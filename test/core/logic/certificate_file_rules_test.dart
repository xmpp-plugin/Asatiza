import 'dart:typed_data';

import 'package:asatiza/core/errors/failures.dart';
import 'package:asatiza/core/logic/certificate_file_rules.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_app.dart';

void main() {
  const rules = CertificateFileRules();

  group('CertificateFileRules', () {
    test('limits: 3 MB and one certificate (decision 2)', () {
      expect(CertificateFileRules.maxBytes, 3 * 1024 * 1024);
      expect(CertificateFileRules.maxCertificates, 1);
      expect(rules.canAdd(0), isTrue);
      expect(rules.canAdd(1), isFalse);
    });

    test('a small PDF is accepted', () {
      final pdf = samplePdf();
      expect(
        rules.check(sizeBytes: pdf.length, bytes: pdf, existingCount: 0),
        isNull,
      );
    });

    test('a second certificate is refused', () {
      final pdf = samplePdf();
      expect(
        rules.check(sizeBytes: pdf.length, bytes: pdf, existingCount: 1),
        ValidationReason.certificateLimitReached,
      );
    });

    test('over 3 MB is refused, also when the bytes were not read', () {
      expect(
        rules.check(
          sizeBytes: CertificateFileRules.maxBytes + 1,
          bytes: Uint8List(0),
          existingCount: 0,
        ),
        ValidationReason.fileTooLarge,
      );
    });

    test('a renamed non-PDF file is refused', () {
      final jpeg = Uint8List.fromList(<int>[0xFF, 0xD8, 0xFF, 0xE0, 1, 2, 3]);
      expect(
        rules.check(sizeBytes: jpeg.length, bytes: jpeg, existingCount: 0),
        ValidationReason.fileTypeNotAllowed,
      );
    });

    test('the PDF signature may follow a few leading bytes', () {
      final bytes = Uint8List.fromList(<int>[0x0A, 0x0D, ...samplePdf()]);
      expect(rules.isPdf(bytes), isTrue);
    });

    test('safe file names', () {
      expect(rules.safeFileName('My Ijazah (2019).PDF'), 'my-ijazah-2019.pdf');
      expect(rules.safeFileName('شهادة.pdf'), 'certificate.pdf');
      expect(rules.safeFileName('a' * 100).length, 60);
      expect(rules.safeFileName('a' * 100), endsWith('.pdf'));
    });

    test('object name and display name round trip', () {
      final name = rules.objectName(
        'Tajweed Sanad.pdf',
        DateTime.fromMillisecondsSinceEpoch(1764000000000),
      );
      expect(name, '1764000000000-tajweed-sanad.pdf');
      expect(rules.displayName('user-1/$name'), 'tajweed-sanad.pdf');
      // Older placeholder paths show as they are.
      expect(
        rules.displayName('certificates/abc/certificate-1.pdf'),
        'certificate-1.pdf',
      );
    });
  });
}
