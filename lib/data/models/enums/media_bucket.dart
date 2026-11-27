/// Supabase Storage buckets used by the app (PHASE_005, PHASE_009,
/// PHASE_010).
enum MediaBucket {
  /// Profile photos; public read, owner writes (JPEG, 1 MB).
  avatars('avatars'),

  /// Teacher certificates; private to the owner (PDF, 3 MB).
  certificates('certificates'),

  /// Chat photos; readable only by the two conversation members (JPEG, 1 MB).
  chatImages('chat-images'),

  /// Post photos; public read, owner writes (JPEG, 1 MB).
  postImages('post-images');

  const MediaBucket(this.id);

  /// Bucket id in Supabase.
  final String id;
}
