import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:latlong2/latlong.dart';
import 'package:location_poll/features/poll/create/bloc/create_state.dart';
import 'package:location_poll/models/choice.dart';
import 'package:location_poll/models/geo_point.dart';
import 'package:location_poll/models/poll.dart';
import 'package:location_poll/models/question.dart';
import 'package:location_poll/models/requirements/auth_requirement.dart';
import 'package:location_poll/models/requirements/location_requirement.dart';
import 'package:location_poll/models/requirements/requirements.dart';
import 'package:location_poll/models/requirements/time_requirement.dart';
import 'package:location_poll/models/user.dart';
import 'package:location_poll/services/auth_service.dart';
import 'package:location_poll/services/poll_service.dart';

class CreateCubit extends Cubit<CreateState> {
  CreateCubit({required PollService pollService})
      : _pollService = pollService,
        super(
          CreateInit.fromPoll(
            poll: null,
          ),
        );

  final PollService _pollService;

  void createInit(Poll? poll) {
    emit(
      CreateInit.fromPoll(
        poll: poll,
      ),
    );
  }

  void questionChange(String question) {
    emit(
      state.copyWith(
        question: question,
      ),
    );
  }

  void titleChange(String title) {
    emit(
      state.copyWith(
        title: title,
      ),
    );
  }

  void locationChange(LatLng location) {
    emit(
      state.copyWith(
        location: location,
      ),
    );
  }

  void radiusChange(double radius) {
    emit(
      state.copyWith(
        radius: radius,
      ),
    );
  }

  void addChoice(Choice choice) {
    final currState = state;
    List<Choice> choices = List.from(currState.choices);
    choices.add(choice);
    emit(
      state.copyWith(
        choices: choices,
      ),
    );
  }

  void changeTextChoice(int index, String text) {
    final currState = state;
    List<Choice> choices = List.from(currState.choices);
    choices.removeAt(index);
    choices.insert(index, Choice(choice: text, counter: 0, choiceId: index));

    emit(
      state.copyWith(
        choices: choices,
      ),
    );
  }

  void removeChoice(int index) {
    final currState = state;
    List<Choice> choices = List.from(currState.choices);
    choices.removeAt(index);
    emit(
      state.copyWith(
        choices: choices,
      ),
    );
  }

  /// Save the current poll to database, update if it has a defined document
  /// reference.
  Future<void> savePoll() async {
    final currState = state;
    bool isMeter = currState.parameter == 'm';
    Poll p = Poll(
      title: currState.title,
      owner: User(
        userName: Modular.get<AuthService>().loggedInUser()?.userName ?? '',
        uuid: Modular.get<AuthService>().loggedInUser()?.uuid ?? '',
      ),
      questions: [
        Question(
            question: currState.question,
            questionId: 0,
            choices: currState.choices)
      ],
      requirements: Requirements(
        authRequirement: AuthRequirement(
          auth: AuthStage.anonymous,
        ),
        locationRequirement: LocationRequirement(
            radius: isMeter ? currState.radius : currState.radius * 1000,
            geoPoint: GeoPoint(
              latitude: currState.location.latitude,
              longitude: currState.location.longitude,
            ),
            geoHash: 'GeoHash123'),
        timeRequirement: TimeRequirement(
          startTime: currState.startDate,
          endTime: currState.endDate,
        ),
      ),
      documentReference: currState.docRef,
    );
    if (currState.docRef == null) {
      await _pollService.createPoll(p);
    } else {
      await _pollService.updatePoll(p);
    }
    emit(
      CreatePageSavePoll(
        title: currState.title,
        question: currState.question,
        choices: currState.choices,
        location: currState.location,
        radius: currState.radius,
        parameter: currState.parameter,
        startDate: currState.startDate,
        endDate: currState.endDate,
        docRef: currState.docRef,
      ),
    );
  }

  void parameterChange(String? parameter) {
    final currState = state;
    emit(
      CreatePagePoll(
        title: currState.title,
        question: currState.question,
        choices: currState.choices,
        location: currState.location,
        radius: currState.radius,
        parameter: parameter!,
        startDate: currState.startDate,
        endDate: currState.endDate,
        docRef: currState.docRef,
      ),
    );
  }

  void startDateChange(DateTime startDate) {
    final currState = state;
    emit(
      CreatePagePoll(
        title: currState.title,
        question: currState.question,
        choices: currState.choices,
        location: currState.location,
        radius: currState.radius,
        parameter: currState.parameter,
        startDate: startDate,
        endDate: currState.endDate,
        docRef: currState.docRef,
      ),
    );
  }

  void endDateChange(DateTime endDate) {
    final currState = state;
    emit(
      CreatePagePoll(
        title: currState.title,
        question: currState.question,
        choices: currState.choices,
        location: currState.location,
        radius: currState.radius,
        parameter: currState.parameter,
        startDate: currState.startDate,
        endDate: endDate,
        docRef: currState.docRef,
      ),
    );
  }
}
