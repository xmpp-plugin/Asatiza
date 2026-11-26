import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/failures.dart';
import '../../../data/models/enums/post_tag.dart';
import '../../../data/models/enums/subject.dart';
import '../../../data/models/post.dart';
import '../../../data/models/profile.dart';
import '../../../data/repositories/discover_repository.dart';
import '../../../data/repositories/feed_repository.dart';
import '../../../data/repositories/profile_repository.dart';
import '../logic/daily_shuffle.dart';
import '../logic/student_filter.dart';
import '../logic/teacher_filter.dart';
import 'search_state.dart';

/// Searches people (through the list filters) and posts (body and tag).
class SearchCubit extends Cubit<SearchState> {
  SearchCubit(
    this._discover,
    this._feed,
    this._profiles, {
    required this.viewerId,
    required this.showTeachers,
    required String Function(Subject) subjectLabel,
    required String Function(PostTag) tagLabel,
    DateTime? today,
  }) : _subjectLabel = subjectLabel,
       _tagLabel = tagLabel,
       _order = DailyShuffle(viewerId: viewerId, day: today ?? DateTime.now()),
       super(const SearchState()) {
    final people = showTeachers
        ? _discover.watchTeachers(viewerId: viewerId)
        : _discover.watchStudents(viewerId: viewerId);
    _peopleSub = people.listen((list) {
      _allPeople = _order.apply(list);
      _rebuild();
    }, onError: (Object _) {});
    _postsSub = _feed.watchPosts(viewerId: viewerId).listen((list) {
      _allPosts = list;
      _rebuild();
    }, onError: (Object _) {});
  }

  final DiscoverRepository _discover;
  final FeedRepository _feed;
  final ProfileRepository _profiles;
  final String viewerId;
  final bool showTeachers;
  final String Function(Subject) _subjectLabel;
  final String Function(PostTag) _tagLabel;
  final DailyShuffle _order;

  StreamSubscription<List<Profile>>? _peopleSub;
  StreamSubscription<List<Post>>? _postsSub;
  List<Profile> _allPeople = const <Profile>[];
  List<Post> _allPosts = const <Post>[];

  void queryChanged(String query) {
    emit(state.copyWith(query: query));
    _rebuild();
  }

  void tabChanged(SearchTab tab) => emit(state.copyWith(tab: tab));

  Future<void> _rebuild() async {
    final q = state.query.trim();
    if (q.isEmpty) {
      emit(state.copyWith(people: const <Profile>[], posts: const <Post>[]));
      return;
    }
    final people = showTeachers
        ? TeacherFilter(query: q).apply(_allPeople, _subjectLabel)
        : StudentFilter(query: q).apply(_allPeople, _subjectLabel);
    final lower = q.toLowerCase();
    final posts = _allPosts
        .where(
          (p) =>
              p.body.toLowerCase().contains(lower) ||
              _tagLabel(p.tag).toLowerCase().contains(lower),
        )
        .toList();
    final missing = posts
        .map((p) => p.authorId)
        .where((id) => !state.authors.containsKey(id));
    var authors = state.authors;
    if (missing.isNotEmpty) {
      final loaded = await _profiles.getProfiles(missing);
      authors = <String, Profile>{...authors, for (final p in loaded) p.id: p};
    }
    if (!isClosed && state.query.trim() == q) {
      emit(
        state.copyWith(
          people: people,
          posts: posts.where((p) => authors.containsKey(p.authorId)).toList(),
          authors: authors,
        ),
      );
    }
  }

  Future<void> toggleLike(String postId) async {
    try {
      await _feed.toggleLike(postId: postId, userId: viewerId);
    } on Failure {
      // The post disappeared; the stream already reflects it.
    }
  }

  @override
  Future<void> close() async {
    await _peopleSub?.cancel();
    await _postsSub?.cancel();
    return super.close();
  }
}
