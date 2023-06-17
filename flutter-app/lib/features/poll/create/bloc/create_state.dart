import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import 'package:location_poll/models/choice.dart';
import 'package:location_poll/models/poll.dart';

abstract class CreateState extends Equatable {
  final String title;
  final String question;
  final List<Choice> choices;
  final LatLng location;
  final double radius;
  final String parameter;
  final DateTime startDate;
  final DateTime endDate;
  final String? docRef;

  const CreateState({
    required this.title,
    required this.question,
    required this.choices,
    required this.location,
    required this.radius,
    required this.parameter,
    required this.startDate,
    required this.endDate,
    this.docRef,
  }) : super();

  @override
  List<Object?> get props => [
        title,
        question,
        choices,
        location,
        radius,
        parameter,
        startDate,
        endDate,
        docRef,
      ];

  bool get isTitleNotEmpty => question.length > 1;

  bool get isQuestionNotEmpty => question.length > 1;

  bool get isChoiceMinTwo => choices.length >= 2;

  bool get isRadiusNotEmpty =>
      !radius.isNaN &&
      !radius.isNegative &&
      double.tryParse(radius.toString()) != null &&
      radius > 0.0;

  bool get isStartDateBeforeEndDate => startDate.isBefore(endDate);

  bool get isPollStarted => startDate.isBefore(DateTime.now());

  bool get isInEditMode => docRef != null;

  CreateState copyWith({
    String? title,
    String? question,
    List<Choice>? choices,
    LatLng? location,
    double? radius,
    String? parameter,
    DateTime? startDate,
    DateTime? endDate,
    String? docRef,
  });
}

class CreateInit extends CreateState {
  CreateInit.fromPoll({
    Poll? poll,
  }) : super(
          title: poll?.title ?? '',
          question: poll?.questions[0].question ?? '',
          choices: poll?.questions[0].choices ??
              List.generate(
                2,
                (index) => Choice(
                  choice: '',
                  choiceId: index,
                  counter: 0,
                ),
              ),
          location: LatLng(
              poll?.requirements.locationRequirement.geoPoint.latitude ?? 0.0,
              poll?.requirements.locationRequirement.geoPoint.longitude ?? 0.0),
          // calculate radius in m or km
          radius: (poll != null)
              ? (poll.requirements.locationRequirement.radius > 1000
                  ? poll.requirements.locationRequirement.radius / 1000
                  : poll.requirements.locationRequirement.radius)
              : 100,
          // display km if > 1000m radius
          parameter: (poll != null)
              ? (poll.requirements.locationRequirement.radius > 1000
                  ? 'km'
                  : 'm')
              : 'm',
          startDate:
              poll?.requirements.timeRequirement.startTime ?? DateTime.now(),
          endDate: poll?.requirements.timeRequirement.endTime ??
              DateTime.now().add(
                const Duration(
                  days: 1,
                ),
              ),
          docRef: poll?.documentReference,
        );

  @override
  CreatePagePoll copyWith({
    String? title,
    String? question,
    List<Choice>? choices,
    LatLng? location,
    double? radius,
    String? parameter,
    DateTime? startDate,
    DateTime? endDate,
    String? docRef,
  }) {
    return CreatePagePoll(
      title: title ?? this.title,
      question: question ?? this.question,
      choices: choices ?? this.choices,
      location: location ?? this.location,
      radius: radius ?? this.radius,
      parameter: parameter ?? this.parameter,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      docRef: docRef ?? this.docRef,
    );
  }
}

class CreatePagePoll extends CreateState {
  const CreatePagePoll({
    required String title,
    required String question,
    required List<Choice> choices,
    required LatLng location,
    required double radius,
    required String parameter,
    required DateTime startDate,
    required DateTime endDate,
    String? docRef,
  }) : super(
          title: title,
          question: question,
          choices: choices,
          location: location,
          radius: radius,
          parameter: parameter,
          startDate: startDate,
          endDate: endDate,
          docRef: docRef,
        );

  @override
  CreatePagePoll copyWith({
    String? title,
    String? question,
    List<Choice>? choices,
    LatLng? location,
    double? radius,
    String? parameter,
    DateTime? startDate,
    DateTime? endDate,
    String? docRef,
  }) {
    return CreatePagePoll(
      title: title ?? this.title,
      question: question ?? this.question,
      choices: choices ?? this.choices,
      location: location ?? this.location,
      radius: radius ?? this.radius,
      parameter: parameter ?? this.parameter,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      docRef: docRef ?? this.docRef,
    );
  }
}

class CreatePageSavePoll extends CreateState {
  const CreatePageSavePoll({
    required String title,
    required String question,
    required List<Choice> choices,
    required LatLng location,
    required double radius,
    required String parameter,
    required DateTime startDate,
    required DateTime endDate,
    String? docRef,
  }) : super(
          title: title,
          question: question,
          choices: choices,
          location: location,
          radius: radius,
          parameter: parameter,
          startDate: startDate,
          endDate: endDate,
          docRef: docRef,
        );

  @override
  CreatePageSavePoll copyWith({
    String? title,
    String? question,
    List<Choice>? choices,
    LatLng? location,
    double? radius,
    String? parameter,
    DateTime? startDate,
    DateTime? endDate,
    String? docRef,
  }) {
    return CreatePageSavePoll(
      title: title ?? this.title,
      question: question ?? this.question,
      choices: choices ?? this.choices,
      location: location ?? this.location,
      radius: radius ?? this.radius,
      parameter: parameter ?? this.parameter,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      docRef: docRef ?? this.docRef,
    );
  }
}

class CreatePageError extends CreateState {
  const CreatePageError({
    required String title,
    required String question,
    required List<Choice> choices,
    required LatLng location,
    required double radius,
    required String parameter,
    required DateTime startDate,
    required DateTime endDate,
    String? docRef,
  }) : super(
          title: title,
          question: question,
          choices: choices,
          location: location,
          radius: radius,
          parameter: parameter,
          startDate: startDate,
          endDate: endDate,
          docRef: docRef,
        );

  @override
  CreatePageError copyWith({
    String? title,
    String? question,
    List<Choice>? choices,
    LatLng? location,
    double? radius,
    String? parameter,
    DateTime? startDate,
    DateTime? endDate,
    String? docRef,
  }) {
    return CreatePageError(
      title: title ?? this.title,
      question: question ?? this.question,
      choices: choices ?? this.choices,
      location: location ?? this.location,
      radius: radius ?? this.radius,
      parameter: parameter ?? this.parameter,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      docRef: docRef ?? this.docRef,
    );
  }
}
