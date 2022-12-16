import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/models/quests/quest-response.model.dart';
import 'package:Talkaboat/models/quests/quest.model.dart';
import 'package:Talkaboat/services/user/reward.service.dart';

import '../repositories/quest.repository.dart';

class QuestService {
  final rewardService = getIt<RewardService>();
  List<Quest> quests = List<Quest>.empty(growable: true);
  var remainingQuests = 0;
  var isWaitingForResponse = false;
  QuestResponse? response;

  hasQuests() => quests.isNotEmpty;

  Future<List<Quest>> getOpenQuests() async {
    if (isWaitingForResponse) {
      return finishRequest();
    }
    isWaitingForResponse = true;
    response = await QuestRepository.getOpenQuests();
    return finishRequest();
  }

  finishRequest() {
    isWaitingForResponse = false;
    quests = response?.currentQuests ?? List.empty();
    remainingQuests = response?.remainingQuests ?? 0;
    return quests;
  }

  Future<bool> finishQuest(Quest quest) async {
    var rewards = await QuestRepository.finishQuest(quest);
    if (rewards == null) {
      return false;
    }
    rewardService.Update(rewards);
    return true;
  }
}
