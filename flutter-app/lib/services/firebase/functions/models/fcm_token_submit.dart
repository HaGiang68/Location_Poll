import 'package:json_annotation/json_annotation.dart';

part 'fcm_token_submit.g.dart';

@JsonSerializable()
class FCMTokenSubmit {
  FCMTokenSubmit({
    required this.token,
  });

  final String token;

  factory FCMTokenSubmit.fromJson(Map<String, dynamic> json) =>
      _$FCMTokenSubmitFromJson(json);

  Map<String, Object?> toJson() =>
      Map<String, Object?>.from(_$FCMTokenSubmitToJson(this));
}
