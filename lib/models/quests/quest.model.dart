import 'package:Talkaboat/models/quests/quest-reward.model.dart';

class Quest {
  int? userQuestId;
  int? userId;
  int? questId;
  int? referenceId;
  String? name;
  String? description;
  num? requirement;
  int? questType;
  List<QuestReward>? rewards;
  int? rewardType;
  String? start;
  Null? end;
  Null? finished;
  num? progress;

  Quest(
      {this.userQuestId,
        this.userId,
        this.questId,
        this.referenceId,
        this.name,
        this.description,
        this.requirement,
        this.questType,
        this.rewards,
        this.rewardType,
        this.start,
        this.end,
        this.finished,
        this.progress});

  Quest.fromJson(Map<String, dynamic> json) {
    userQuestId = json['userQuestId'];
    userId = json['userId'];
    questId = json['questId'];
    referenceId = json['referenceId'];
    name = json['name'];
    description = json['description'];
    requirement = json['requirement'];
    questType = json['questType'];
    if (json['rewards'] != null) {
      rewards = <QuestReward>[];
      json['rewards'].forEach((v) {
        rewards!.add(new QuestReward.fromJson(v));
      });
    }
    rewardType = json['rewardType'];
    start = json['start'];
    end = json['end'];
    finished = json['finished'];
    progress = json['progress'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userQuestId'] = this.userQuestId;
    data['userId'] = this.userId;
    data['questId'] = this.questId;
    data['referenceId'] = this.referenceId;
    data['name'] = this.name;
    data['description'] = this.description;
    data['requirement'] = this.requirement;
    data['questType'] = this.questType;
    if (this.rewards != null) {
      data['rewards'] = this.rewards!.map((v) => v.toJson()).toList();
    }
    data['rewardType'] = this.rewardType;
    data['start'] = this.start;
    data['end'] = this.end;
    data['finished'] = this.finished;
    data['progress'] = this.progress;
    return data;
  }
}