// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user-info-model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserInfoData _$UserInfoDataFromJson(Map<String, dynamic> json) => UserInfoData(
      userName: json['userName'] as String?,
      email: json['email'] as String?,
      verified: json['verified'] as bool?,
      addresses: (json['addresses'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      rewards: json['rewards'] as int?,
      referrer: json['referrer'] as int?,
      ambassador: json['ambassador'] as bool?,
      userBadge: json['userBadge'] == null
          ? null
          : Badge.fromJson(json['userBadge'] as Map<String, dynamic>),
      artist: json['artist'] as bool?,
    )..userId = json['userId'] as int?;

Map<String, dynamic> _$UserInfoDataToJson(UserInfoData instance) =>
    <String, dynamic>{
      'userName': instance.userName,
      'email': instance.email,
      'verified': instance.verified,
      'addresses': instance.addresses,
      'rewards': instance.rewards,
      'referrer': instance.referrer,
      'ambassador': instance.ambassador,
      'userBadge': instance.userBadge,
      'artist': instance.artist,
      'userId': instance.userId,
    };

Badge _$BadgeFromJson(Map<String, dynamic> json) => Badge(
      name: json['name'] as String?,
      vesting: json['vesting'] as int?,
      multiplier: (json['multiplier'] as num?)?.toDouble(),
      rewardLimit: json['rewardLimit'] as int?,
      referrerRewardMultiplier:
          (json['referrerRewardMultiplier'] as num?)?.toDouble(),
      dailyTasks: json['dailyTasks'] as int?,
      rank: json['rank'] as int?,
    );

Map<String, dynamic> _$BadgeToJson(Badge instance) => <String, dynamic>{
      'name': instance.name,
      'vesting': instance.vesting,
      'multiplier': instance.multiplier,
      'rewardLimit': instance.rewardLimit,
      'referrerRewardMultiplier': instance.referrerRewardMultiplier,
      'dailyTasks': instance.dailyTasks,
      'rank': instance.rank,
    };
