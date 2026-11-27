import 'package:asatiza/core/errors/failures.dart';
import 'package:asatiza/data/repositories/supabase/supabase_chat_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a messages row maps to a Message', () {
    final m = SupabaseChatRepository.messageFromRow(<String, dynamic>{
      'id': 'm-1',
      'conversation_id': 'c-1',
      'sender_id': 'a',
      'body': 'Assalamu alaikum',
      'image_path': 'a/c-1_123.jpg',
      'read_at': null,
      'created_at': '2026-11-27T10:00:00Z',
    });
    expect(m.id, 'm-1');
    expect(m.conversationId, 'c-1');
    expect(m.senderId, 'a');
    expect(m.body, 'Assalamu alaikum');
    expect(m.imagePath, 'a/c-1_123.jpg');
    expect(m.imageUrl, isNull);
    expect(m.isRead, isFalse);
    expect(m.sentAt, DateTime.utc(2026, 11, 27, 10));
  });

  test('a list_conversations row maps with last message, unread, canSend', () {
    final c = SupabaseChatRepository.conversationFromRow(<String, dynamic>{
      'id': 'c-1',
      'user_a': 'a',
      'user_b': 'b',
      'started_at': '2026-11-20T09:00:00Z',
      'can_send': false,
      'unread_count': 2,
      'last_id': 'm-9',
      'last_sender_id': 'b',
      'last_body': null,
      'last_image_path': 'b/c-1_9.jpg',
      'last_read_at': null,
      'last_created_at': '2026-11-27T10:00:00Z',
    });
    expect(c.memberIds, <String>['a', 'b']);
    expect(c.otherId('a'), 'b');
    expect(c.canSend, isFalse);
    expect(c.unreadCount, 2);
    expect(c.lastMessage!.imagePath, 'b/c-1_9.jpg');
    expect(c.lastMessage!.senderId, 'b');
  });

  test('a new conversation row without messages has no last message', () {
    final c = SupabaseChatRepository.conversationFromRow(<String, dynamic>{
      'id': 'c-2',
      'user_a': 'a',
      'user_b': 'b',
      'started_at': '2026-11-27T09:00:00Z',
      'can_send': true,
    });
    expect(c.lastMessage, isNull);
    expect(c.unreadCount, 0);
    expect(c.canSend, isTrue);
  });

  test('database rule messages map to failures', () {
    Failure? map(String m) => SupabaseChatRepository.mapError(m);
    expect(map('not_found'), const NotFoundFailure());
    expect(
      map('not_connected'),
      const ValidationFailure(ValidationReason.notConnected),
    );
    expect(
      map('message_empty'),
      const ValidationFailure(ValidationReason.messageEmpty),
    );
    expect(
      map('message_too_long'),
      const ValidationFailure(ValidationReason.messageTooLong),
    );
    expect(
      map('daily_message_limit'),
      const ValidationFailure(ValidationReason.dailyMessageLimit),
    );
    expect(
      map('daily_photo_limit'),
      const ValidationFailure(ValidationReason.dailyPhotoLimit),
    );
    expect(map('invalid_image'), const UnexpectedFailure());
    expect(map('anything else'), isNull);
  });
}
