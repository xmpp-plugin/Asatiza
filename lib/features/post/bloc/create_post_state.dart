import 'dart:typed_data';

import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../../data/models/enums/post_tag.dart';
import '../logic/post_rules.dart';

enum CreatePostStatus { editing, posting, posted }

class CreatePostState extends Equatable {
  const CreatePostState({
    this.body = '',
    this.tag,
    this.photoPath,
    this.photoPreview,
    this.uploadingPhoto = false,
    this.status = CreatePostStatus.editing,
    this.failure,
  });

  final String body;
  final PostTag? tag;

  /// Uploaded `post-images` path of the attached photo (PHASE_010).
  final String? photoPath;

  /// The compressed photo, shown before posting.
  final Uint8List? photoPreview;

  /// A photo is being compressed and uploaded.
  final bool uploadingPhoto;
  final CreatePostStatus status;
  final ValidationReason? failure;

  static const PostRules _rules = PostRules();

  bool get hasPhoto => photoPath != null;
  int get length => body.trim().length;
  bool get canPost =>
      _rules.canPublish(body: body, tag: tag) &&
      status != CreatePostStatus.posting &&
      !uploadingPhoto;

  CreatePostState copyWith({
    String? body,
    PostTag? tag,
    String? Function()? photoPath,
    Uint8List? Function()? photoPreview,
    bool? uploadingPhoto,
    CreatePostStatus? status,
    ValidationReason? failure,
    bool clearFailure = false,
  }) {
    return CreatePostState(
      body: body ?? this.body,
      tag: tag ?? this.tag,
      photoPath: photoPath != null ? photoPath() : this.photoPath,
      photoPreview: photoPreview != null ? photoPreview() : this.photoPreview,
      uploadingPhoto: uploadingPhoto ?? this.uploadingPhoto,
      status: status ?? this.status,
      failure: clearFailure ? null : failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    body,
    tag,
    photoPath,
    photoPreview,
    uploadingPhoto,
    status,
    failure,
  ];
}
