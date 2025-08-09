import 'package:feed_app/data/models/comments_model.dart';
import 'package:feed_app/data/models/post_model.dart';
import 'package:feed_app/data/sources/local_data_source.dart';
import 'package:feed_app/data/sources/remote_data_sources.dart';
import 'package:feed_app/domain/repo/post_repository.dart';

class PostRepositoryImpl implements PostRepository {
  final RemoteDataSource remote;
  final LocalDataSource local;

  PostRepositoryImpl({required this.remote, required this.local});

  @override
  Future<Post> getPost(int id) async {
    // Try local first
    final localPost = await local.getPostById(id);
    if (localPost != null) return localPost;

    // Fallback to remote and cache
    final remotePost = await remote.fetchPost(id);
    await local.insertPost(remotePost);
    return remotePost;
  }

  @override
  Future<List<CommentModel>> getComments(int postId) async {
    final cached = await local.getCachedComments(postId);
    if (cached.isNotEmpty) return cached;

    final remoteComments = await remote.fetchComments(postId);
    await local.cacheComments(remoteComments);
    return remoteComments;
  }

  @override
  Future<void> toggleFavorite(int postId) async {
    final isFav = await local.isFavorite(postId);
    if (isFav) {
      await local.removeFavorite(postId);
    } else {
      await local.addFavorite(postId);
    }
  }

  @override
  Future<bool> isFavorite(int postId) async {
    return await local.isFavorite(postId);
  }
}
