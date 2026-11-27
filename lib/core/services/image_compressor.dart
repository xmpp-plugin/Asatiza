import 'dart:typed_data';

/// Shrinks images before upload. Wraps `flutter_image_compress`.
abstract interface class ImageCompressor {
  /// A JPEG avatar (about 512 px on the shorter side, ≈ 60 KB) from any
  /// picked image; orientation is applied and metadata removed.
  /// Throws `UnexpectedFailure` when the image cannot be read.
  Future<Uint8List> compressAvatar(Uint8List bytes);

  /// A JPEG photo for posts and chat (about 1280 px on each side at most,
  /// about 200 KB, plan section 9). Throws as [compressAvatar].
  Future<Uint8List> compressPhoto(Uint8List bytes);
}
