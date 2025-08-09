import 'package:feed_app/data/models/comments_model.dart';
import 'package:feed_app/data/models/post_model.dart';
import 'package:feed_app/domain/repo/post_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'details_event.dart';
import 'details_state.dart';

class DetailsBloc extends Bloc<DetailsEvent, DetailsState> {
  final PostRepository repository;

  DetailsBloc(this.repository) : super(DetailsInitial()) {
    on<DetailsRequested>(_onRequested);
    on<ToggleFavoriteRequested>(_onToggleFavorite);
  }

  Future<void> _onRequested(
      DetailsRequested event, Emitter<DetailsState> emit) async {
    emit(DetailsLoading());
    try {
      final Post post = await repository.getPost(event.postId);
      final List<CommentModel> comments =
          await repository.getComments(event.postId);
      final bool isFav = await repository.isFavorite(event.postId);

      emit(DetailsLoaded(post: post, comments: comments, isFavorite: isFav));
    } catch (e) {
      emit(DetailsError('Failed to load post details'));
    }
  }

  Future<void> _onToggleFavorite(
      ToggleFavoriteRequested event, Emitter<DetailsState> emit) async {
    if (state is DetailsLoaded) {
      final current = state as DetailsLoaded;
      try {
        // optimistic UI toggle
        emit(current.copyWith(isFavorite: !current.isFavorite));
        await repository.toggleFavorite(event.postId);
        final bool isFav = await repository.isFavorite(event.postId);
        emit(current.copyWith(isFavorite: isFav));
      } catch (e) {
        // rollback if something went wrong
        emit(current.copyWith(isFavorite: current.isFavorite));
      }
    }
  }
}
