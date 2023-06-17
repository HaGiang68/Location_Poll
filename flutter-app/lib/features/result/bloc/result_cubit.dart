import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:location_poll/models/poll.dart';
import 'package:location_poll/services/poll_service.dart';

part 'result_state.dart';

class ResultCubit extends Cubit<ResultState> {
  ResultCubit({
    required PollService pollService,
  })  : _pollService = pollService,
        super(ResultInitial());

  final PollService _pollService;

  startWithPoll(Poll poll) {
    emit(
      PollLoaded(
        poll: poll,
      ),
    );
  }

  Future<void> updatePoll() async {
    final curState = state;
    if (curState is PollLoaded) {
      final id = curState.poll.documentReference;
      if (id != null) {
        final newPoll = await _pollService.loadPollWithId(id);
        if (newPoll != null) {
          emit(
            PollLoaded(
              poll: newPoll,
            ),
          );
        }
      }
    }
  }
}
