import 'dart:typed_data';

import 'package:equatable/equatable.dart';

/// Loading the PDF, showing it, or the download failed.
enum CertificateViewerStatus { loading, loaded, failure }

/// The owner's certificate opened in the in-app viewer (PHASE_005,
/// decision 6).
class CertificateViewerState extends Equatable {
  const CertificateViewerState({
    this.status = CertificateViewerStatus.loading,
    this.bytes,
  });

  final CertificateViewerStatus status;

  /// The PDF, kept in memory only (never written to disk).
  final Uint8List? bytes;

  @override
  List<Object?> get props => <Object?>[status, bytes];
}
