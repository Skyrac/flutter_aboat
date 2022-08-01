import 'package:Talkaboat/services/repositories/social.repository.dart';
import '../../models/user/social-user.model.dart';
import '../../models/user/user-info.model.dart';

class SocialService {

  String lastQueue = "";
  List<SocialUser> queueResult = List.empty(growable: true);
  List<SocialUser> friends = List.empty(growable: true);
  List<SocialUser> pendingFriends = List.empty(growable: true);
  List<SocialUser> friendRequests = List.empty(growable: true);

  isFriend(int? userId) => friends.isNotEmpty
      && friends.any((element) => element.userId == userId);

  isPending(int? userId) => pendingFriends.isNotEmpty
      && pendingFriends.any((element) => element.userId == userId);

  isRequest(int? userId) => friendRequests.isNotEmpty
      && friendRequests.any((element) => element.userId == userId);

  getPendingAndFriendsLocally()  {
    List<SocialUser> list = List.empty(growable: true);
    if(friendRequests.isNotEmpty) {
      list.addAll(friendRequests);
    }
    if(friends.isNotEmpty) {
      list.addAll(friends);
    }
    if(pendingFriends.isNotEmpty) {
      list.addAll(pendingFriends);
    }
    return list;
  }


  Future initialize() async {
    await getFriends();
    await getPendingFriends();
    await getFriendRequests();
  }

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
    friendRequests = await SocialRepository.getFriendRequests();
    return friendRequests;
  }

  Future<List<SocialUser>> requestFriends(SocialUser user) async {
    if(!friends.any((element) => element.userId == user.userId)) {
      if(pendingFriends.any((element) => element.userId == user.userId)) {
        var success = await SocialRepository.pullbackFriend(user.userId!);
        if(success) {
          pendingFriends.removeWhere((element) => element.userId == user.userId);
        }
      } else {
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

  Future<bool> acceptFriend(SocialUser? user) async {
    var success = false;
    if(user != null) {

      print("try add friend");
      success = await SocialRepository.acceptFriendRequest(user.userId!);
      if(success) {
        print("accepted friend");
        friends.add(user);
        friendRequests.remove(user);
      }
    }
    return success;
  }

  Future<bool> declineFriend(SocialUser? user) async {
    var success = false;
    if(user != null) {
      success = await SocialRepository.declineFriendRequest(user.userId!);
      if(success) {
        friendRequests.remove(user);
      }
    }
    return success;
  }

  Future<bool> removeFriend(SocialUser? user) async {
    var success = false;
    if(user != null) {
      success = await SocialRepository.removeFriend(user.userId!);
      if(success) {
        friends.remove(user);
      }
    }
    return success;
  }

}