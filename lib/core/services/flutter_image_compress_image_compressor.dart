import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../errors/failures.dart';
import 'image_compressor.dart';

/// [ImageCompressor] on `flutter_image_compress` (plan section 13: avatars
/// about 60 KB; post and chat photos about 200 KB).
class FlutterImageCompressImageCompressor implements ImageCompressor {
  const FlutterImageCompressImageCompressor();

  static const int avatarSide = 512;
  static const int avatarQuality = 80;

  /// Photos keep up to this many pixels per side (aspect ratio kept).
  static const int photoSide = 1280;
  static const int photoQuality = 75;

  @override
  Future<Uint8List> compressAvatar(Uint8List bytes) =>
      _compress(bytes, side: avatarSide, quality: avatarQuality);

  @override
  Future<Uint8List> compressPhoto(Uint8List bytes) =>
      _compress(bytes, side: photoSide, quality: photoQuality);

  Future<Uint8List> _compress(
    Uint8List bytes, {
    required int side,
    required int quality,
  }) async {
    try {
      final result = await FlutterImageCompress.compressWithList(
        bytes,
        minWidth: side,
        minHeight: side,
        quality: quality,
      );
      if (result.isEmpty) {
        throw const UnexpectedFailure();
      }
      return result;
    } catch (_) {
      throw const UnexpectedFailure();
    }
  }
}
