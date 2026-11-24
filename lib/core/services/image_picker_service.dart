import 'dart:typed_data';

import 'image_source_kind.dart';

/// Lets the user take or choose a photo. Wraps `image_picker`.
abstract interface class ImagePickerService {
  /// The picked image's bytes, or null when the user cancelled.
  /// Throws `UnexpectedFailure` when the picker fails (e.g. no access).
  Future<Uint8List?> pickImage(ImageSourceKind source);
}
