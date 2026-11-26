import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/failures.dart';
import '../block_repository.dart';
import 'supabase_failure_mapper.dart';

/// [BlockRepository] on `public.blocks`
/// (`supabase/migrations/20261127120000_blocks.sql`).
///
/// RLS: users create, read and delete only their own blocks; the database
/// also hides a blocker's profile from the person they blocked. No Realtime:
/// streams load on subscribe and again after every block / unblock made
/// through this repository (a block made by someone else shows on the next
/// load).
class SupabaseBlockRepository implements BlockRepository {
  SupabaseBlockRepository(
    this._client, {
    SupabaseFailureMapper failures = const SupabaseFailureMapper(),
  }) : _failures = failures;

  final SupabaseClient _client;
  final SupabaseFailureMapper _failures;
  final StreamController<void> _changes = StreamController<void>.broadcast();

  /// Postgres unique violation: the block already exists.
  static const String _duplicate = '23505';

  Future<T> _guard<T>(Future<T> Function() run) async {
    try {
      return await run();
    } catch (error) {
      throw _failures.map(error);
    }
  }

  @override
  Future<void> blockUser({
    required String blockerId,
    required String blockedId,
  }) async {
    if (blockerId == blockedId) {
      return;
    }
    await _guard(() async {
      try {
        await _client.from('blocks').insert(<String, dynamic>{
          'blocker_id': blockerId,
          'blocked_id': blockedId,
        });
      } on PostgrestException catch (error) {
        if (error.code != _duplicate) {
          rethrow;
        }
      }
    });
    _changes.add(null);
  }

  @override
  Future<void> unblockUser({
    required String blockerId,
    required String blockedId,
  }) async {
    await _guard(
      () => _client
          .from('blocks')
          .delete()
          .eq('blocker_id', blockerId)
          .eq('blocked_id', blockedId),
    );
    _changes.add(null);
  }

  @override
  Stream<Set<String>> watchBlockedIds(String userId) => _watch(
    () async => <String>{for (final b in await _load(userId)) b.userId},
  );

  @override
  Stream<List<BlockedUser>> watchBlockedUsers(String userId) =>
      _watch(() => _load(userId));

  Future<List<BlockedUser>> _load(String userId) => _guard(() async {
    final rows = await _client
        .from('blocks')
        .select('blocked_id, created_at')
        .eq('blocker_id', userId)
        .order('created_at', ascending: false);
    return toBlockedUsers(rows);
  });

  /// Maps `blocks` rows to [BlockedUser]s, newest first.
  @visibleForTesting
  static List<BlockedUser> toBlockedUsers(List<Map<String, dynamic>> rows) =>
      <BlockedUser>[
        for (final row in rows)
          (
            userId: row['blocked_id'] as String,
            blockedAt: DateTime.parse(row['created_at'] as String),
          ),
      ]..sort((a, b) => b.blockedAt.compareTo(a.blockedAt));

  /// Emits [load] on subscribe and after every local change; a failed load
  /// arrives as a `Failure` error and the stream keeps listening.
  Stream<T> _watch<T>(Future<T> Function() load) {
    late final StreamController<T> controller;
    StreamSubscription<void>? changes;
    Future<void> push() async {
      try {
        final value = await load();
        if (!controller.isClosed) {
          controller.add(value);
        }
      } on Failure catch (failure) {
        if (!controller.isClosed) {
          controller.addError(failure);
        }
      }
    }

    controller = StreamController<T>(
      onListen: () {
        unawaited(push());
        changes = _changes.stream.listen((_) => unawaited(push()));
      },
      onCancel: () async {
        await changes?.cancel();
        await controller.close();
      },
    );
    return controller.stream;
  }
}
