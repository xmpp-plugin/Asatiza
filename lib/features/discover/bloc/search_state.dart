import 'package:equatable/equatable.dart';

import '../../../data/models/post.dart';
import '../../../data/models/profile.dart';

enum SearchTab { all, people, posts }

/// Home search results (artboard 08b): All / Teachers (or Students) / Posts.
class SearchState extends Equatable {
  const SearchState({
    this.query = '',
    this.tab = SearchTab.all,
    this.people = const <Profile>[],
    this.posts = const <Post>[],
    this.authors = const <String, Profile>{},
  });

  final String query;
  final SearchTab tab;

  /// Matching teachers (student viewer) or students (teacher viewer).
  final List<Profile> people;
  final List<Post> posts;
  final Map<String, Profile> authors;

  bool get hasQuery => query.trim().isNotEmpty;
  bool get isEmpty => hasQuery && people.isEmpty && posts.isEmpty;

  SearchState copyWith({
    String? query,
    SearchTab? tab,
    List<Profile>? people,
    List<Post>? posts,
    Map<String, Profile>? authors,
  }) {
    return SearchState(
      query: query ?? this.query,
      tab: tab ?? this.tab,
      people: people ?? this.people,
      posts: posts ?? this.posts,
      authors: authors ?? this.authors,
    );
  }

  @override
  List<Object?> get props => <Object?>[query, tab, people, posts, authors];
}
