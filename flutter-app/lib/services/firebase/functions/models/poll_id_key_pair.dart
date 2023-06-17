import 'package:json_annotation/json_annotation.dart';

part 'poll_id_key_pair.g.dart';

@JsonSerializable()
class PollIdKeyPair {
  final String key;
  @JsonKey(name: 'poll_id')
  final String pollId;

  PollIdKeyPair({
    required this.key,
    required this.pollId,
  });

  factory PollIdKeyPair.fromJson(Map<String, dynamic> json) =>
      _$PollIdKeyPairFromJson(json);

  Map<String, Object?> toJson() =>
      Map<String, Object?>.from(_$PollIdKeyPairToJson(this));
}
