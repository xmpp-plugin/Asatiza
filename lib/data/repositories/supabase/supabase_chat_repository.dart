import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/failures.dart';
import '../../models/conversation.dart';
import '../../models/enums/media_bucket.dart';
import '../../models/message.dart';
import '../chat_repository.dart';
import 'supabase_failure_mapper.dart';

/// [ChatRepository] on `public.conversations` / `public.messages`
/// (`supabase/migrations/20261129120000_chat.sql`).
///
/// Reads go through RLS (members only, hidden while blocked); writes are the
/// database functions `open_conversation`, `send_message`,
/// `mark_conversation_read`; the Chats list is `list_conversations`.
/// Streams re-load on Supabase Realtime events for `messages` (RLS decides
/// which events arrive) and after changes made through this repository.
/// Every Realtime channel is removed when its stream is cancelled.
class SupabaseChatRepository implements ChatRepository {
  SupabaseChatRepository(
    this._client, {
    SupabaseFailureMapper failures = const SupabaseFailureMapper(),
  }) : _failures = failures;

  final SupabaseClient _client;
  final SupabaseFailureMapper _failures;
  final StreamController<void> _changes = StreamController<void>.broadcast();
  int _channelCount = 0;

  /// Latest messages a chat loads (PHASE_009 decision 12).
  static const int maxMessages = 200;

  /// Lifetime of photo links.
  static const int signedUrlSeconds = 3600;

  Future<T> _guard<T>(Future<T> Function() run) async {
    try {
      return await run();
    } on PostgrestException catch (error) {
      throw mapError(error.message) ?? _failures.map(error);
    } catch (error) {
      throw _failures.map(error);
    }
  }

  /// The `Failure` for a rule message raised by the chat functions, or null
  /// for anything else.
  @visibleForTesting
  static Failure? mapError(String message) => switch (message) {
    'not_found' => const NotFoundFailure(),
    'not_connected' => const ValidationFailure(ValidationReason.notConnected),
    'message_empty' => const ValidationFailure(ValidationReason.messageEmpty),
    'message_too_long' => const ValidationFailure(
      ValidationReason.messageTooLong,
    ),
    'daily_message_limit' => const ValidationFailure(
      ValidationReason.dailyMessageLimit,
    ),
    'daily_photo_limit' => const ValidationFailure(
      ValidationReason.dailyPhotoLimit,
    ),
    'invalid_image' => const UnexpectedFailure(),
    _ => null,
  };

  /// Maps a `messages` row to a [Message] (without a signed URL).
  @visibleForTesting
  static Message messageFromRow(Map<String, dynamic> row) => Message(
    id: row['id'] as String,
    conversationId: row['conversation_id'] as String,
    senderId: row['sender_id'] as String,
    sentAt: DateTime.parse(row['created_at'] as String),
    body: row['body'] as String?,
    imagePath: row['image_path'] as String?,
    readAt: row['read_at'] == null
        ? null
        : DateTime.parse(row['read_at'] as String),
  );

  /// Maps a `list_conversations()` / `open_conversation()` row.
  @visibleForTesting
  static Conversation conversationFromRow(Map<String, dynamic> row) {
    final lastId = row['last_id'] as String?;
    return Conversation(
      id: row['id'] as String,
      memberIds: <String>[row['user_a'] as String, row['user_b'] as String],
      startedAt: DateTime.parse(row['started_at'] as String),
      canSend: (row['can_send'] as bool?) ?? false,
      unreadCount: (row['unread_count'] as int?) ?? 0,
      lastMessage: lastId == null
          ? null
          : Message(
              id: lastId,
              conversationId: row['id'] as String,
              senderId: row['last_sender_id'] as String,
              sentAt: DateTime.parse(row['last_created_at'] as String),
              body: row['last_body'] as String?,
              imagePath: row['last_image_path'] as String?,
              readAt: row['last_read_at'] == null
                  ? null
                  : DateTime.parse(row['last_read_at'] as String),
            ),
    );
  }

  // ------------------------------------------------------------ streams

  /// Emits [load] on subscribe, on every Realtime event of a channel
  /// configured by [configure], and after local changes. Load errors arrive
  /// as `Failure`s; the stream keeps listening.
  Stream<T> _watch<T>(
    Future<T> Function() load,
    RealtimeChannel Function(RealtimeChannel, void Function()) configure,
  ) {
    late final StreamController<T> controller;
    StreamSubscription<void>? changes;
    RealtimeChannel? channel;
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
        channel = configure(
          _client.channel('chat-${_channelCount++}'),
          () => unawaited(push()),
        )..subscribe();
      },
      onCancel: () async {
        await changes?.cancel();
        final open = channel;
        if (open != null) {
          await _client.removeChannel(open);
        }
        await controller.close();
      },
    );
    return controller.stream;
  }

  @override
  Stream<List<Conversation>> watchConversations(String userId) => _watch(
    () => _guard(() async {
      final rows = await _client.rpc<List<dynamic>>('list_conversations');
      return <Conversation>[
        for (final row in rows)
          conversationFromRow(row as Map<String, dynamic>),
      ];
    }),
    // Any message the user may see (RLS filters the events).
    (channel, reload) => channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'messages',
      callback: (_) => reload(),
    ),
  );

  @override
  Stream<List<Message>> watchMessages({
    required String conversationId,
    required String viewerId,
  }) => _watch(
    () => _loadMessages(conversationId),
    (channel, reload) => channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'messages',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'conversation_id',
        value: conversationId,
      ),
      callback: (_) => reload(),
    ),
  );

  Future<List<Message>> _loadMessages(String conversationId) =>
      _guard(() async {
        final rows = await _client
            .from('messages')
            .select()
            .eq('conversation_id', conversationId)
            .order('created_at', ascending: false)
            .limit(maxMessages);
        final messages = rows.map(messageFromRow).toList().reversed.toList();
        return _withSignedUrls(messages);
      });

  /// Adds short-lived photo links (private bucket).
  Future<List<Message>> _withSignedUrls(List<Message> messages) async {
    final paths = <String>[
      for (final m in messages)
        if (m.imagePath != null) m.imagePath!,
    ];
    if (paths.isEmpty) {
      return messages;
    }
    final signed = await _client.storage
        .from(MediaBucket.chatImages.id)
        .createSignedUrlsResult(paths, signedUrlSeconds);
    // A photo that cannot be signed (e.g. deleted) shows a placeholder.
    final urls = <String, String>{
      for (final s in signed.whereType<SignedUrlSuccess>()) s.path: s.signedUrl,
    };
    return <Message>[
      for (final m in messages)
        m.imagePath == null || urls[m.imagePath] == null
            ? m
            : Message(
                id: m.id,
                conversationId: m.conversationId,
                senderId: m.senderId,
                sentAt: m.sentAt,
                body: m.body,
                imagePath: m.imagePath,
                imageUrl: urls[m.imagePath],
                readAt: m.readAt,
              ),
    ];
  }

  // ------------------------------------------------------------ writes

  @override
  Future<Conversation> openConversation({
    required String userId,
    required String otherId,
  }) => _guard(() async {
    if (userId != _client.auth.currentUser?.id) {
      throw const NotFoundFailure();
    }
    final rows = await _client.rpc<List<dynamic>>(
      'open_conversation',
      params: <String, dynamic>{'p_other': otherId},
    );
    if (rows.isEmpty) {
      throw const NotFoundFailure();
    }
    return conversationFromRow(rows.first as Map<String, dynamic>);
  });

  @override
  Future<Message> sendMessage({
    required String conversationId,
    required String senderId,
    String? body,
    String? imagePath,
  }) async {
    if (senderId != _client.auth.currentUser?.id) {
      throw const NotFoundFailure();
    }
    final text = body?.trim();
    if ((text == null || text.isEmpty) && imagePath == null) {
      throw const ValidationFailure(ValidationReason.messageEmpty);
    }
    if (text != null && text.length > 2000) {
      throw const ValidationFailure(ValidationReason.messageTooLong);
    }
    final row = await _guard(
      () => _client.rpc<Map<String, dynamic>>(
        'send_message',
        params: <String, dynamic>{
          'p_conversation': conversationId,
          'p_body': text,
          'p_image_path': imagePath,
        },
      ),
    );
    _changes.add(null);
    return messageFromRow(row);
  }

  @override
  Future<void> markRead({
    required String conversationId,
    required String userId,
  }) async {
    await _guard(
      () => _client.rpc<void>(
        'mark_conversation_read',
        params: <String, dynamic>{'p_conversation': conversationId},
      ),
    );
    _changes.add(null);
  }
}
