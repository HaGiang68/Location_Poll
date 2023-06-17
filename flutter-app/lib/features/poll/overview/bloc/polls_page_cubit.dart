import 'package:bloc/bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_geofence/Geolocation.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:location_poll/features/poll/overview/bloc/polls_page_state.dart';
import 'package:location_poll/models/poll.dart';
import 'package:location_poll/services/auth_service.dart';
import 'package:location_poll/services/geofence_service.dart';
import 'package:location_poll/services/poll_service.dart';
import 'package:logger/logger.dart';

class PollsPageCubit extends Cubit<PollsPageState> {
  PollsPageCubit({
    required PollService pollService,
    required GeofenceService geofenceService,
  })  : _pollService = pollService,
        _geofenceService = geofenceService,
        super(const PollsPageInitial()) {
    init();
  }

  final PollService _pollService;
  final GeofenceService _geofenceService;

  static final _logger = Logger(
    printer: PrettyPrinter(),
  );

  void init() {
    loadPolls();
    _initFcm();
  }

  Future<void> loadPolls() async {
    try {
      final curState = state;
      if (curState is PollsPageLoaded) {
        emit(
          PollsPageUpdating(
            myPolls: curState.myPolls,
            allPolls: curState.allPolls,
          ),
        );
      } else {
        emit(const PollsPageLoading());
      }
      final user = Modular.get<AuthService>().loggedInUser();
      if (user != null) {
        List<Poll> ownPolls =
            await _pollService.getPollsCreatedBy(uuid: user.uuid);
        List<Poll> futureEndingPolls =
            await _pollService.getFutureEndingPolls();
        for (Poll poll in futureEndingPolls) {
          Geolocation location = Geolocation(
              latitude: poll.requirements.locationRequirement.geoPoint.latitude,
              longitude:
                  poll.requirements.locationRequirement.geoPoint.longitude,
              radius: poll.requirements.locationRequirement.radius,
              id: poll.title.toString());
          _geofenceService.addGeofenceEntry(location);
        }

        emit(PollsPageLoaded(
          myPolls: ownPolls,
          allPolls: futureEndingPolls,
        ));
      }
    } on Exception {
      emit(const PollsPageError(
          "Polls konnten nicht geladen werden, bist du online?"));
    }
  }

  Future<void> _initFcm() async {
    _logger.i('Init FCM-Service');
    String? token = await FirebaseMessaging.instance.getToken();
    await _pollService.submitFCMToken(token!);
  }

  void onUserVoted(Poll poll, Map<int, int> votes) {
    final curState = state;
    if (curState is PollsPageLoaded) {
      final allPolls = _setPollVoted(curState.allPolls, poll, votes);
      final myPolls = _setPollVoted(curState.myPolls, poll, votes);

      if (state is PollsPageUpdating) {
        emit(
          PollsPageUpdating(
            myPolls: myPolls,
            allPolls: allPolls,
          ),
        );
      } else {
        emit(
          PollsPageLoaded(
            myPolls: myPolls,
            allPolls: allPolls,
          ),
        );
      }
    }
  }

  List<Poll> _setPollVoted(List<Poll> polls, Poll poll, Map<int, int> votes) {
    final p = polls.firstWhere(
        (element) => element.documentReference == poll.documentReference);
    polls.remove(p);
    polls.add(
      p.copyWith(
        alreadyVoted: true,
      ),
    );
    return polls;
  }

  Future<void> deletePoll(Poll poll) async {
    final curState = state;
    if (curState is PollsPageLoaded) {
      try {
        await _pollService.deletePoll(poll);
        _logger.i('Deleted poll with id ${poll.documentReference}');
      } catch (e) {
        _logger.e(e);
      }
      final myPolls = curState.myPolls;
      final allPolls = curState.allPolls;
      myPolls.remove(poll);
      allPolls.remove(poll);
      if (curState is PollsPageUpdating) {
        emit(
          PollsPageUpdating(
            myPolls: myPolls,
            allPolls: allPolls,
          ),
        );
      } else {
        emit(
          PollsPageLoaded(
            myPolls: myPolls,
            allPolls: allPolls,
          ),
        );
      }
    }
  }
}
