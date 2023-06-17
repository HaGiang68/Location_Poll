// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'poll.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Poll _$PollFromJson(Map json) => Poll(
      title: json['title'] as String,
      owner: User.fromJson(Map<String, dynamic>.from(json['owner'] as Map)),
      questions: (json['questions'] as List<dynamic>)
          .map((e) => Question.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      requirements: Requirements.fromJson(
          Map<String, dynamic>.from(json['requirements'] as Map)),
    );

Map<String, dynamic> _$PollToJson(Poll instance) => <String, dynamic>{
      'title': instance.title,
      'owner': instance.owner.toJson(),
      'questions': instance.questions.map((e) => e.toJson()).toList(),
      'requirements': instance.requirements.toJson(),
    };
