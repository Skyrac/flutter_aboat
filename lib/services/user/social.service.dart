import 'package:Talkaboat/services/repositories/social.repository.dart';
import '../../models/user/social-user.model.dart';
import '../../models/user/user-info.model.dart';

class SocialService {

  Future<List<SocialUser>> searchFriends(String identifier) async {
    var potentialFriends = await SocialRepository.searchFriends(identifier);
    return potentialFriends;
  }

}