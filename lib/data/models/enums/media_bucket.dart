/// Supabase Storage buckets used by the app (PHASE_005). Post and chat
/// images are added by their phases.
enum MediaBucket {
  /// Profile photos; public read, owner writes (JPEG, 1 MB).
  avatars('avatars'),

  /// Teacher certificates; private to the owner (PDF, 3 MB).
  certificates('certificates');

  const MediaBucket(this.id);

  /// Bucket id in Supabase.
  final String id;
}
