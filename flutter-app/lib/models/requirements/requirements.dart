import 'package:json_annotation/json_annotation.dart';
import 'package:location_poll/models/requirements/auth_requirement.dart';
import 'package:location_poll/models/requirements/location_requirement.dart';
import 'package:location_poll/models/requirements/time_requirement.dart';

part 'requirements.g.dart';

@JsonSerializable(anyMap: true, explicitToJson: true)
class Requirements {
  Requirements({
    required this.authRequirement,
    required this.locationRequirement,
    required this.timeRequirement,
  });

  final AuthRequirement authRequirement;
  final LocationRequirement locationRequirement;
  final TimeRequirement timeRequirement;

  factory Requirements.fromJson(Map<String, dynamic> json) =>
      _$RequirementsFromJson(json);

  Map<String, Object?> toJson() =>
      Map<String, Object?>.from(_$RequirementsToJson(this));
}
