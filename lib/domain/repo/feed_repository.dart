import 'package:feed_app/data/models/post_model.dart';

abstract class FeedRepository {
  Future<List<Post>> fetchPosts({int start, int limit});
  Future<void> cachePosts(List<Post> posts);
  Future<List<Post>> getCachedPosts();
}
