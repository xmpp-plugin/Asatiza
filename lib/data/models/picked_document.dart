import 'dart:typed_data';

import 'package:equatable/equatable.dart';

/// A file the user picked with the document picker.
class PickedDocument extends Equatable {
  const PickedDocument({
    required this.name,
    required this.sizeBytes,
    required this.bytes,
  });

  /// Original file name, e.g. `ijazah.pdf`.
  final String name;

  /// Size reported by the system picker.
  final int sizeBytes;

  /// File content; empty when the file was larger than the picker was asked
  /// to read (the caller then refuses it as too large).
  final Uint8List bytes;

  @override
  List<Object?> get props => <Object?>[name, sizeBytes, bytes.length];
}
