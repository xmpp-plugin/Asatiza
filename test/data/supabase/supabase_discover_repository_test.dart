import 'package:asatiza/data/models/enums/user_role.dart';
import 'package:asatiza/data/repositories/supabase/supabase_discover_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  // No network: only row mapping and the public-URL builder are used.
  final repo = SupabaseDiscoverRepository(
    SupabaseClient('https://example.supabase.co', 'public-test-key'),
  );

  Map<String, dynamic> row(String id, String role, {String? photo}) =>
      <String, dynamic>{
        'id': id,
        'role': role,
        'full_name': 'Person $id',
        'created_at': '2026-11-25T10:00:00Z',
        'photo_path': photo,
        'languages': <String>['urdu'],
        'is_verified': role == 'teacher',
        'status': 'active',
        'teacher_details': role == 'teacher'
            ? <String, dynamic>{
                'subjects': <String>['tajweed'],
              }
            : null,
        'student_details': role == 'student'
            ? <String, dynamic>{'looking_for_teacher': true}
            : null,
      };

  test('drops the viewer', () {
    final people = repo.toProfiles(<Map<String, dynamic>>[
      row('me', 'teacher'),
      row('t-1', 'teacher'),
    ], viewerId: 'me');
    expect(people.map((p) => p.id), <String>['t-1']);
  });

  test('teacher photos get a public avatars URL', () {
    final people = repo.toProfiles(<Map<String, dynamic>>[
      row('t-1', 'teacher', photo: 't-1/avatar.jpg'),
    ], viewerId: 'me');
    expect(people.single.role, UserRole.teacher);
    expect(people.single.photoPath, 't-1/avatar.jpg');
    expect(people.single.photoUrl, contains('/avatars/t-1/avatar.jpg'));
  });

  test('student photos are never returned', () {
    final people = repo.toProfiles(<Map<String, dynamic>>[
      row('s-1', 'student', photo: 's-1/avatar.jpg'),
    ], viewerId: 'me');
    expect(people.single.role, UserRole.student);
    expect(people.single.photoPath, isNull);
    expect(people.single.photoUrl, isNull);
  });
}
