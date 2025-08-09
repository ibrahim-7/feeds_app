import 'package:feed_app/core/utils/app_constants.dart';
import 'package:feed_app/domain/repo/feed_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'feed_event.dart';
import 'feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final FeedRepository feedRepository;
  int _page = 0;
  final int _limit = AppConstants.postsPerPage;

  FeedBloc(this.feedRepository) : super(FeedInitial()) {
    on<FetchFeed>(_onFetchFeed);
  }

  Future<void> _onFetchFeed(FetchFeed event, Emitter<FeedState> emit) async {
    try {
      if (event.refresh) {
        _page = 0;
        emit(FeedLoading());
      }

      final newPosts =
          await feedRepository.fetchPosts(start: _page * _limit, limit: _limit);

      if (event.refresh) {
        await feedRepository.cachePosts(newPosts);
        emit(FeedLoaded(posts: newPosts, hasMore: newPosts.length == _limit));
      } else {
        final currentState = state;
        if (currentState is FeedLoaded) {
          final updatedList = List.of(currentState.posts)..addAll(newPosts);
          emit(FeedLoaded(
              posts: updatedList, hasMore: newPosts.length == _limit));
        } else {
          emit(FeedLoaded(posts: newPosts, hasMore: newPosts.length == _limit));
        }
      }

      _page++;
    } catch (_) {
      final cached = await feedRepository.getCachedPosts();
      if (cached.isNotEmpty) {
        emit(FeedLoaded(
          posts: cached,
          hasMore: false,
          isOffline: true,
        ));
      } else {
        emit(FeedError("Failed to load feed"));
      }
    }
  }
}
