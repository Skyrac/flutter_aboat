import 'package:Talkaboat/services/repositories/social.repository.dart';
import '../../models/user/social-user.model.dart';
import '../../models/user/user-info.model.dart';

class SocialService {

  String lastQueue = "";
  List<SocialUser> queueResult = List.empty();
  List<SocialUser> friends = List.empty();
  List<SocialUser> pendingFriends = List.empty();

  Future<List<SocialUser>> getFriends({refresh = true}) async {
    if(refresh || friends.isEmpty) {
      friends = await SocialRepository.getFriends();
    }
    return friends;
  }

  Future<List<SocialUser>> requestFriends(SocialUser user) async {
    if(!friends.any((element) => element.userId == user.userId)) {
      if(pendingFriends.any((element) => element.userId == user.userId)) {
        //pullback
      } else {
        //request friendship

      }
    }
    return friends;
  }

  Future<List<SocialUser>> searchFriends(String identifier) async {
    if(identifier != lastQueue) {
      lastQueue = identifier;
      queueResult = await SocialRepository.searchFriends(identifier);
    }
    return queueResult;
  }

}