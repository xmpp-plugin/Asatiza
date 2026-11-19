import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../../data/models/enums/post_tag.dart';
import '../logic/post_rules.dart';

enum CreatePostStatus { editing, posting, posted }

class CreatePostState extends Equatable {
  const CreatePostState({
    this.body = '',
    this.tag,
    this.hasPhoto = false,
    this.status = CreatePostStatus.editing,
    this.failure,
  });

  final String body;
  final PostTag? tag;
  final bool hasPhoto;
  final CreatePostStatus status;
  final ValidationReason? failure;

  static const PostRules _rules = PostRules();

  int get length => body.trim().length;
  bool get canPost =>
      _rules.canPublish(body: body, tag: tag) &&
      status != CreatePostStatus.posting;

  CreatePostState copyWith({
    String? body,
    PostTag? tag,
    bool? hasPhoto,
    CreatePostStatus? status,
    ValidationReason? failure,
    bool clearFailure = false,
  }) {
    return CreatePostState(
      body: body ?? this.body,
      tag: tag ?? this.tag,
      hasPhoto: hasPhoto ?? this.hasPhoto,
      status: status ?? this.status,
      failure: clearFailure ? null : failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props => <Object?>[body, tag, hasPhoto, status, failure];
}
