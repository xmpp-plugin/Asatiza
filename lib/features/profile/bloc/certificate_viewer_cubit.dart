import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/failures.dart';
import '../../../data/repositories/media_repository.dart';
import 'certificate_viewer_state.dart';

/// Downloads the signed-in teacher's certificate at [path] for the viewer;
/// [retry] tries again after a failure.
class CertificateViewerCubit extends Cubit<CertificateViewerState> {
  CertificateViewerCubit(this._media, this.path)
    : super(const CertificateViewerState());

  final MediaRepository _media;

  /// Storage path inside the `certificates` bucket.
  final String path;

  Future<void> load() async {
    emit(const CertificateViewerState());
    try {
      final bytes = await _media.downloadCertificate(path);
      if (!isClosed) {
        emit(
          CertificateViewerState(
            status: CertificateViewerStatus.loaded,
            bytes: bytes,
          ),
        );
      }
    } on Failure {
      if (!isClosed) {
        emit(
          const CertificateViewerState(status: CertificateViewerStatus.failure),
        );
      }
    }
  }

  Future<void> retry() => load();
}
