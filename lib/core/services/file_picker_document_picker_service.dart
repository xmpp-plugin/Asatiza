import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

import '../../data/models/picked_document.dart';
import '../errors/failures.dart';
import 'document_picker_service.dart';

/// [DocumentPickerService] on `file_picker`: the system document picker,
/// filtered to `.pdf` (no storage permission needed).
class FilePickerDocumentPickerService implements DocumentPickerService {
  const FilePickerDocumentPickerService();

  @override
  Future<PickedDocument?> pickPdf({required int maxReadBytes}) async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: const <String>['pdf'],
      );
      if (file == null) {
        return null;
      }
      final size = await file.length() ?? 0;
      final bytes = size > maxReadBytes
          ? Uint8List(0)
          : await file.readAsBytes();
      return PickedDocument(
        name: file.name,
        sizeBytes: size == 0 ? bytes.length : size,
        bytes: bytes,
      );
    } catch (_) {
      throw const UnexpectedFailure();
    }
  }
}
