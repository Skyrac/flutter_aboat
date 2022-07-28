import 'package:Talkaboat/services/repositories/social.repository.dart';
import '../../models/user/social-user.model.dart';
import '../../models/user/user-info.model.dart';

class SocialService {

  String lastQueue = "";
  List<SocialUser> queueResult = List.empty(growable: true);
  List<SocialUser> friends = List.empty(growable: true);
  List<SocialUser> pendingFriends = List.empty(growable: true);

  isFriend(int? userId) => friends.isNotEmpty
      && friends.any((element) => element.userId == userId);

  isPending(int? userId) => pendingFriends.isNotEmpty
      && pendingFriends.any((element) => element.userId == userId);

  Future<List<SocialUser>> getFriends({refresh = true}) async {
    if(refresh || friends.isEmpty) {
      friends = await SocialRepository.getFriends();
    }
    return friends;
  }

  Future<List<SocialUser>> getPendingFriends({refresh = true}) async {
    if(refresh || pendingFriends.isEmpty) {
      pendingFriends = await SocialRepository.getPendingFriends();
    }
    return pendingFriends;
  }

  Future<List<SocialUser>> getFriendRequests() async {
    var friendRequests = await SocialRepository.getFriendRequests();
    return friendRequests;
  }

  Future<List<SocialUser>> requestFriends(SocialUser user) async {
    print("Request Friend");
    if(!friends.any((element) => element.userId == user.userId)) {
      print("No Friend yet");
      if(pendingFriends.any((element) => element.userId == user.userId)) {
        //pullback
        print("Pullback");
        var success = await SocialRepository.pullbackFriend(user.userId!);
        if(success) {
          pendingFriends.removeWhere((element) => element.userId == user.userId);
        }
      } else {
        //request friendship
        print("Request Friend");
        var success = await SocialRepository.requestFriend(user.userId!);
        if(success) {
          pendingFriends.add(user);
        }
      }
    }
    return pendingFriends;
  }




  Future<List<SocialUser>> searchFriends(String identifier) async {
    if(identifier != lastQueue && identifier.isNotEmpty) {
      lastQueue = identifier;
      queueResult = await SocialRepository.searchFriends(identifier);
    } else if(identifier.isEmpty) {
      return [];
    }
    return queueResult;
  }

}