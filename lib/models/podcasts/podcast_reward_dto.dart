// -- podcast_reward_dto.dart --
import 'package:json_annotation/json_annotation.dart';

part 'podcast_reward_dto.g.dart';

@JsonSerializable()
class PodcastRewardDto {
  String name;
  String symbol;
  String address;
  String chain;
  double remaining;
  double rewardPerMinute;
  int dailyTimeLimit;

  PodcastRewardDto(this.name,this.symbol,this.address,this.chain,this.remaining,this.rewardPerMinute,this.dailyTimeLimit,);

  factory PodcastRewardDto.fromJson(Map<String, dynamic> json) => _$PodcastRewardDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PodcastRewardDtoToJson(this);
}