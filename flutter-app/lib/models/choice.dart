import 'package:json_annotation/json_annotation.dart';

part 'choice.g.dart';

@JsonSerializable(anyMap: true, explicitToJson: true)
class Choice {
  late final String choice;
  late final int choiceId;
  late final int counter;

  Choice({
    required this.choice,
    required this.choiceId,
    required this.counter,
  });

  factory Choice.fromJson(Map<String, dynamic> json) => _$ChoiceFromJson(json);

  Choice.fromFirebase(Map<String, dynamic> data) {
    choice = data['choice'] ?? '';
    choiceId = data['choiceId'] ?? 0;
    counter = data['counter'] ?? 0;
  }

  Map<String, Object?> toJson() =>
      Map<String, Object?>.from(_$ChoiceToJson(this));
}
