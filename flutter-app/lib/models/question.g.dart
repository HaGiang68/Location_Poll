// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Question _$QuestionFromJson(Map json) => Question(
      question: json['question'] as String,
      questionId: json['questionId'] as int,
      choices: (json['choices'] as List<dynamic>)
          .map((e) => Choice.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

Map<String, dynamic> _$QuestionToJson(Question instance) => <String, dynamic>{
      'question': instance.question,
      'questionId': instance.questionId,
      'choices': instance.choices.map((e) => e.toJson()).toList(),
    };
