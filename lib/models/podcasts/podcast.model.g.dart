// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Podcast _$PodcastFromJson(Map<String, dynamic> json) => Podcast(
      json['podcastId'] as int?,
      json['image'] as String?,
      json['genres'] as String?,
      json['rss'] as String?,
      json['email'] as String?,
      (json['episodes'] as List<dynamic>?)
          ?.map((e) => Episode.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['title'] as String?,
      json['country'] as String?,
      json['website'] as String?,
      json['language'] as String?,
      json['publisher'] as String?,
      json['description'] as String?,
      json['shortDescription'] as String?,
      json['totalEpisodes'] as int?,
      json['explicitContent'] as bool?,
      json['latestPubDate'] as int?,
      json['roomId'] as int?,
      json['rank'] as int?,
      json['lastUpdate'] == null
          ? null
          : DateTime.parse(json['lastUpdate'] as String),
      (json['rewardTokens'] as List<dynamic>?)
          ?.map((e) => PodcastRewardDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    )..id = json['id'] as int?;

Map<String, dynamic> _$PodcastToJson(Podcast instance) => <String, dynamic>{
      'id': instance.id,
      'podcastId': instance.podcastId,
      'image': instance.image,
      'genres': instance.genres,
      'rss': instance.rss,
      'email': instance.email,
      'episodes': instance.episodes,
      'title': instance.title,
      'country': instance.country,
      'website': instance.website,
      'language': instance.language,
      'publisher': instance.publisher,
      'description': instance.description,
      'shortDescription': instance.shortDescription,
      'totalEpisodes': instance.totalEpisodes,
      'explicitContent': instance.explicitContent,
      'latestPubDate': instance.latestPubDate,
      'roomId': instance.roomId,
      'rank': instance.rank,
      'lastUpdate': instance.lastUpdate?.toIso8601String(),
      'rewardTokens': instance.rewardTokens,
    };
