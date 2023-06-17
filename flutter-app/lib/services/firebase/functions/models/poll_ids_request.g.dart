// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'poll_ids_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PollIdsRequest _$PollIdsRequestFromJson(Map<String, dynamic> json) =>
    PollIdsRequest(
      pollIds:
          (json['pollIds'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$PollIdsRequestToJson(PollIdsRequest instance) =>
    <String, dynamic>{
      'pollIds': instance.pollIds,
    };
