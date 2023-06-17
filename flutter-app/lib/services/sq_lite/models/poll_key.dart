import 'package:json_annotation/json_annotation.dart';

part 'poll_key.g.dart';

@JsonSerializable()
class PollKey {
  final String pollId;
  final String key;
  final String alreadyVoted;

  PollKey({
    required this.pollId,
    required this.key,
    bool alreadyVotedBool = false,
  }) : alreadyVoted = alreadyVotedBool ? 'true' : 'false';

  factory PollKey.fromJson(Map<String, dynamic> json) =>
      _$PollKeyFromJson(json);

  Map<String, Object?> toJson() =>
      Map<String, Object?>.from(_$PollKeyToJson(this));
}
