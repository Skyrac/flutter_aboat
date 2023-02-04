// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stormm-mission.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StormmMission _$StormmMissionFromJson(Map<String, dynamic> json) =>
    StormmMission(
      json['requiredLikes'] as int,
      json['requiredRetweets'] as int,
      json['url'] as String,
      json['remainingTime'] as String,
    );

Map<String, dynamic> _$StormmMissionToJson(StormmMission instance) =>
    <String, dynamic>{
      'requiredLikes': instance.requiredLikes,
      'requiredRetweets': instance.requiredRetweets,
      'url': instance.url,
      'remainingTime': instance.remainingTime,
    };
