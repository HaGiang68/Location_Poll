part of 'vote_preview_page_cubit.dart';

abstract class VotePreviewPageState extends Equatable {
  const VotePreviewPageState({
    required this.poll,
  }) : super();

  final Poll poll;

  bool get isAfterStartTime =>
      poll.requirements.timeRequirement.startTime.isBefore(DateTime.now());

  bool get isBeforeEndTime =>
      poll.requirements.timeRequirement.endTime.isAfter(DateTime.now());

  bool get isTimeValid => isAfterStartTime && isBeforeEndTime;

  @override
  List<Object?> get props => [
        poll,
      ];

  VotePreviewPageState copyWith({
    Poll? poll,
    Position? position,
    double? distanceMeter,
  });
}

class VotePreviewPageInitial extends VotePreviewPageState {
  const VotePreviewPageInitial({
    required Poll poll,
  }) : super(
          poll: poll,
        );

  VotePreviewPageState copyWith({
    Poll? poll,
    Position? position,
    double? distanceMeter,
  }) {
    return VotePreviewPageInitial(
      poll: poll ?? this.poll,
    );
  }
}

class VotePreviewPagePositionLoaded extends VotePreviewPageState {
  const VotePreviewPagePositionLoaded({
    required Poll poll,
    required this.position,
  }) : super(
          poll: poll,
        );

  final Position position;

  @override
  List<Object?> get props => [
        poll,
        position,
      ];

  VotePreviewPageState copyWith({
    Poll? poll,
    Position? position,
    double? distanceMeter,
  }) {
    return VotePreviewPagePositionLoaded(
      poll: poll ?? this.poll,
      position: position ?? this.position,
    );
  }
}

class VotePreviewPageInPollRadius extends VotePreviewPagePositionLoaded {
  const VotePreviewPageInPollRadius({
    required Poll poll,
    required Position position,
  }) : super(
          poll: poll,
          position: position,
        );

  VotePreviewPageState copyWith({
    Poll? poll,
    Position? position,
    double? distanceMeter,
  }) {
    return VotePreviewPageInPollRadius(
      poll: poll ?? this.poll,
      position: position ?? this.position,
    );
  }
}

class VotePreviewPageOutsidePollRadius extends VotePreviewPagePositionLoaded {
  const VotePreviewPageOutsidePollRadius({
    required Poll poll,
    required Position position,
    required this.distanceMeter,
  }) : super(
          poll: poll,
          position: position,
        );

  final double distanceMeter;

  @override
  List<Object?> get props => [
        poll,
        position,
        distanceMeter,
      ];

  VotePreviewPageState copyWith({
    Poll? poll,
    Position? position,
    double? distanceMeter,
  }) {
    return VotePreviewPageOutsidePollRadius(
      poll: poll ?? this.poll,
      position: position ?? this.position,
      distanceMeter: distanceMeter ?? this.distanceMeter,
    );
  }
}
