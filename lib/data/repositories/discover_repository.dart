import '../models/profile.dart';

/// Provisional contract for the Teachers / Students tabs. The backend phase
/// implements it with Supabase queries and RLS; the visibility rules are the
/// same (`DiscoverVisibilityRules`).
abstract interface class DiscoverRepository {
  /// Teachers [viewerId] may see: verified, at least 80 % complete, not
  /// blocked in either direction. Unordered; emits again on changes.
  Stream<List<Profile>> watchTeachers({required String viewerId});

  /// Students [viewerId] may see: "Looking for a teacher" on, at least 60 %
  /// complete, not blocked in either direction. Student photos are never
  /// returned. Unordered; emits again on changes.
  Stream<List<Profile>> watchStudents({required String viewerId});
}
