// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'choice.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Choice _$ChoiceFromJson(Map json) => Choice(
      choice: json['choice'] as String,
      choiceId: json['choiceId'] as int,
      counter: json['counter'] as int,
    );

Map<String, dynamic> _$ChoiceToJson(Choice instance) => <String, dynamic>{
      'choice': instance.choice,
      'choiceId': instance.choiceId,
      'counter': instance.counter,
    };
