import '../../../data/models/post.dart';

/// Feed order (plan section 9): posts from the viewer's connections first,
/// newest first, then everyone else's posts, newest first.
class FeedOrdering {
  const FeedOrdering();

  List<Post> order(Iterable<Post> posts, Set<String> connectedAuthorIds) {
    int newestFirst(Post a, Post b) => b.createdAt.compareTo(a.createdAt);
    final fromConnections =
        posts.where((p) => connectedAuthorIds.contains(p.authorId)).toList()
          ..sort(newestFirst);
    final others =
        posts.where((p) => !connectedAuthorIds.contains(p.authorId)).toList()
          ..sort(newestFirst);
    return <Post>[...fromConnections, ...others];
  }
}
