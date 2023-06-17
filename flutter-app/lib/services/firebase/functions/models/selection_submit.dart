import 'package:json_annotation/json_annotation.dart';

part 'selection_submit.g.dart';

@JsonSerializable()
class SelectionSubmit {
  SelectionSubmit({
    required this.key,
    required this.pollId,
    required this.answers,
  });

  final String key;
  final String pollId;
  final Map<int, int> answers;

  factory SelectionSubmit.fromJson(Map<String, dynamic> json) =>
      _$SelectionSubmitFromJson(json);

  Map<String, Object?> toJson() =>
      Map<String, Object?>.from(_$SelectionSubmitToJson(this));
}
