// -- user_data.dart --
import 'package:json_annotation/json_annotation.dart';

part 'user-info-model.g.dart';

@JsonSerializable()
class UserInfoData {
  String? userName;
  String? email;
  bool? verified;
  List<String>? addresses;
  int? rewards;
  int? referrer;
  bool? ambassador;
  Badge? userBadge;
  bool? artist;
  late int? userId;

  UserInfoData({
    this.userName,
    this.email,
    this.verified,
    this.addresses,
    this.rewards,
    this.referrer,
    this.ambassador,
    this.userBadge,
    this.artist,
  });

  factory UserInfoData.fromJson(Map<String, dynamic> json) => _$UserInfoDataFromJson(json);

  Map<String, dynamic> toJson() => _$UserInfoDataToJson(this);
}

@JsonSerializable()
class Badge {
  String? name;
  int? vesting;
  double? multiplier;
  int? rewardLimit;
  double? referrerRewardMultiplier;
  int? dailyTasks;
  int? rank;

  Badge({
    required this.name,
    required this.vesting,
    required this.multiplier,
    required this.rewardLimit,
    required this.referrerRewardMultiplier,
    required this.dailyTasks,
    required this.rank,
  });

  factory Badge.fromJson(Map<String, dynamic> json) => _$BadgeFromJson(json);

  Map<String, dynamic> toJson() => _$BadgeToJson(this);
}
