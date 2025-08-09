import 'package:equatable/equatable.dart';
import 'package:feed_app/data/models/comments_model.dart';

import '../../../data/models/post_model.dart';

abstract class DetailsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DetailsInitial extends DetailsState {}

class DetailsLoading extends DetailsState {}

class DetailsLoaded extends DetailsState {
  final Post post;
  final List<CommentModel> comments;
  final bool isFavorite;

  DetailsLoaded({
    required this.post,
    required this.comments,
    required this.isFavorite,
  });

  DetailsLoaded copyWith({
    Post? post,
    List<CommentModel>? comments,
    bool? isFavorite,
  }) {
    return DetailsLoaded(
      post: post ?? this.post,
      comments: comments ?? this.comments,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props => [post, comments, isFavorite];
}

class DetailsError extends DetailsState {
  final String message;
  DetailsError(this.message);
  @override
  List<Object?> get props => [message];
}
