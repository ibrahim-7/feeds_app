import 'package:equatable/equatable.dart';
import 'package:feed_app/data/models/post_model.dart';

abstract class FeedState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FeedInitial extends FeedState {}

class FeedLoading extends FeedState {}

class FeedLoaded extends FeedState {
  final List<Post> posts;
  final bool hasMore;
  final bool isOffline;

  FeedLoaded({
    required this.posts,
    required this.hasMore,
    this.isOffline = false,
  });

  @override
  List<Object?> get props => [posts, hasMore];
}

class FeedError extends FeedState {
  final String message;
  FeedError(this.message);

  @override
  List<Object?> get props => [message];
}
