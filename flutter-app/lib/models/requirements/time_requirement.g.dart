// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_requirement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimeRequirement _$TimeRequirementFromJson(Map json) => TimeRequirement(
      startTime: _dateTimeFromJson(json['startTime'] as int),
      endTime: _dateTimeFromJson(json['endTime'] as int),
    );

Map<String, dynamic> _$TimeRequirementToJson(TimeRequirement instance) =>
    <String, dynamic>{
      'startTime': _dateTimeToJson(instance.startTime),
      'endTime': _dateTimeToJson(instance.endTime),
    };
