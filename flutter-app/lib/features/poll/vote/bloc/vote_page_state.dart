import 'package:equatable/equatable.dart';
import 'package:location_poll/models/poll.dart';

abstract class VotePageState extends Equatable {
  const VotePageState({
    this.currentQuestionIndex = 0,
    this.votes = const {},
    this.submissionFailed = false,
  });

  final int currentQuestionIndex;
  final Map<int, int> votes;
  final bool submissionFailed;

  @override
  List<Object?> get props => [
        currentQuestionIndex,
        votes,
        submissionFailed,
      ];

  VotePageState copyWith({
    Poll? poll,
    int? currentQuestionIndex,
    Map<int, int>? votes,
    bool? submissionFailed,
  });
}

abstract class VotePagePollState extends VotePageState {
  const VotePagePollState({
    required this.poll,
    int currentQuestionIndex = 0,
    Map<int, int> votes = const {},
    bool submissionFailed = false,
  }) : super(
          currentQuestionIndex: currentQuestionIndex,
          votes: votes,
          submissionFailed: submissionFailed,
        );

  final Poll poll;

  @override
  List<Object?> get props => [
        poll,
        currentQuestionIndex,
        votes,
        submissionFailed,
      ];

  @override
  VotePagePollState copyWith({
    Poll? poll,
    int? currentQuestionIndex,
    Map<int, int>? votes,
    bool? submissionFailed,
  });
}

class VotePageInit extends VotePageState {
  const VotePageInit() : super();

  @override
  VotePageInit copyWith({
    Poll? poll,
    int? currentQuestionIndex,
    Map<int, int>? votes,
    bool? submissionFailed,
  }) {
    return const VotePageInit();
  }
}

class VotePageQuestionReady extends VotePagePollState {
  const VotePageQuestionReady({
    required Poll poll,
    required int currentQuestionIndex,
    required Map<int, int> votes,
    bool submissionFailed = false,
  }) : super(
          poll: poll,
          currentQuestionIndex: currentQuestionIndex,
          votes: votes,
          submissionFailed: submissionFailed,
        );

  @override
  VotePageQuestionReady copyWith({
    Poll? poll,
    int? currentQuestionIndex,
    Map<int, int>? votes,
    bool? submissionFailed,
  }) {
    return VotePageQuestionReady(
      poll: poll ?? this.poll,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      votes: votes ?? this.votes,
      submissionFailed: submissionFailed ?? this.submissionFailed,
    );
  }
}

class VotePageSubmitting extends VotePagePollState {
  const VotePageSubmitting({
    required Poll poll,
    required int currentQuestionIndex,
    required Map<int, int> votes,
    bool submissionFailed = false,
  }) : super(
          poll: poll,
          currentQuestionIndex: currentQuestionIndex,
          votes: votes,
          submissionFailed: submissionFailed,
        );

  @override
  VotePageSubmitting copyWith({
    Poll? poll,
    int? currentQuestionIndex,
    Map<int, int>? votes,
    bool? submissionFailed,
  }) {
    return VotePageSubmitting(
      poll: poll ?? this.poll,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      votes: votes ?? this.votes,
      submissionFailed: submissionFailed ?? this.submissionFailed,
    );
  }
}

class VotePageFinished extends VotePagePollState {
  const VotePageFinished({
    required Poll poll,
    required int currentQuestionIndex,
    required Map<int, int> votes,
    bool submissionFailed = false,
  }) : super(
          poll: poll,
          currentQuestionIndex: currentQuestionIndex,
          votes: votes,
          submissionFailed: submissionFailed,
        );

  @override
  VotePageFinished copyWith({
    Poll? poll,
    int? currentQuestionIndex,
    Map<int, int>? votes,
    bool? submissionFailed,
  }) {
    return VotePageFinished(
      poll: poll ?? this.poll,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      votes: votes ?? this.votes,
      submissionFailed: submissionFailed ?? this.submissionFailed,
    );
  }
}

class VotePageError extends VotePagePollState {
  const VotePageError({
    required Poll poll,
    required int currentQuestionIndex,
    required Map<int, int> votes,
    bool submissionFailed = false,
  }) : super(
          poll: poll,
          currentQuestionIndex: currentQuestionIndex,
          votes: votes,
          submissionFailed: submissionFailed,
        );

  @override
  VotePageError copyWith({
    Poll? poll,
    int? currentQuestionIndex,
    Map<int, int>? votes,
    bool? submissionFailed,
  }) {
    return VotePageError(
      poll: poll ?? this.poll,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      votes: votes ?? this.votes,
      submissionFailed: submissionFailed ?? this.submissionFailed,
    );
  }
}
