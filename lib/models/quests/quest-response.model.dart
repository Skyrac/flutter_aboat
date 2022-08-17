import 'package:Talkaboat/models/quests/quest.model.dart';

class QuestResponse {
  int? remainingQuests;
  List<Quest>? currentQuests;

  QuestResponse({this.remainingQuests, this.currentQuests});

  QuestResponse.fromJson(Map<String, dynamic> json) {
    remainingQuests = json['remainingQuests'];
    if (json['currentQuests'] != null) {
      currentQuests = <Quest>[];
      json['currentQuests'].forEach((v) {
        currentQuests!.add(new Quest.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['remainingQuests'] = this.remainingQuests;
    if (this.currentQuests != null) {
      data['currentQuests'] =
          this.currentQuests!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}