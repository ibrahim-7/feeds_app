import 'package:equatable/equatable.dart';

abstract class DetailsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class DetailsRequested extends DetailsEvent {
  final int postId;
  DetailsRequested(this.postId);
  @override
  List<Object?> get props => [postId];
}

class ToggleFavoriteRequested extends DetailsEvent {
  final int postId;
  ToggleFavoriteRequested(this.postId);
  @override
  List<Object?> get props => [postId];
}
