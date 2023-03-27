// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'episode.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Episode _$EpisodeFromJson(Map<String, dynamic> json) => Episode(
      json['episodeId'] as int?,
      json['podcastId'] as int?,
      json['link'] as String?,
      json['podcast'] == null
          ? null
          : Podcast.fromJson(json['podcast'] as Map<String, dynamic>),
      json['audio'] as String?,
      json['image'] as String?,
      json['title'] as String?,
      json['transcript'] as String?,
      json['description'] as String?,
      json['pubDateInMilliseconds'] as int?,
      json['audioLengthInSeconds'] as int?,
      json['explicitContent'] as bool?,
      json['playTime'] as int?,
      json['isDeleted'] as bool?,
      json['roomId'] as int?,
    )..id = json['id'] as int?;

Map<String, dynamic> _$EpisodeToJson(Episode instance) => <String, dynamic>{
      'id': instance.id,
      'episodeId': instance.episodeId,
      'podcastId': instance.podcastId,
      'link': instance.link,
      'podcast': instance.podcast,
      'audio': instance.audio,
      'image': instance.image,
      'title': instance.title,
      'transcript': instance.transcript,
      'description': instance.description,
      'pubDateInMilliseconds': instance.pubDateInMilliseconds,
      'audioLengthInSeconds': instance.audioLengthInSeconds,
      'explicitContent': instance.explicitContent,
      'playTime': instance.playTime,
      'isDeleted': instance.isDeleted,
      'roomId': instance.roomId,
    };
