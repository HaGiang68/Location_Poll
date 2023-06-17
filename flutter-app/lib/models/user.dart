import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable(explicitToJson: true)
class User {
  User({
    required this.userName,
    required this.uuid,
  });

  final String userName;
  final String uuid;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, Object?> toJson() =>
      Map<String, Object?>.from(_$UserToJson(this));
}
