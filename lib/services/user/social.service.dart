import 'package:Talkaboat/services/repositories/social.repository.dart';
import '../../models/user/social-user.model.dart';
import '../../models/user/user-info.model.dart';

class SocialService {

  String lastQueue = "";
  List<SocialUser> queueResult = List.empty();

  Future<List<SocialUser>> searchFriends(String identifier) async {
    if(identifier != lastQueue) {
      lastQueue = identifier;
      queueResult = await SocialRepository.searchFriends(identifier);
    }
    return queueResult;
  }

}