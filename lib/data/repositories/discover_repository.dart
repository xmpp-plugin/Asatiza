import '../models/profile.dart';

/// Contract for the Teachers / Students tabs; the visibility rules are
/// `DiscoverVisibilityRules`: every active profile (`profiles.status =
/// 'active'` in the Supabase implementation).
///
/// Each stream emits the current list; an implementation may emit again on
/// changes (the mock does) or only once (Supabase, no Realtime): cancel and
/// re-subscribe to reload. Load errors arrive on the stream as `*Failure`.
abstract interface class DiscoverRepository {
  /// Teachers [viewerId] may see: active (verified or not), not blocked in
  /// either direction (Supabase: from the Safety phase). Never includes
  /// [viewerId]. Order is not part of the contract (callers apply
  /// `DailyShuffle`).
  Stream<List<Profile>> watchTeachers({required String viewerId});

  /// Students [viewerId] may see: active ("Looking for a teacher" is only
  /// information), not blocked in either direction (Supabase: from the
  /// Safety phase). Never includes [viewerId]; student photos are never
  /// returned. Order is not part of the contract.
  Stream<List<Profile>> watchStudents({required String viewerId});
}
