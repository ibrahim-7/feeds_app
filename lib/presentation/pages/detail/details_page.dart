import 'package:feed_app/core/utils/app_colors.dart';
import 'package:feed_app/domain/repo/post_repository.dart';
import 'package:feed_app/presentation/blocs/details/detail_bloc.dart';
import 'package:feed_app/presentation/pages/widgets/comment_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/details/details_event.dart';
import '../../blocs/details/details_state.dart';

class DetailsPage extends StatelessWidget {
  final int postId;
  const DetailsPage({super.key, required this.postId});

  // Helper to create the route with bloc provided
  static Route route(int postId) {
    return MaterialPageRoute(
      builder: (context) {
        final repo = RepositoryProvider.of<PostRepository>(context);
        return BlocProvider(
          create: (_) => DetailsBloc(repo)..add(DetailsRequested(postId)),
          child: DetailsPage(postId: postId),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Post Details'),
      ),
      body: BlocBuilder<DetailsBloc, DetailsState>(
        builder: (context, state) {
          if (state is DetailsLoading || state is DetailsInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DetailsError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      context.read<DetailsBloc>().add(DetailsRequested(postId));
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state is DetailsLoaded) {
            final post = state.post;
            final comments = state.comments;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Favorite Button Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          post.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          state.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: state.isFavorite ? Colors.red : Colors.grey,
                          size: 28,
                        ),
                        tooltip: state.isFavorite
                            ? 'Remove from favorites'
                            : 'Add to favorites',
                        onPressed: () {
                          context
                              .read<DetailsBloc>()
                              .add(ToggleFavoriteRequested(post.id));
                          final message = state.isFavorite
                              ? 'Removed from favorites'
                              : 'Added to favorites';
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(message),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Post Body Text
                  Text(
                    post.body,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Divider(thickness: 1),

                  const SizedBox(height: 12),

                  // Comments Header
                  const Text(
                    'Comments',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Comments List or Empty Text
                  if (comments.isEmpty)
                    const Text(
                      'No comments found.',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    )
                  else
                    ...comments.map(
                      (c) => CommentTile(
                        name: c.name,
                        body: c.body,
                        email: c.email,
                      ),
                    ),
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
