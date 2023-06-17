import 'package:json_annotation/json_annotation.dart';

part 'auth_requirement.g.dart';

enum AuthStage {
  @JsonValue("ANONYMOUS")
  anonymous,
  @JsonValue("MAIL_VERIFIED")
  mailVerified,
  @JsonValue("PHONE_VERIFIED")
  phoneVerified,
  @JsonValue("ID_VERIFIED")
  idVerified,
}

@JsonSerializable(anyMap: true, explicitToJson: true)
class AuthRequirement {
  AuthRequirement({
    required this.auth,
  });

  final AuthStage auth;

  factory AuthRequirement.fromJson(Map<String, dynamic> json) =>
      _$AuthRequirementFromJson(json);

  Map<String, Object?> toJson() =>
      Map<String, Object?>.from(_$AuthRequirementToJson(this));
}
