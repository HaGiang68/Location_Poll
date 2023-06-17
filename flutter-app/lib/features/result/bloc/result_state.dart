part of 'result_cubit.dart';

class ResultState extends Equatable {
  const ResultState();

  @override
  List<Object?> get props => [];
}

class ResultInitial extends ResultState {}

class PollLoaded extends ResultState {
  const PollLoaded({
    required this.poll,
  });

  final Poll poll;

  @override
  List<Object?> get props => [
        poll,
      ];
}
