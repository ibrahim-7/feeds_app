import 'package:feed_app/data/models/comments_model.dart';

import '../../data/models/post_model.dart';

abstract class PostRepository {
  Future<Post> getPost(int id);
  Future<List<CommentModel>> getComments(int postId);
  Future<void> toggleFavorite(int postId);
  Future<bool> isFavorite(int postId);
}
