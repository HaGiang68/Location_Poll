import 'package:equatable/equatable.dart';
import 'package:location_poll/models/poll.dart';

abstract class PollsPageState extends Equatable {
  const PollsPageState();
}

class PollsPageInitial extends PollsPageState {
  const PollsPageInitial();

  @override
  List<Object?> get props => [];
}

class PollsPageLoading extends PollsPageState {
  const PollsPageLoading();

  @override
  List<Object?> get props => [];
}

class PollsPageLoaded extends PollsPageState {
  final List<Poll> myPolls;
  final List<Poll> allPolls;

  const PollsPageLoaded({
    required this.myPolls,
    required this.allPolls,
  });

  @override
  List<Object> get props => [
        myPolls,
        allPolls,
      ];
}

class PollsPageError extends PollsPageState {
  final String message;

  const PollsPageError(this.message);

  @override
  List<Object> get props => [
        message,
      ];
}

class PollsPageUpdating extends PollsPageLoaded {
  const PollsPageUpdating({
    required List<Poll> myPolls,
    required List<Poll> allPolls,
  }) : super(
          myPolls: myPolls,
          allPolls: allPolls,
        );
}
