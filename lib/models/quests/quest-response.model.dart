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
        currentQuests!.add(Quest.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['remainingQuests'] = remainingQuests;
    if (currentQuests != null) {
      data['currentQuests'] = currentQuests!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
