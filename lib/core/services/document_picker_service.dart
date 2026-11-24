import '../../data/models/picked_document.dart';

/// Lets the user choose a document from the device. Wraps `file_picker`.
abstract interface class DocumentPickerService {
  /// A PDF chosen by the user, or null when cancelled. Files larger than
  /// [maxReadBytes] are not read: their [PickedDocument.bytes] are empty
  /// and [PickedDocument.sizeBytes] tells the caller why.
  /// Throws `UnexpectedFailure` when the picker fails.
  Future<PickedDocument?> pickPdf({required int maxReadBytes});
}
