// -- stormm_mission.dart --
import 'package:json_annotation/json_annotation.dart';

part 'stormm-mission.model.g.dart';

@JsonSerializable()
class StormmMission {
  int requiredLikes;
  int requiredRetweets;
  String url;
  Duration remainingTime;

  StormmMission(this.requiredLikes,this.requiredRetweets,this.url,this.remainingTime,);

  factory StormmMission.fromJson(Map<String, dynamic> json) => _$StormmMissionFromJson(json);

  Map<String, dynamic> toJson() => _$StormmMissionToJson(this);
}