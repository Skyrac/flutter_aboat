import 'package:Talkaboat/models/quests/quest.model.dart';

import '../repositories/quest.repository.dart';

class QuestService {

  List<Quest> quests = List<Quest>.empty(growable: true);
  var remainingQuests = 0;

  hasQuests() => quests.isNotEmpty;

  Future<List<Quest>> getOpenQuests() async {
    var response = await QuestRepository.getOpenQuests();
    quests = response?.currentQuests ?? List.empty();
    remainingQuests = response?.remainingQuests ?? 0;
    print(quests);
    return quests;
  }

}