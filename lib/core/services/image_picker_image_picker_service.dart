import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

import '../errors/failures.dart';
import 'image_picker_service.dart';
import 'image_source_kind.dart';

/// [ImagePickerService] on `image_picker`: the system photo picker / gallery
/// and the camera app. Large photos are scaled down to [maxSide] by the
/// picker before they reach Dart (the compressor then makes the avatar).
class ImagePickerImagePickerService implements ImagePickerService {
  ImagePickerImagePickerService([ImagePicker? picker])
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  static const double maxSide = 1600;

  @override
  Future<Uint8List?> pickImage(ImageSourceKind source) async {
    try {
      final file = await _picker.pickImage(
        source: switch (source) {
          ImageSourceKind.camera => ImageSource.camera,
          ImageSourceKind.gallery => ImageSource.gallery,
        },
        maxWidth: maxSide,
        maxHeight: maxSide,
        requestFullMetadata: false,
      );
      return file == null ? null : await file.readAsBytes();
    } catch (_) {
      throw const UnexpectedFailure();
    }
  }
}
