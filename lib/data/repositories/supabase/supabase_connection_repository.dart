import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/failures.dart';
import '../../models/connection.dart';
import '../../models/enums/connection_status.dart';
import '../connection_repository.dart';
import 'supabase_failure_mapper.dart';

/// [ConnectionRepository] on `public.connections`
/// (`supabase/migrations/20261128120000_connections.sql`).
///
/// Reads go through RLS (only connections the user is part of); every write
/// is a database function that checks the rules (active profiles, blocks,
/// 3-day re-request, 10 requests per 24 hours). No Realtime: a stream loads
/// on subscribe and after every change made through this repository, and
/// every load is shared with all open streams of the same user.
class SupabaseConnectionRepository implements ConnectionRepository {
  SupabaseConnectionRepository(
    this._client, {
    SupabaseFailureMapper failures = const SupabaseFailureMapper(),
  }) : _failures = failures;

  final SupabaseClient _client;
  final SupabaseFailureMapper _failures;
  final StreamController<void> _changes = StreamController<void>.broadcast();

  Future<T> _guard<T>(Future<T> Function() run) async {
    try {
      return await run();
    } on PostgrestException catch (error) {
      throw mapError(error.message) ?? _failures.map(error);
    } catch (error) {
      throw _failures.map(error);
    }
  }

  /// The `Failure` for a rule message raised by the connection functions, or
  /// null for anything else.
  @visibleForTesting
  static Failure? mapError(String message) => switch (message) {
    'note_too_long' => const ValidationFailure(
      ValidationReason.connectNoteTooLong,
    ),
    'sender_not_active' => const ValidationFailure(
      ValidationReason.profileIncomplete,
    ),
    'receiver_not_active' => const ValidationFailure(
      ValidationReason.receiverNotActive,
    ),
    'already_connected' || 'self_request' => const ValidationFailure(
      ValidationReason.alreadyConnected,
    ),
    'declined_recently' => const ValidationFailure(
      ValidationReason.declinedRecently,
    ),
    'request_limit' => const ValidationFailure(
      ValidationReason.requestLimitReached,
    ),
    'not_found' => const NotFoundFailure(),
    _ => null,
  };

  /// Maps a `connections` row to a [Connection].
  @visibleForTesting
  static Connection fromRow(Map<String, dynamic> row) => Connection(
    id: row['id'] as String,
    requesterId: row['requester_id'] as String,
    receiverId: row['receiver_id'] as String,
    status: ConnectionStatus.values.firstWhere(
      (s) => s.name == row['status'],
      orElse: () => ConnectionStatus.removed,
    ),
    createdAt: DateTime.parse(row['created_at'] as String),
    note: row['note'] as String?,
  );

  Future<List<Connection>> _load(String userId) => _guard(() async {
    final rows = await _client
        .from('connections')
        .select()
        .or('requester_id.eq.$userId,receiver_id.eq.$userId')
        .inFilter('status', <String>[
          ConnectionStatus.pending.name,
          ConnectionStatus.accepted.name,
        ])
        .order('created_at', ascending: false);
    return rows.map(fromRow).toList();
  });

  /// Latest load per user, shared by every open stream of that user.
  final Map<String, StreamController<List<Connection>>> _results =
      <String, StreamController<List<Connection>>>{};

  StreamController<List<Connection>> _resultsFor(String userId) => _results
      .putIfAbsent(userId, StreamController<List<Connection>>.broadcast);

  /// Loads [userId]'s connections and hands the result to **every** open
  /// stream of that user, so a screen kept alive (e.g. the Teachers tab)
  /// sees what another screen just loaded (e.g. a request the other person
  /// accepted on their device).
  Future<void> _reload(String userId) async {
    final results = _resultsFor(userId);
    try {
      results.add(await _load(userId));
    } on Failure catch (failure) {
      results.addError(failure);
    }
  }

  @override
  Stream<List<Connection>> watchConnections(String userId) {
    late final StreamController<List<Connection>> controller;
    StreamSubscription<List<Connection>>? results;
    StreamSubscription<void>? changes;
    controller = StreamController<List<Connection>>(
      onListen: () {
        results = _resultsFor(
          userId,
        ).stream.listen(controller.add, onError: controller.addError);
        changes = _changes.stream.listen((_) => unawaited(_reload(userId)));
        unawaited(_reload(userId));
      },
      onCancel: () async {
        await results?.cancel();
        await changes?.cancel();
        await controller.close();
      },
    );
    return controller.stream;
  }

  @override
  Future<Connection> sendRequest({
    required String requesterId,
    required String receiverId,
    String? note,
  }) async {
    if (requesterId != _client.auth.currentUser?.id) {
      throw const NotFoundFailure();
    }
    final row = await _guard(
      () => _client.rpc<Map<String, dynamic>>(
        'send_connection_request',
        params: <String, dynamic>{'p_receiver': receiverId, 'p_note': note},
      ),
    );
    _changes.add(null);
    return fromRow(row);
  }

  @override
  Future<void> respond({
    required String connectionId,
    required String userId,
    required bool accept,
  }) async {
    await _guard(
      () => _client.rpc<void>(
        'respond_to_connection',
        params: <String, dynamic>{'p_id': connectionId, 'p_accept': accept},
      ),
    );
    _changes.add(null);
  }

  @override
  Future<void> remove({
    required String connectionId,
    required String userId,
  }) async {
    await _guard(
      () => _client.rpc<void>(
        'remove_connection',
        params: <String, dynamic>{'p_id': connectionId},
      ),
    );
    _changes.add(null);
  }

  @override
  Future<int> connectionCount(String userId) => _guard(
    () async => await _client.rpc<int>(
      'connection_count',
      params: <String, dynamic>{'p_user': userId},
    ),
  );
}
