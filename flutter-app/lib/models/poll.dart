import 'package:json_annotation/json_annotation.dart';
import 'package:location_poll/models/question.dart';
import 'package:location_poll/models/requirements/requirements.dart';
import 'package:location_poll/models/user.dart';

part 'poll.g.dart';

@JsonSerializable(anyMap: true, explicitToJson: true)
class Poll {
  Poll({
    required this.title,
    required this.owner,
    required this.questions,
    required this.requirements,
    this.documentReference,
    this.voteKey,
    this.isEditable = false,
    this.alreadyVoted = false,
    this.isDeletable = false,
  });

  final String title;
  final User owner;
  final List<Question> questions;
  final Requirements requirements;
  @JsonKey(ignore: true)
  String? documentReference;
  @JsonKey(ignore: true)
  String? voteKey;
  @JsonKey(ignore: true)
  bool isEditable;
  @JsonKey(ignore: true)
  bool alreadyVoted;
  @JsonKey(ignore: true)
  bool isDeletable;

  factory Poll.fromJson(Map<String, dynamic> json) => _$PollFromJson(json);

  Map<String, Object?> toJson() =>
      Map<String, Object?>.from(_$PollToJson(this));

  Poll copyWith({
    String? title,
    User? owner,
    List<Question>? questions,
    Requirements? requirements,
    String? documentReference,
    String? voteKey,
    bool? isEditable,
    bool? alreadyVoted,
    bool? isDeletable,
  }) {
    return Poll(
      title: title ?? this.title,
      owner: owner ?? this.owner,
      questions: questions ?? this.questions,
      requirements: requirements ?? this.requirements,
      documentReference: documentReference ?? this.documentReference,
      voteKey: voteKey ?? this.voteKey,
      isEditable: isEditable ?? this.isEditable,
      alreadyVoted: alreadyVoted ?? this.alreadyVoted,
      isDeletable: isDeletable ?? this.isDeletable,
    );
  }
}
