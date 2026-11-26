import 'package:asatiza/core/errors/failures.dart';
import 'package:asatiza/data/models/enums/connection_status.dart';
import 'package:asatiza/data/repositories/supabase/supabase_connection_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a connections row maps to a Connection', () {
    final c = SupabaseConnectionRepository.fromRow(<String, dynamic>{
      'id': 'c-1',
      'requester_id': 'a',
      'receiver_id': 'b',
      'status': 'accepted',
      'note': 'Assalamu alaikum',
      'created_at': '2026-11-26T10:00:00Z',
      'responded_at': '2026-11-26T11:00:00Z',
    });
    expect(c.id, 'c-1');
    expect(c.requesterId, 'a');
    expect(c.receiverId, 'b');
    expect(c.status, ConnectionStatus.accepted);
    expect(c.note, 'Assalamu alaikum');
    expect(c.createdAt, DateTime.utc(2026, 11, 26, 10));
  });

  test('database rule messages map to failures', () {
    Failure? map(String m) => SupabaseConnectionRepository.mapError(m);
    expect(
      map('note_too_long'),
      const ValidationFailure(ValidationReason.connectNoteTooLong),
    );
    expect(
      map('sender_not_active'),
      const ValidationFailure(ValidationReason.profileIncomplete),
    );
    expect(
      map('receiver_not_active'),
      const ValidationFailure(ValidationReason.receiverNotActive),
    );
    expect(
      map('already_connected'),
      const ValidationFailure(ValidationReason.alreadyConnected),
    );
    expect(
      map('self_request'),
      const ValidationFailure(ValidationReason.alreadyConnected),
    );
    expect(
      map('declined_recently'),
      const ValidationFailure(ValidationReason.declinedRecently),
    );
    expect(
      map('request_limit'),
      const ValidationFailure(ValidationReason.requestLimitReached),
    );
    expect(map('not_found'), const NotFoundFailure());
    expect(map('something else'), isNull);
  });
}
