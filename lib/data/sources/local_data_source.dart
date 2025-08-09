import 'package:feed_app/data/models/comments_model.dart';
import 'package:feed_app/data/models/post_model.dart';
import 'package:sqflite/sqflite.dart';

class LocalDataSource {
  final Database db;
  LocalDataSource(this.db);

  // posts
  Future<void> cachePosts(List<Post> posts) async {
    final batch = db.batch();
    for (var p in posts) {
      batch.insert('posts', p.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<Post>> getCachedPosts() async {
    final rows = await db.query('posts', orderBy: 'id DESC');
    return rows.map((r) => Post.fromJson(r)).toList();
  }

  Future<Post?> getPostById(int id) async {
    final rows =
        await db.query('posts', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isNotEmpty) return Post.fromJson(rows.first);
    return null;
  }

  Future<void> insertPost(Post post) async {
    await db.insert('posts', post.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deletePost(int id) async {
    await db.delete('posts', where: 'id = ?', whereArgs: [id]);
  }

  // comments
  Future<void> cacheComments(List<CommentModel> comments) async {
    final batch = db.batch();
    for (var c in comments) {
      batch.insert('comments', c.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<CommentModel>> getCachedComments(int postId) async {
    final rows = await db.query('comments',
        where: 'postId = ?', whereArgs: [postId], orderBy: 'id ASC');
    return rows.map((r) => CommentModel.fromJson(r)).toList();
  }

  // favorites
  Future<void> addFavorite(int postId) async {
    await db.insert('favorites', {'postId': postId},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> removeFavorite(int postId) async {
    await db.delete('favorites', where: 'postId = ?', whereArgs: [postId]);
  }

  Future<bool> isFavorite(int postId) async {
    final rows = await db.query('favorites',
        where: 'postId = ?', whereArgs: [postId], limit: 1);
    return rows.isNotEmpty;
  }

  Future<List<int>> getFavorites() async {
    final rows = await db.query('favorites');
    return rows.map((r) => r['postId'] as int).toList();
  }
}
