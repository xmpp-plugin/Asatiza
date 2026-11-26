import 'package:asatiza/data/repositories/supabase/supabase_block_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('rows map to blocked users, newest first', () {
    final list = SupabaseBlockRepository.toBlockedUsers(<Map<String, dynamic>>[
      <String, dynamic>{
        'blocked_id': 'old',
        'created_at': '2026-11-20T10:00:00Z',
      },
      <String, dynamic>{
        'blocked_id': 'new',
        'created_at': '2026-11-26T10:00:00Z',
      },
    ]);
    expect(list.map((b) => b.userId), <String>['new', 'old']);
    expect(list.first.blockedAt, DateTime.utc(2026, 11, 26, 10));
  });

  test('blocking yourself is a no-op (never reaches the server)', () async {
    // No network: the call returns before any request is made.
    final repo = SupabaseBlockRepository(
      SupabaseClient('https://example.supabase.co', 'public-test-key'),
    );
    await repo.blockUser(blockerId: 'me', blockedId: 'me');
  });
}
