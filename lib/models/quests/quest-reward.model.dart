class QuestReward {
  int? id;
  int? questId;
  int? rewardType;
  int? amount;

  QuestReward({this.id, this.questId, this.rewardType, this.amount});

  QuestReward.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    questId = json['questId'];
    rewardType = json['rewardType'];
    amount = json['amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['questId'] = questId;
    data['rewardType'] = rewardType;
    data['amount'] = amount;
    return data;
  }

  getName() {
    switch (rewardType) {
      case 0:
        return "Aboat Token";
      default:
        return "Name undefined";
    }
  }
}
