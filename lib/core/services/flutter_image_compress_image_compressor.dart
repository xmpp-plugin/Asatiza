import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../errors/failures.dart';
import 'image_compressor.dart';

/// [ImageCompressor] on `flutter_image_compress` (plan section 13: avatars
/// about 60 KB).
class FlutterImageCompressImageCompressor implements ImageCompressor {
  const FlutterImageCompressImageCompressor();

  static const int avatarSide = 512;
  static const int avatarQuality = 80;

  @override
  Future<Uint8List> compressAvatar(Uint8List bytes) async {
    try {
      final result = await FlutterImageCompress.compressWithList(
        bytes,
        minWidth: avatarSide,
        minHeight: avatarSide,
        quality: avatarQuality,
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
