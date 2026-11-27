import 'dart:typed_data';

import '../models/enums/media_bucket.dart';

/// Uploads and removals in Supabase Storage (PHASE_005: avatars and
/// certificates; PHASE_009: chat photos; PHASE_010: post photos).
///
/// Paths are relative to the bucket (`<user-id>/<file>`), are built by the
/// implementation from [userId] (never from user input) and are what
/// `ProfileRepository` stores. Throws only `Failure` subtypes.
abstract interface class MediaRepository {
  /// Uploads a compressed JPEG profile photo for [userId] (the signed-in
  /// user) under a new file name and returns its path.
  /// Throws `NotFoundFailure` (not the signed-in user / refused),
  /// `ValidationFailure(fileTooLarge | fileTypeNotAllowed)`, `NetworkFailure`,
  /// `UnexpectedFailure`.
  Future<String> uploadAvatar(String userId, Uint8List jpegBytes);

  /// Uploads a PDF certificate for [userId] (a teacher) and returns its
  /// path; the original [fileName] stays readable in the path.
  /// Throws as [uploadAvatar].
  Future<String> uploadCertificate(
    String userId,
    Uint8List pdfBytes,
    String fileName,
  );

  /// Uploads a compressed JPEG chat photo of [userId] (the signed-in user)
  /// for [conversationId] and returns its path
  /// (`<user-id>/<conversation-id>_<random>.jpg`). Throws as [uploadAvatar].
  Future<String> uploadChatImage(
    String userId,
    String conversationId,
    Uint8List jpegBytes,
  );

  /// Uploads a compressed JPEG post photo of [userId] (the signed-in user)
  /// and returns its path (`<user-id>/post_<n>.jpg`). Throws as
  /// [uploadAvatar].
  Future<String> uploadPostImage(String userId, Uint8List jpegBytes);

  /// Downloads the signed-in user's own certificate at [path].
  /// Throws `NotFoundFailure` (missing or not allowed), `NetworkFailure`,
  /// `UnexpectedFailure`.
  Future<Uint8List> downloadCertificate(String path);

  /// Removes [paths] from [bucket]; missing files are ignored.
  /// Throws `NetworkFailure`, `UnexpectedFailure`.
  Future<void> deleteFiles(MediaBucket bucket, List<String> paths);

  /// Removes every file of [userId] in every bucket (account deletion).
  /// Throws `NetworkFailure`, `UnexpectedFailure`.
  Future<void> deleteAllUserFiles(String userId);
}
