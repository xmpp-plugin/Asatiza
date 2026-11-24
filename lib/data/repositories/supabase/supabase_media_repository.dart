import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/failures.dart';
import '../../../core/logic/certificate_file_rules.dart';
import '../../models/enums/media_bucket.dart';
import '../media_repository.dart';
import 'supabase_failure_mapper.dart';

/// [MediaRepository] on Supabase Storage (migration
/// `20261124120000_storage_avatars_certificates.sql`): every user writes only
/// inside their own `<user-id>/` folder; `avatars` is public read,
/// `certificates` is readable by its owner only (no public or signed URL).
class SupabaseMediaRepository implements MediaRepository {
  SupabaseMediaRepository(
    this._client, {
    SupabaseFailureMapper failures = const SupabaseFailureMapper(),
    CertificateFileRules rules = const CertificateFileRules(),
    DateTime Function() now = DateTime.now,
  }) : _failures = failures,
       _rules = rules,
       _now = now;

  final SupabaseClient _client;
  final SupabaseFailureMapper _failures;
  final CertificateFileRules _rules;
  final DateTime Function() _now;

  Future<T> _guard<T>(Future<T> Function() run) async {
    try {
      return await run();
    } catch (error) {
      throw _failures.map(error);
    }
  }

  StorageFileApi _bucket(MediaBucket bucket) => _client.storage.from(bucket.id);

  void _checkOwner(String userId) {
    if (userId.isEmpty || _client.auth.currentUser?.id != userId) {
      throw const NotFoundFailure();
    }
  }

  @override
  Future<String> uploadAvatar(String userId, Uint8List jpegBytes) =>
      _guard(() async {
        _checkOwner(userId);
        final path = '$userId/avatar-${_now().millisecondsSinceEpoch}.jpg';
        await _bucket(MediaBucket.avatars).uploadBinary(
          path,
          jpegBytes,
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );
        return path;
      });

  @override
  Future<String> uploadCertificate(
    String userId,
    Uint8List pdfBytes,
    String fileName,
  ) => _guard(() async {
    _checkOwner(userId);
    final path = '$userId/${_rules.objectName(fileName, _now())}';
    await _bucket(MediaBucket.certificates).uploadBinary(
      path,
      pdfBytes,
      fileOptions: const FileOptions(contentType: 'application/pdf'),
    );
    return path;
  });

  @override
  Future<Uint8List> downloadCertificate(String path) =>
      _guard(() => _bucket(MediaBucket.certificates).download(path));

  @override
  Future<void> deleteFiles(MediaBucket bucket, List<String> paths) =>
      _guard(() async {
        final targets = paths.where((p) => p.trim().isNotEmpty).toList();
        if (targets.isEmpty) {
          return;
        }
        await _bucket(bucket).remove(targets);
      });

  @override
  Future<void> deleteAllUserFiles(String userId) => _guard(() async {
    _checkOwner(userId);
    for (final bucket in MediaBucket.values) {
      final api = _bucket(bucket);
      final files = await api.list(path: userId);
      final paths = <String>[
        for (final file in files)
          if (file.name.isNotEmpty) '$userId/${file.name}',
      ];
      if (paths.isNotEmpty) {
        await api.remove(paths);
      }
    }
  });
}
