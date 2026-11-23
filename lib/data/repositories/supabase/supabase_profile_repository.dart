import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/failures.dart';
import '../../models/profile.dart';
import '../profile_repository.dart';
import 'profile_row_mapper.dart';
import 'supabase_failure_mapper.dart';

/// [ProfileRepository] on the `profiles`, `teacher_details` and
/// `student_details` tables (RLS: signed-in users read; owners update their
/// own editable columns; `role`, `is_verified`, `is_visible` and
/// `completion_pct` are never written by the app).
///
/// [watchProfile] emits the stored profile and then every save made through
/// this repository (no Realtime in this phase).
class SupabaseProfileRepository implements ProfileRepository {
  SupabaseProfileRepository(
    this._client, {
    ProfileRowMapper rows = const ProfileRowMapper(),
    SupabaseFailureMapper failures = const SupabaseFailureMapper(),
  }) : _rows = rows,
       _failures = failures;

  final SupabaseClient _client;
  final ProfileRowMapper _rows;
  final SupabaseFailureMapper _failures;
  final StreamController<Profile> _saved =
      StreamController<Profile>.broadcast();

  User? get _me => _client.auth.currentUser;

  Future<T> _guard<T>(Future<T> Function() run) async {
    try {
      return await run();
    } catch (error) {
      throw _failures.map(error);
    }
  }

  Profile _profile(Map<String, dynamic> row) {
    final me = _me;
    return _rows.fromRow(row, email: row['id'] == me?.id ? me?.email : null);
  }

  @override
  Future<Profile> getProfile(String id) => _guard(() async {
    final row = await _client
        .from('profiles')
        .select(ProfileRowMapper.select)
        .eq('id', id)
        .maybeSingle();
    if (row == null) {
      throw const NotFoundFailure();
    }
    return _profile(row);
  });

  @override
  Future<List<Profile>> getProfiles(Iterable<String> ids) => _guard(() async {
    final unique = ids.toSet().toList();
    if (unique.isEmpty) {
      return const <Profile>[];
    }
    final rows = await _client
        .from('profiles')
        .select(ProfileRowMapper.select)
        .inFilter('id', unique);
    return rows.map(_profile).toList();
  });

  @override
  Stream<Profile> watchProfile(String id) async* {
    yield await getProfile(id);
    yield* _saved.stream.where((profile) => profile.id == id);
  }

  @override
  Future<Profile> updateProfile(Profile profile) => _guard(() async {
    if (profile.id != _me?.id) {
      throw const NotFoundFailure();
    }
    final updated = await _client
        .from('profiles')
        .update(_rows.profileUpdate(profile))
        .eq('id', profile.id)
        .select('id');
    if (updated.isEmpty) {
      throw const NotFoundFailure();
    }
    final teacher = profile.teacherDetails;
    final student = profile.studentDetails;
    if (profile.isTeacher && teacher != null) {
      await _client
          .from('teacher_details')
          .upsert(_rows.teacherRow(profile.id, teacher));
    } else if (!profile.isTeacher && student != null) {
      await _client
          .from('student_details')
          .upsert(_rows.studentRow(profile.id, student));
    }
    final stored = await getProfile(profile.id);
    _saved.add(stored);
    return stored;
  });
}
