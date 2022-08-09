import 'package:jiffy/jiffy.dart';

class RewardDetail {
  num? amount;
  String? description;
  String? earnDate;
  String? unlockDate;

  RewardDetail({this.amount, this.description, this.earnDate, this.unlockDate});

  RewardDetail.fromJson(Map<String, dynamic> json) {
    amount = json['amount'];
    description = json['description'];
    earnDate = json['earnDate'];
    unlockDate = json['unlockDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['amount'] = this.amount;
    data['description'] = this.description;
    data['earnDate'] = this.earnDate;
    data['unlockDate'] = this.unlockDate;
    return data;
  }

  getEarnDate() {
    return Jiffy(earnDate!).yMMMd; // DateTime.parse(created!).
  }
  getUnlockDate() {
    return Jiffy(unlockDate!).yMMMd; // DateTime.parse(created!).
  }
}