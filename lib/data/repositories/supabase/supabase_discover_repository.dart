import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/enums/media_bucket.dart';
import '../../models/enums/user_role.dart';
import '../../models/profile.dart';
import '../block_repository.dart';
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
/// Blocks (PHASE_007): people the viewer blocked are dropped here; people
/// who blocked the viewer are already hidden by RLS. The list re-loads
/// whenever the viewer's blocks change ([BlockRepository.watchBlockedIds]).
class SupabaseDiscoverRepository implements DiscoverRepository {
  SupabaseDiscoverRepository(
    this._client,
    this._blocks, {
    ProfileRowMapper rows = const ProfileRowMapper(),
    SupabaseFailureMapper failures = const SupabaseFailureMapper(),
  }) : _rows = rows,
       _failures = failures;

  final SupabaseClient _client;
  final BlockRepository _blocks;
  final ProfileRowMapper _rows;
  final SupabaseFailureMapper _failures;

  /// Most rows one list loads, newest first (PHASE_006 decision 3).
  static const int maxRows = 500;

  @override
  Stream<List<Profile>> watchTeachers({required String viewerId}) =>
      _watch(UserRole.teacher, viewerId);

  @override
  Stream<List<Profile>> watchStudents({required String viewerId}) =>
      _watch(UserRole.student, viewerId);

  /// Loads once per change of the viewer's blocks (first emission on
  /// subscribe). Errors arrive on the stream as `Failure`s.
  Stream<List<Profile>> _watch(UserRole role, String viewerId) => _blocks
      .watchBlockedIds(viewerId)
      .asyncMap((blocked) => _load(role, viewerId, blocked));

  Future<List<Profile>> _load(
    UserRole role,
    String viewerId,
    Set<String> blocked,
  ) async {
    try {
      final rows = await _client
          .from('profiles')
          .select(ProfileRowMapper.select)
          .eq('role', role.name)
          .eq('status', 'active')
          .neq('id', viewerId)
          .order('created_at', ascending: false)
          .limit(maxRows);
      return toProfiles(rows, viewerId: viewerId, blocked: blocked);
    } catch (error) {
      throw _failures.map(error);
    }
  }

  /// Maps loaded rows: drops the viewer and the people the viewer [blocked],
  /// removes every student photo (plan section 7) and fills teacher photo
  /// URLs from the public `avatars` bucket.
  @visibleForTesting
  List<Profile> toProfiles(
    List<Map<String, dynamic>> rows, {
    required String viewerId,
    Set<String> blocked = const <String>{},
  }) => <Profile>[
    for (final row in rows)
      if (row['id'] != viewerId && !blocked.contains(row['id'])) _profile(row),
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
