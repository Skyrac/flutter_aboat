// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'youtube-video-simple.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

YoutubeVideoSimple _$YoutubeVideoSimpleFromJson(Map<String, dynamic> json) =>
    YoutubeVideoSimple(
      json['id'] as String,
      json['url'] as String,
      json['title'] as String,
      json['thumbnailUrl'] as String,
      json['duration'] as String,
      json['author'] as String,
    );

Map<String, dynamic> _$YoutubeVideoSimpleToJson(YoutubeVideoSimple instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'title': instance.title,
      'thumbnailUrl': instance.thumbnailUrl,
      'duration': instance.duration,
      'author': instance.author,
    };
