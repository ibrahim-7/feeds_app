import 'package:feed_app/core/utils/app_colors.dart';
import 'package:feed_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:feed_app/presentation/blocs/auth/auth_event.dart';
import 'package:feed_app/presentation/blocs/feed/feed_block.dart';
import 'package:feed_app/presentation/pages/detail/details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/feed/feed_event.dart';
import '../../blocs/feed/feed_state.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final ScrollController _controller = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    context.read<FeedBloc>().add(FetchFeed(refresh: true));

    _controller.addListener(() {
      if (_controller.position.pixels >=
          _controller.position.maxScrollExtent - 200) {
        final state = context.read<FeedBloc>().state;
        if (state is FeedLoaded && state.hasMore && !_isLoadingMore) {
          _isLoadingMore = true;
          context.read<FeedBloc>().add(FetchFeed());
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Feed"),
        actions: [
          IconButton(
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequested());
              Navigator.pushReplacementNamed(context, '/login');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: BlocConsumer<FeedBloc, FeedState>(
        listener: (context, state) {
          if (state is FeedLoaded || state is FeedError) {
            _isLoadingMore = false;
          }
        },
        builder: (context, state) {
          if (state is FeedLoading && state is! FeedLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is FeedLoaded) {
            return Column(
              children: [
                if (state.isOffline)
                  Container(
                    width: double.infinity,
                    color: Colors.orange.shade100,
                    padding: const EdgeInsets.all(8),
                    child: const Text(
                      "⚠ Offline Mode – showing cached posts",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      context.read<FeedBloc>().add(FetchFeed(refresh: true));
                    },
                    child: ListView.builder(
                      controller: _controller,
                      itemCount: state.hasMore
                          ? state.posts.length + 1
                          : state.posts.length,
                      itemBuilder: (context, index) {
                        if (index >= state.posts.length) {
                          return const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final post = state.posts[index];
                        return GestureDetector(
                          onTap: () => Navigator.push(
                              context, DetailsPage.route(post.id)),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                            shadowColor: Colors.grey.withOpacity(0.2),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Leading icon
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.article_outlined,
                                      color: Colors.blue,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Title + Body text
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Title
                                        Text(
                                          post.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 6),

                                        // Body
                                        Text(
                                          post.body,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade700,
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          }

          if (state is FeedError) {
            return Center(child: Text(state.message));
          }

          return const SizedBox();
        },
      ),
    );
  }
}
