import 'dart:typed_data';

import 'package:asatiza/core/errors/failures.dart';
import 'package:asatiza/core/logic/certificate_file_rules.dart';
import 'package:asatiza/data/models/enums/media_bucket.dart';
import 'package:asatiza/data/repositories/media_repository.dart';

/// In-memory [MediaRepository] for tests: files live in a map keyed by
/// `<bucket>/<path>`. [failNext] makes the next call throw that failure.
// Test-only fake: the app uses the Supabase implementation (moved from
// `lib/` in PHASE_007).
class MockMediaRepository implements MediaRepository {
  MockMediaRepository({
    CertificateFileRules rules = const CertificateFileRules(),
    DateTime Function()? now,
  }) : _rules = rules,
       _now = now ?? _counter;

  final CertificateFileRules _rules;
  final DateTime Function() _now;

  static int _tick = 1700000000000;
  static DateTime _counter() => DateTime.fromMillisecondsSinceEpoch(_tick++);

  final Map<String, Uint8List> _files = <String, Uint8List>{};

  /// Mock helper: every removed path, in order (`<bucket>/<path>`).
  final List<String> deleted = <String>[];

  /// Mock helper: throw this failure on the next call.
  Failure? failNext;

  /// Mock helper: whether a file is stored.
  bool contains(MediaBucket bucket, String path) =>
      _files.containsKey('${bucket.id}/$path');

  /// Mock helper: stored paths of a bucket.
  Iterable<String> paths(MediaBucket bucket) => _files.keys
      .where((k) => k.startsWith('${bucket.id}/'))
      .map((k) => k.substring(bucket.id.length + 1));

  void _maybeFail() {
    final failure = failNext;
    if (failure != null) {
      failNext = null;
      throw failure;
    }
  }

  @override
  Future<String> uploadAvatar(String userId, Uint8List jpegBytes) async {
    _maybeFail();
    final path = '$userId/avatar-${_now().millisecondsSinceEpoch}.jpg';
    _files['${MediaBucket.avatars.id}/$path'] = jpegBytes;
    return path;
  }

  @override
  Future<String> uploadChatImage(
    String userId,
    String conversationId,
    Uint8List jpegBytes,
  ) async {
    _maybeFail();
    final path =
        '$userId/${conversationId}_${_now().microsecondsSinceEpoch}.jpg';
    _files['${MediaBucket.chatImages.id}/$path'] = jpegBytes;
    return path;
  }

  @override
  Future<String> uploadCertificate(
    String userId,
    Uint8List pdfBytes,
    String fileName,
  ) async {
    _maybeFail();
    if (pdfBytes.length > CertificateFileRules.maxBytes) {
      throw const ValidationFailure(ValidationReason.fileTooLarge);
    }
    final path = '$userId/${_rules.objectName(fileName, _now())}';
    _files['${MediaBucket.certificates.id}/$path'] = pdfBytes;
    return path;
  }

  @override
  Future<Uint8List> downloadCertificate(String path) async {
    _maybeFail();
    final bytes = _files['${MediaBucket.certificates.id}/$path'];
    if (bytes == null) {
      throw const NotFoundFailure();
    }
    return bytes;
  }

  @override
  Future<void> deleteFiles(MediaBucket bucket, List<String> paths) async {
    _maybeFail();
    for (final path in paths) {
      _files.remove('${bucket.id}/$path');
      deleted.add('${bucket.id}/$path');
    }
  }

  @override
  Future<void> deleteAllUserFiles(String userId) async {
    _maybeFail();
    for (final bucket in MediaBucket.values) {
      final mine = paths(
        bucket,
      ).where((p) => p.startsWith('$userId/')).toList();
      await deleteFiles(bucket, mine);
    }
  }
}
