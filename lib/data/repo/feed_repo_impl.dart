import 'package:feed_app/data/models/post_model.dart';
import 'package:feed_app/data/sources/local_data_source.dart';
import 'package:feed_app/data/sources/remote_data_sources.dart';
import 'package:feed_app/domain/repo/feed_repository.dart';

class FeedRepositoryImpl implements FeedRepository {
  final RemoteDataSource remote;
  final LocalDataSource local;

  FeedRepositoryImpl({
    required this.remote,
    required this.local,
  });
  @override
  Future<List<Post>> getFavoritePosts() async {
    // If you have a local DB
    final allPosts = await local.getCachedPosts();
    return allPosts.where((post) => post.isFavorite).toList();
  }

  @override
  Future<List<Post>> fetchPosts({int start = 0, int limit = 10}) async {
    try {
      // Always fetch fresh data from remote
      final posts = await remote.fetchPosts(start: start, limit: limit);

      // Cache posts locally
      await local.cachePosts(posts);

      return posts;
    } catch (_) {
      // If remote fails, try offline cache
      final cached = await local.getCachedPosts();
      if (cached.isNotEmpty) {
        return cached;
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<void> cachePosts(List<Post> posts) async {
    await local.cachePosts(posts);
  }

  @override
  Future<List<Post>> getCachedPosts() async {
    return await local.getCachedPosts();
  }
}
