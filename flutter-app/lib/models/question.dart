import 'package:json_annotation/json_annotation.dart';
import 'package:location_poll/models/choice.dart';

part 'question.g.dart';

@JsonSerializable(anyMap: true, explicitToJson: true)
class Question {
  late final String question;
  late final int questionId;
  late final List<Choice> choices;

  Question({
    required this.question,
    required this.questionId,
    required this.choices,
  });

  factory Question.fromJson(Map<String, dynamic> json) =>
      _$QuestionFromJson(json);

  Map<String, Object?> toJson() =>
      Map<String, Object?>.from(_$QuestionToJson(this));
}
