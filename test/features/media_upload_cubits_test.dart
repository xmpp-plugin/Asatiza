import 'package:asatiza/core/errors/failures.dart';
import 'package:asatiza/core/services/image_source_kind.dart';
import 'package:asatiza/data/mock/mock_profiles.dart';
import 'package:asatiza/data/models/enums/media_bucket.dart';
import 'package:asatiza/data/models/picked_document.dart';
import 'package:asatiza/data/models/teacher_details.dart';
import '../fakes/mock_media_repository.dart';
import '../fakes/mock_profile_repository.dart';
import 'package:asatiza/features/profile/bloc/certificate_viewer_cubit.dart';
import 'package:asatiza/features/profile/bloc/certificate_viewer_state.dart';
import 'package:asatiza/features/profile/bloc/edit_profile_cubit.dart';
import 'package:asatiza/features/profile_setup/bloc/teacher_setup_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

/// PHASE_005: photo and certificate uploads in the setup / edit cubits and
/// the certificate viewer, on the mock media repository and fake services.
void main() {
  late MockProfileRepository profiles;
  late MockMediaRepository media;
  late FakeImagePicker picker;
  late FakeDocumentPicker documents;

  setUp(() {
    profiles = MockProfileRepository();
    media = MockMediaRepository();
    picker = FakeImagePicker();
    documents = FakeDocumentPicker();
  });

  Future<EditProfileCubit> editTeacher({bool withoutCertificate = true}) async {
    var ahmed = await profiles.getProfile(MockIds.ahmed);
    if (withoutCertificate) {
      ahmed = await profiles.updateProfile(
        ahmed.copyWith(
          teacherDetails: ahmed.teacherDetails!.copyWith(
            certificatePaths: const <String>[],
          ),
        ),
      );
    }
    return EditProfileCubit(
      profiles,
      ahmed,
      media: media,
      picker: picker,
      compressor: const FakeImageCompressor(),
      documents: documents,
    );
  }

  group('photo', () {
    test('cancelled pick changes nothing', () async {
      picker.next = null;
      final cubit = await editTeacher();
      final before = cubit.state.draft.photoPath;
      await cubit.photoPicked(ImageSourceKind.camera);
      expect(picker.lastSource, ImageSourceKind.camera);
      expect(cubit.state.draft.photoPath, before);
      expect(cubit.state.uploadingPhoto, isFalse);
      expect(media.paths(MediaBucket.avatars), isEmpty);
      await cubit.close();
    });

    test(
      'upload: compressed photo stored, path in draft, preview set',
      () async {
        final cubit = await editTeacher();
        await cubit.photoPicked(ImageSourceKind.gallery);
        final path = cubit.state.draft.photoPath!;
        expect(path, startsWith('${MockIds.ahmed}/avatar-'));
        expect(media.contains(MediaBucket.avatars, path), isTrue);
        expect(cubit.state.photoPreview!.first, 0xFF); // compressed (JPEG)
        await cubit.close();
      },
    );

    test('network error: message, draft unchanged', () async {
      final cubit = await editTeacher();
      final before = cubit.state.draft.photoPath;
      media.failNext = const NetworkFailure();
      await cubit.photoPicked(ImageSourceKind.gallery);
      expect(cubit.state.mediaError, ValidationReason.network);
      expect(cubit.state.uploadingPhoto, isFalse);
      expect(cubit.state.draft.photoPath, before);
      await cubit.close();
    });

    test('replace + save deletes the old file; leaving unsaved deletes '
        'the new upload', () async {
      final cubit = await editTeacher();
      await cubit.photoPicked(ImageSourceKind.gallery);
      final first = cubit.state.draft.photoPath!;
      await cubit.save();
      expect(cubit.state.saved, isTrue);
      await cubit.close();

      // Second session: replace the saved photo, save → old one removed.
      final again = await editTeacher(withoutCertificate: false);
      await again.photoPicked(ImageSourceKind.gallery);
      final second = again.state.draft.photoPath!;
      await again.save();
      expect(media.deleted, contains('avatars/$first'));
      expect(media.contains(MediaBucket.avatars, second), isTrue);
      await again.close();

      // Third session: upload, then leave without saving → removed.
      final third = await editTeacher(withoutCertificate: false);
      await third.photoPicked(ImageSourceKind.gallery);
      final unsaved = third.state.draft.photoPath!;
      await third.close();
      await Future<void>.delayed(Duration.zero);
      expect(media.contains(MediaBucket.avatars, unsaved), isFalse);
      expect(media.contains(MediaBucket.avatars, second), isTrue);
    });
  });

  group('certificate', () {
    test('PDF uploads with its name; a second one is refused', () async {
      documents.next = PickedDocument(
        name: 'Ijazah Hafs.pdf',
        sizeBytes: 64,
        bytes: samplePdf(),
      );
      final cubit = await editTeacher();
      await cubit.certificatePicked();
      final paths = cubit.state.draft.teacherDetails!.certificatePaths;
      expect(paths, hasLength(1));
      expect(paths.single, contains('ijazah-hafs.pdf'));
      expect(media.contains(MediaBucket.certificates, paths.single), isTrue);

      await cubit.certificatePicked();
      expect(cubit.state.mediaError, ValidationReason.certificateLimitReached);
      expect(cubit.state.draft.teacherDetails!.certificatePaths, hasLength(1));
      await cubit.close();
    });

    test('over 3 MB is refused before upload', () async {
      documents.next = PickedDocument(
        name: 'big.pdf',
        sizeBytes: 4 * 1024 * 1024,
        bytes: samplePdf(),
      );
      final cubit = await editTeacher();
      await cubit.certificatePicked();
      expect(cubit.state.mediaError, ValidationReason.fileTooLarge);
      expect(media.paths(MediaBucket.certificates), isEmpty);
      await cubit.close();
    });

    test('a non-PDF file is refused', () async {
      documents.next = PickedDocument(
        name: 'photo.pdf',
        sizeBytes: 3,
        bytes: samplePdf().sublist(5, 8),
      );
      final cubit = await editTeacher();
      await cubit.certificatePicked();
      expect(cubit.state.mediaError, ValidationReason.fileTypeNotAllowed);
      expect(media.paths(MediaBucket.certificates), isEmpty);
      await cubit.close();
    });

    test('remove + save deletes the file', () async {
      documents.next = PickedDocument(
        name: 'sanad.pdf',
        sizeBytes: 64,
        bytes: samplePdf(),
      );
      final cubit = await editTeacher();
      await cubit.certificatePicked();
      final path = cubit.state.draft.teacherDetails!.certificatePaths.single;
      await cubit.save();
      await cubit.close();

      final again = await editTeacher(withoutCertificate: false);
      again.certificateRemoved(path);
      await again.save();
      expect(media.deleted, contains('certificates/$path'));
      expect(
        (await profiles.getProfile(
          MockIds.ahmed,
        )).teacherDetails!.certificatePaths,
        isEmpty,
      );
      await again.close();
    });

    test('teacher setup: upload, remove, upload again', () async {
      final ahmed = await profiles.getProfile(MockIds.ahmed);
      final cubit = TeacherSetupCubit(
        profiles,
        ahmed.copyWith(teacherDetails: const TeacherDetails()),
        media: media,
        picker: picker,
        compressor: const FakeImageCompressor(),
        documents: documents,
      );
      documents.next = PickedDocument(
        name: 'a.pdf',
        sizeBytes: 64,
        bytes: samplePdf(),
      );
      await cubit.certificatePicked();
      final first = cubit.state.details.certificatePaths.single;
      cubit.certificateRemoved(first);
      expect(cubit.state.details.certificatePaths, isEmpty);
      await cubit.certificatePicked();
      expect(cubit.state.details.certificatePaths, hasLength(1));
      await cubit.close();
    });
  });

  group('viewer', () {
    test('loading → loaded; failure → retry → loaded', () async {
      final path = await media.uploadCertificate(
        MockIds.ahmed,
        samplePdf(),
        'x.pdf',
      );
      final cubit = CertificateViewerCubit(media, path);
      media.failNext = const NetworkFailure();
      await cubit.load();
      expect(cubit.state.status, CertificateViewerStatus.failure);
      await cubit.retry();
      expect(cubit.state.status, CertificateViewerStatus.loaded);
      expect(cubit.state.bytes, samplePdf());
      await cubit.close();
    });

    test('a missing file fails', () async {
      final cubit = CertificateViewerCubit(media, 'nobody/none.pdf');
      await cubit.load();
      expect(cubit.state.status, CertificateViewerStatus.failure);
      await cubit.close();
    });
  });
}
