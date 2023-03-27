// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast_reward_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PodcastRewardDto _$PodcastRewardDtoFromJson(Map<String, dynamic> json) =>
    PodcastRewardDto(
      json['name'] as String,
      json['symbol'] as String,
      json['address'] as String,
      json['chain'] as String,
      (json['remaining'] as num).toDouble(),
      (json['rewardPerMinute'] as num).toDouble(),
      json['dailyTimeLimit'] as int,
    );

Map<String, dynamic> _$PodcastRewardDtoToJson(PodcastRewardDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'symbol': instance.symbol,
      'address': instance.address,
      'chain': instance.chain,
      'remaining': instance.remaining,
      'rewardPerMinute': instance.rewardPerMinute,
      'dailyTimeLimit': instance.dailyTimeLimit,
    };
