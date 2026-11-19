import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/failures.dart';
import '../../../data/models/enums/post_tag.dart';
import '../../../data/repositories/feed_repository.dart';
import 'create_post_state.dart';

/// New post: text (max 1,500), one optional photo, one required tag.
class CreatePostCubit extends Cubit<CreatePostState> {
  CreatePostCubit(this._feed, {required this.authorId})
    : super(const CreatePostState());

  final FeedRepository _feed;
  final String authorId;

  /// UI-only phase: "Photo" attaches this bundled sample image instead of
  /// opening the gallery.
  static const String sampleAttachment = 'assets/illustrations/post_photo.svg';

  void bodyChanged(String value) =>
      emit(state.copyWith(body: value, clearFailure: true));
  void tagSelected(PostTag tag) =>
      emit(state.copyWith(tag: tag, clearFailure: true));
  void photoAdded() => emit(state.copyWith(hasPhoto: true));
  void photoRemoved() => emit(state.copyWith(hasPhoto: false));

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
        imagePath: state.hasPhoto ? sampleAttachment : null,
      );
      emit(state.copyWith(status: CreatePostStatus.posted));
    } on ValidationFailure catch (f) {
      emit(state.copyWith(status: CreatePostStatus.editing, failure: f.reason));
    } on Failure {
      emit(state.copyWith(status: CreatePostStatus.editing));
    }
  }
}
