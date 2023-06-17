import 'package:json_annotation/json_annotation.dart';

part 'time_requirement.g.dart';

@JsonSerializable(anyMap: true, explicitToJson: true)
class TimeRequirement {
  TimeRequirement({
    required this.startTime,
    required this.endTime,
  });

  @JsonKey(toJson: _dateTimeToJson, fromJson: _dateTimeFromJson)
  final DateTime startTime;
  @JsonKey(toJson: _dateTimeToJson, fromJson: _dateTimeFromJson)
  final DateTime endTime;

  factory TimeRequirement.fromJson(Map<String, dynamic> json) =>
      _$TimeRequirementFromJson(json);

  Map<String, Object?> toJson() =>
      Map<String, Object?>.from(_$TimeRequirementToJson(this));
}

int _dateTimeToJson(DateTime dateTime) => dateTime.millisecondsSinceEpoch;

DateTime _dateTimeFromJson(int json) =>
    DateTime.fromMillisecondsSinceEpoch(json);
