// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selection_submit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SelectionSubmit _$SelectionSubmitFromJson(Map<String, dynamic> json) =>
    SelectionSubmit(
      key: json['key'] as String,
      pollId: json['pollId'] as String,
      answers: (json['answers'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(int.parse(k), e as int),
      ),
    );

Map<String, dynamic> _$SelectionSubmitToJson(SelectionSubmit instance) =>
    <String, dynamic>{
      'key': instance.key,
      'pollId': instance.pollId,
      'answers': instance.answers.map((k, e) => MapEntry(k.toString(), e)),
    };
