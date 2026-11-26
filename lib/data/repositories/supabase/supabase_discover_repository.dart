import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/enums/media_bucket.dart';
import '../../models/enums/user_role.dart';
import '../../models/profile.dart';
import '../discover_repository.dart';
import 'profile_row_mapper.dart';
import 'supabase_failure_mapper.dart';

/// [DiscoverRepository] on `profiles` + `teacher_details` /
/// `student_details`.
///
/// Lists only rows with `status = 'active'`, which the database sets when
/// every required field is filled (`private.profile_is_complete`); the app
/// can never write it. Admin approval and "Looking for a teacher" do not
/// affect listing. RLS is unchanged (signed-in users read profiles). Each subscription loads once (no
/// Realtime, PHASE_006 decision 2); re-subscribe to reload.
///
/// Blocked users are not filtered yet: the `blocks` table arrives with the
/// Safety phase, which adds that filter here (PHASE_006 decision 1,
/// `docs/KNOWN_ISSUES.md`).
class SupabaseDiscoverRepository implements DiscoverRepository {
  SupabaseDiscoverRepository(
    this._client, {
    ProfileRowMapper rows = const ProfileRowMapper(),
    SupabaseFailureMapper failures = const SupabaseFailureMapper(),
  }) : _rows = rows,
       _failures = failures;

  final SupabaseClient _client;
  final ProfileRowMapper _rows;
  final SupabaseFailureMapper _failures;

  /// Most rows one list loads, newest first (PHASE_006 decision 3).
  static const int maxRows = 500;

  @override
  Stream<List<Profile>> watchTeachers({required String viewerId}) =>
      Stream<List<Profile>>.fromFuture(_load(UserRole.teacher, viewerId));

  @override
  Stream<List<Profile>> watchStudents({required String viewerId}) =>
      Stream<List<Profile>>.fromFuture(_load(UserRole.student, viewerId));

  Future<List<Profile>> _load(UserRole role, String viewerId) async {
    try {
      final rows = await _client
          .from('profiles')
          .select(ProfileRowMapper.select)
          .eq('role', role.name)
          .eq('status', 'active')
          .neq('id', viewerId)
          .order('created_at', ascending: false)
          .limit(maxRows);
      return toProfiles(rows, viewerId: viewerId);
    } catch (error) {
      throw _failures.map(error);
    }
  }

  /// Maps loaded rows: drops the viewer, removes every student photo (plan
  /// section 7) and fills teacher photo URLs from the public `avatars`
  /// bucket.
  @visibleForTesting
  List<Profile> toProfiles(
    List<Map<String, dynamic>> rows, {
    required String viewerId,
  }) => <Profile>[
    for (final row in rows)
      if (row['id'] != viewerId) _profile(row),
  ];

  Profile _profile(Map<String, dynamic> row) {
    final student = row['role'] == UserRole.student.name;
    final profile = _rows.fromRow(
      student ? (<String, dynamic>{...row}..['photo_path'] = null) : row,
    );
    final path = profile.photoPath;
    return path == null
        ? profile
        : profile.copyWith(
            photoUrl: _client.storage
                .from(MediaBucket.avatars.id)
                .getPublicUrl(path),
          );
  }
}
