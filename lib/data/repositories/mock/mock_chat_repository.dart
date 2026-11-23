import 'dart:async';

import '../../../core/errors/failures.dart';
import '../../mock/mock_chats.dart';
import '../../models/conversation.dart';
import '../../models/message.dart';
import '../chat_repository.dart';
import 'mock_connection_repository.dart';

/// In-memory [ChatRepository] (resets on restart). Chat is allowed only
/// between accepted connections of [MockConnectionRepository].
class MockChatRepository implements ChatRepository {
  MockChatRepository(this._connections, {DateTime? now}) : _now = now {
    final seed = buildMockChats(now ?? DateTime.now());
    for (final c in seed.conversations) {
      _conversations[c.id] = c;
    }
    _messages.addAll(seed.messages);
  }

  final MockConnectionRepository _connections;
  final DateTime? _now;
  final Map<String, Conversation> _conversations = <String, Conversation>{};
  final List<Message> _messages = <Message>[];
  final StreamController<void> _changes = StreamController<void>.broadcast();
  int _nextConversation = 100;
  int _nextMessage = 1000;

  DateTime get _clock => _now ?? DateTime.now();

  /// Deletes every conversation of [userId] (mock account deletion).
  void removeUser(String userId) {
    final ids = _conversations.values
        .where((c) => c.memberIds.contains(userId))
        .map((c) => c.id)
        .toSet();
    _conversations.removeWhere((id, _) => ids.contains(id));
    _messages.removeWhere((m) => ids.contains(m.conversationId));
    _changes.add(null);
  }

  Conversation _view(Conversation c, String viewerId) {
    final own = _messages.where((m) => m.conversationId == c.id).toList()
      ..sort((a, b) => a.sentAt.compareTo(b.sentAt));
    return Conversation(
      id: c.id,
      memberIds: c.memberIds,
      startedAt: c.startedAt,
      lastMessage: own.isEmpty ? null : own.last,
      unreadCount: own.where((m) => m.senderId != viewerId && !m.isRead).length,
    );
  }

  List<Conversation> _list(String userId) {
    final connected = _connections.acceptedIdsOf(userId);
    final list = _conversations.values
        .where(
          (c) =>
              c.memberIds.contains(userId) &&
              connected.contains(c.otherId(userId)),
        )
        .map((c) => _view(c, userId))
        .where((c) => c.lastMessage != null)
        .toList();
    list.sort((a, b) => b.lastMessage!.sentAt.compareTo(a.lastMessage!.sentAt));
    return list;
  }

  Stream<T> _watch<T>(T Function() read) {
    late final StreamController<T> controller;
    final subs = <StreamSubscription<void>>[];
    controller = StreamController<T>(
      onListen: () {
        void push(void _) {
          try {
            controller.add(read());
          } on Failure catch (f) {
            controller.addError(f);
          }
        }

        push(null);
        subs
          ..add(_changes.stream.listen(push))
          ..add(_connections.changes.listen(push));
      },
      onCancel: () async {
        for (final s in subs) {
          await s.cancel();
        }
      },
    );
    return controller.stream;
  }

  @override
  Stream<List<Conversation>> watchConversations(String userId) =>
      _watch(() => _list(userId));

  @override
  Future<Conversation> openConversation({
    required String userId,
    required String otherId,
  }) async {
    if (!_connections.acceptedIdsOf(userId).contains(otherId)) {
      throw const ValidationFailure(ValidationReason.notConnected);
    }
    for (final c in _conversations.values) {
      if (c.memberIds.contains(userId) && c.memberIds.contains(otherId)) {
        return _view(c, userId);
      }
    }
    final created = Conversation(
      id: 'chat-${_nextConversation++}',
      memberIds: <String>[userId, otherId],
      startedAt: _clock,
    );
    _conversations[created.id] = created;
    _changes.add(null);
    return created;
  }

  Conversation _member(String conversationId, String userId) {
    final c = _conversations[conversationId];
    if (c == null || !c.memberIds.contains(userId)) {
      throw const NotFoundFailure();
    }
    return c;
  }

  @override
  Stream<List<Message>> watchMessages({
    required String conversationId,
    required String viewerId,
  }) => _watch(() {
    _member(conversationId, viewerId);
    return _messages.where((m) => m.conversationId == conversationId).toList()
      ..sort((a, b) => a.sentAt.compareTo(b.sentAt));
  });

  @override
  Future<Message> sendMessage({
    required String conversationId,
    required String senderId,
    String? body,
    String? imagePath,
  }) async {
    final c = _member(conversationId, senderId);
    if (!_connections.acceptedIdsOf(senderId).contains(c.otherId(senderId))) {
      throw const ValidationFailure(ValidationReason.notConnected);
    }
    final text = body?.trim();
    if ((text == null || text.isEmpty) && imagePath == null) {
      throw const ValidationFailure(ValidationReason.messageEmpty);
    }
    final message = Message(
      id: 'message-${_nextMessage++}',
      conversationId: conversationId,
      senderId: senderId,
      sentAt: _clock,
      body: (text == null || text.isEmpty) ? null : text,
      imagePath: imagePath,
    );
    _messages.add(message);
    _changes.add(null);
    return message;
  }

  @override
  Future<void> markRead({
    required String conversationId,
    required String userId,
  }) async {
    _member(conversationId, userId);
    var changed = false;
    for (var i = 0; i < _messages.length; i++) {
      final m = _messages[i];
      if (m.conversationId == conversationId &&
          m.senderId != userId &&
          !m.isRead) {
        _messages[i] = m.markRead(_clock);
        changed = true;
      }
    }
    if (changed) {
      _changes.add(null);
    }
  }
}
