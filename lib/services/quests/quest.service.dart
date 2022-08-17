import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/models/quests/quest.model.dart';
import 'package:Talkaboat/services/user/user.service.dart';

import '../repositories/quest.repository.dart';

class QuestService {
  final userService = getIt<UserService>();
  List<Quest> quests = List<Quest>.empty(growable: true);
  var remainingQuests = 0;
  var isWaitingForResponse = false;
  var response;

  hasQuests() => quests.isNotEmpty;

  Future<List<Quest>> getOpenQuests() async {
    if(isWaitingForResponse) {
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
    if(rewards == null) {
      return false;
    }
    userService.updateRewards(rewards);
    return true;
  }

}