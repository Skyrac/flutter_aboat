import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/services/repositories/token.repository.dart';
import 'package:Talkaboat/services/user/reward.service.dart';

class TokenService {
  final rewardService = getIt<RewardService>();

  Future<num> donate(int podcastId, double amount) async {
    var result = await TokenRepository.donateAboatToPodcast(podcastId, amount);
    await rewardService.getRewards();
    return rewardService.value.vested ?? 0;
  }
}
