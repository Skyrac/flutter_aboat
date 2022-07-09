import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/services/repositories/token.repository.dart';
import 'package:Talkaboat/services/user/user.service.dart';

class TokenService {
  final userService = getIt<UserService>();

  Future<num> donate(int podcastId, double amount) async {

    var result = await TokenRepository.donateAboatToPodcast(podcastId, amount);
    await userService.getRewards();
    return userService.rewards.vested ?? 0;
  }
}