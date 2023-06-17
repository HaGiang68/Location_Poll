import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_geofence/geofence.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:location_poll/features/poll/overview/bloc/polls_page_cubit.dart';
import 'package:location_poll/features/poll/vote/bloc/vote_page_state.dart';
import 'package:location_poll/models/poll.dart';
import 'package:location_poll/services/geofence_service.dart';
import 'package:location_poll/services/poll_service.dart';
import 'package:location_poll/services/storage_service.dart';
import 'package:logger/logger.dart';

class VotePageCubit extends Cubit<VotePageState> {
  VotePageCubit({
    required PollService pollService,
    required GeofenceService geofenceService,
    required StorageService storageService,
  })  : _pollService = pollService,
        _geofenceService = geofenceService,
        _storageService = storageService,
        super(const VotePageInit());

  final PollService _pollService;
  final GeofenceService _geofenceService;
  final StorageService _storageService;

  final _logger = Logger(
    printer: PrettyPrinter(),
  );

  void startWithPoll(Poll poll) {
    if (poll.questions.isNotEmpty) {
      emit(
        VotePageQuestionReady(
          currentQuestionIndex: 0,
          votes: const {},
          poll: poll,
        ),
      );
      return;
    } else {
      emit(
        VotePageError(
          poll: poll,
          currentQuestionIndex: 0,
          votes: const {},
        ),
      );
    }
  }

  void vote(int choiceId) {
    final votes = Map<int, int>.from(state.votes);
    votes[state.currentQuestionIndex] = choiceId;
    emit(
      state.copyWith(
        votes: votes,
      ),
    );
  }

  Future<void> submit() async {
    final currState = state;
    if (currState is VotePagePollState) {
      emit(
        VotePageSubmitting(
          poll: currState.poll,
          currentQuestionIndex: currState.currentQuestionIndex,
          votes: currState.votes,
          submissionFailed: currState.submissionFailed,
        ),
      );
      final success =
          await _pollService.submitVote(currState.poll, currState.votes);
      if (success) {
        try {
          _logger.i('Delete geofence.');
          _geofenceService.deleteGeofence(Geolocation(
              latitude: currState
                  .poll.requirements.locationRequirement.geoPoint.latitude,
              longitude: currState
                  .poll.requirements.locationRequirement.geoPoint.longitude,
              radius: currState.poll.requirements.locationRequirement.radius,
              id: currState.poll.title));
        } catch (e) {
          _logger.e(e);
        }
        try {
          _logger.i('Store information on vote in db.');
          _storageService.storeUserVote(
            currState.poll,
          );
        } catch (e) {
          _logger.e(e);
        }
        try {
          Modular.get<PollsPageCubit>().onUserVoted(
            currState.poll,
            currState.votes,
          );
        } catch(e) {
          _logger.e(e);
        }
        emit(
          VotePageFinished(
            poll: currState.poll,
            currentQuestionIndex: currState.currentQuestionIndex,
            votes: currState.votes,
          ),
        );
      } else {
        emit(
          VotePageQuestionReady(
            poll: currState.poll,
            currentQuestionIndex: currState.currentQuestionIndex,
            votes: currState.votes,
            submissionFailed: true,
          ),
        );
      }
    }
  }
}
