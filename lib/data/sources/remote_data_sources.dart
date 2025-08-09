import 'dart:convert';

import 'package:feed_app/data/models/comments_model.dart';
import 'package:http/http.dart' as http;

import '../../core/utils/app_constants.dart';
import '../models/post_model.dart';

class RemoteDataSource {
  final http.Client client;
  RemoteDataSource(this.client);

  // Fetch paginated list of posts
  Future<List<Post>> fetchPosts({int start = 0, int limit = 10}) async {
    final res = await client.get(
      Uri.parse(
          '${AppConstants.baseUrlFeed}/posts?_start=$start&_limit=$limit'),
      headers: {
        'Accept': 'application/json',
        'User-Agent': 'Mozilla/5.0',
      },
    );

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => Post.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch posts');
    }
  }

  // Fetch single post
  Future<Post> fetchPost(int id) async {
    final res = await client.get(
      Uri.parse('${AppConstants.baseUrlFeed}/posts/$id'),
      headers: {
        'Accept': 'application/json',
        'User-Agent': 'Mozilla/5.0',
      },
    );
    if (res.statusCode == 200) {
      return Post.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('Failed to fetch post');
    }
  }

  Future<List<CommentModel>> fetchComments(int postId) async {
    final res = await client.get(
      Uri.parse('${AppConstants.baseUrlFeed}/posts/$postId/comments'),
      headers: {
        'Accept': 'application/json',
        'User-Agent': 'Mozilla/5.0',
      },
    );
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => CommentModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch comments');
    }
  }
}
