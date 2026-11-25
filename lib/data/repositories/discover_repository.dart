import '../models/profile.dart';

/// Contract for the Teachers / Students tabs; the visibility rules are
/// `DiscoverVisibilityRules` (computed server-side as `profiles.is_visible`
/// in the Supabase implementation).
///
/// Each stream emits the current list; an implementation may emit again on
/// changes (the mock does) or only once (Supabase, no Realtime): cancel and
/// re-subscribe to reload. Load errors arrive on the stream as `*Failure`.
abstract interface class DiscoverRepository {
  /// Teachers [viewerId] may see: verified, at least 80 % complete, not
  /// blocked in either direction (Supabase: from the Safety phase). Never
  /// includes [viewerId]. Order is not part of the contract.
  Stream<List<Profile>> watchTeachers({required String viewerId});

  /// Students [viewerId] may see: "Looking for a teacher" on, at least 60 %
  /// complete, not blocked in either direction (Supabase: from the Safety
  /// phase). Never includes [viewerId]; student photos are never returned.
  /// Order is not part of the contract.
  Stream<List<Profile>> watchStudents({required String viewerId});
}
