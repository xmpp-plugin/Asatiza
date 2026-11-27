import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/failures.dart';
import '../../../core/services/image_compressor.dart';
import '../../../core/services/image_picker_service.dart';
import '../../../core/services/image_source_kind.dart';
import '../../../data/models/enums/media_bucket.dart';
import '../../../data/models/enums/post_tag.dart';
import '../../../data/repositories/feed_repository.dart';
import '../../../data/repositories/media_repository.dart';
import 'create_post_state.dart';

/// New post: text (max 1,500), one optional photo (picked, compressed with
/// `ImageCompressor.compressPhoto`, uploaded to `post-images`), one required
/// tag. A photo that is not posted is removed again.
class CreatePostCubit extends Cubit<CreatePostState> {
  CreatePostCubit(
    this._feed, {
    required this.authorId,
    required MediaRepository media,
    required ImagePickerService picker,
    required ImageCompressor compressor,
  }) : _media = media,
       _picker = picker,
       _compressor = compressor,
       super(const CreatePostState());

  final FeedRepository _feed;
  final MediaRepository _media;
  final ImagePickerService _picker;
  final ImageCompressor _compressor;
  final String authorId;

  void bodyChanged(String value) =>
      emit(state.copyWith(body: value, clearFailure: true));
  void tagSelected(PostTag tag) =>
      emit(state.copyWith(tag: tag, clearFailure: true));

  /// Takes or chooses a photo, compresses and uploads it.
  Future<void> photoPicked(ImageSourceKind source) async {
    if (state.uploadingPhoto) {
      return;
    }
    try {
      final picked = await _picker.pickImage(source);
      if (picked == null || isClosed) {
        return;
      }
      emit(state.copyWith(uploadingPhoto: true, clearFailure: true));
      final jpeg = await _compressor.compressPhoto(picked);
      final path = await _media.uploadPostImage(authorId, jpeg);
      if (isClosed) {
        unawaited(_deleteQuietly(path));
        return;
      }
      final previous = state.photoPath;
      emit(
        state.copyWith(
          photoPath: () => path,
          photoPreview: () => jpeg,
          uploadingPhoto: false,
        ),
      );
      if (previous != null) {
        unawaited(_deleteQuietly(previous));
      }
    } on Failure catch (f) {
      if (!isClosed) {
        emit(state.copyWith(uploadingPhoto: false, failure: f.displayReason));
      }
    }
  }

  void photoRemoved() {
    final path = state.photoPath;
    emit(state.copyWith(photoPath: () => null, photoPreview: () => null));
    if (path != null) {
      unawaited(_deleteQuietly(path));
    }
  }

  Future<void> _deleteQuietly(String path) async {
    try {
      await _media.deleteFiles(MediaBucket.postImages, <String>[path]);
    } on Failure {
      // Left as an orphan in Storage (recorded limitation).
    }
  }

  Future<void> submit() async {
    if (!state.canPost) {
      return;
    }
    emit(state.copyWith(status: CreatePostStatus.posting, clearFailure: true));
    try {
      await _feed.createPost(
        authorId: authorId,
        body: state.body,
        tag: state.tag,
        imagePath: state.photoPath,
      );
      emit(state.copyWith(status: CreatePostStatus.posted));
    } on ValidationFailure catch (f) {
      emit(state.copyWith(status: CreatePostStatus.editing, failure: f.reason));
    } on Failure catch (f) {
      emit(
        state.copyWith(
          status: CreatePostStatus.editing,
          failure: f.displayReason,
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    final path = state.photoPath;
    if (path != null && state.status != CreatePostStatus.posted) {
      unawaited(_deleteQuietly(path));
    }
    return super.close();
  }
}
