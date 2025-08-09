import 'package:equatable/equatable.dart';

abstract class FeedEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchFeed extends FeedEvent {
  final bool refresh;
  FetchFeed({this.refresh = false});

  @override
  List<Object?> get props => [refresh];
}
