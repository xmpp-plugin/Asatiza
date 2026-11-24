import 'dart:typed_data';

import '../errors/failures.dart';

/// Rules for teacher certificates (PHASE_005, decisions 2 and 10): PDF only,
/// at most [maxBytes], at most [maxCertificates] per teacher, and the
/// Storage object name that keeps the original file name readable.
///
/// Pure Dart; used by teacher setup, Edit profile and the media repository.
class CertificateFileRules {
  const CertificateFileRules();

  /// 3 MB (decision 2). The `certificates` bucket enforces the same limit.
  static const int maxBytes = 3 * 1024 * 1024;

  /// One certificate in v1 (limited free Storage); more in v2 or later.
  static const int maxCertificates = 1;

  /// Longest kept file name part (without the timestamp prefix).
  static const int maxNameLength = 60;

  /// PDF files start with `%PDF-` (allowed within the first 1024 bytes).
  static const List<int> _pdfMagic = <int>[0x25, 0x50, 0x44, 0x46, 0x2D];

  /// Whether a teacher with [existingCount] certificates may add another.
  bool canAdd(int existingCount) => existingCount < maxCertificates;

  /// The reason a picked file is refused, or null when it is acceptable.
  /// [bytes] may be empty when the file was too large to read.
  ValidationReason? check({
    required int sizeBytes,
    required Uint8List bytes,
    required int existingCount,
  }) {
    if (!canAdd(existingCount)) {
      return ValidationReason.certificateLimitReached;
    }
    if (sizeBytes > maxBytes || bytes.length > maxBytes) {
      return ValidationReason.fileTooLarge;
    }
    if (!isPdf(bytes)) {
      return ValidationReason.fileTypeNotAllowed;
    }
    return null;
  }

  /// True when [bytes] carry the PDF signature near the start.
  bool isPdf(Uint8List bytes) {
    final end = bytes.length < 1024 ? bytes.length : 1024;
    for (var i = 0; i + _pdfMagic.length <= end; i++) {
      var match = true;
      for (var j = 0; j < _pdfMagic.length; j++) {
        if (bytes[i + j] != _pdfMagic[j]) {
          match = false;
          break;
        }
      }
      if (match) {
        return true;
      }
    }
    return false;
  }

  /// `report card.PDF` → `report-card.pdf`: lower case, only `a-z 0-9 . _ -`,
  /// at most [maxNameLength] characters, always ending in `.pdf`.
  String safeFileName(String name) {
    var base = name.trim().toLowerCase();
    if (base.endsWith('.pdf')) {
      base = base.substring(0, base.length - 4);
    }
    base = base
        .replaceAll(RegExp(r'[^a-z0-9._-]+'), '-')
        .replaceAll(RegExp(r'-{2,}'), '-')
        .replaceAll(RegExp(r'^[-._]+|[-._]+$'), '');
    if (base.isEmpty) {
      base = 'certificate';
    }
    const ext = '.pdf';
    if (base.length > maxNameLength - ext.length) {
      base = base.substring(0, maxNameLength - ext.length);
    }
    return '$base$ext';
  }

  /// Object name inside the user's folder: `<millis>-<safe name>.pdf`.
  String objectName(String fileName, DateTime now) =>
      '${now.millisecondsSinceEpoch}-${safeFileName(fileName)}';

  /// The file name shown to the user for a stored [path]: the last segment
  /// without the timestamp prefix (older paths are shown as they are).
  String displayName(String path) {
    final last = path.split('/').last;
    final match = RegExp(r'^\d{10,}-(.+)$').firstMatch(last);
    return match?.group(1) ?? last;
  }
}
