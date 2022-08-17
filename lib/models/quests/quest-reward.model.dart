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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['questId'] = this.questId;
    data['rewardType'] = this.rewardType;
    data['amount'] = this.amount;
    return data;
  }
}