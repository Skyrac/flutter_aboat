import 'package:Talkaboat/models/rewards/reward-detail.model.dart';
import 'package:Talkaboat/models/rewards/reward.model.dart';
import 'package:Talkaboat/services/repositories/user.repository.dart';
import 'package:flutter/foundation.dart';

class RewardService extends ValueNotifier<Reward> {
  RewardService({Reward? value}) : super(value ?? Reward());

  void Update(Reward newValue) {
    value = newValue;
  }

  getRewards() async {
    value = await UserRepository.getUserRewards();
  }

  Future<List<RewardDetail>> getUserRewardDetails() async {
    return await UserRepository.getDetailedUserRewards();
  }
}
