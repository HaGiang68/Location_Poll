import 'package:json_annotation/json_annotation.dart';

part 'poll_ids_request.g.dart';

@JsonSerializable()
class PollIdsRequest {
  PollIdsRequest({
    required this.pollIds,
  });

  final List<String> pollIds;

  factory PollIdsRequest.fromJson(Map<String, dynamic> json) =>
      _$PollIdsRequestFromJson(json);

  Map<String, Object?> toJson() =>
      Map<String, Object?>.from(_$PollIdsRequestToJson(this));
}
