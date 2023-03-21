import 'package:Talkaboat/services/hubs/chat/chat.service.dart';
import 'package:Talkaboat/services/hubs/reward/reward-hub.service.dart';
import 'package:Talkaboat/services/hubs/live/live-session.service.dart';
import 'package:Talkaboat/services/quests/quest.service.dart';
import 'package:Talkaboat/services/user/reward.service.dart';
import 'package:Talkaboat/services/user/social.service.dart';
import 'package:Talkaboat/services/videos/youtube/youtube-video.service.dart';
import 'package:Talkaboat/services/web3/token.service.dart';
import 'package:audio_service/audio_service.dart';
import 'package:get_it/get_it.dart';

import '../services/audio/audio-handler.services.dart';
import '../services/audio/podcast.service.dart';
import '../services/state/state.service.dart';
import '../services/user/user.service.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  getIt.registerSingleton<AudioPlayerHandler>(await AudioService.init(
      builder: () => AudioPlayerHandlerImpl(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.aboat.talkaboat.channel.audio',
        androidNotificationChannelName: 'Talkaboat Audio',
        androidNotificationOngoing: true,
      )));

  getIt.registerSingleton(SocialService());
  getIt.registerSingleton(RewardService());
  getIt.registerSingleton(await UserService.init());
  getIt.registerSingleton(PodcastService());
  getIt.registerSingleton(StateService());
  getIt.registerSingleton(TokenService());
  getIt.registerSingleton(QuestService());
  getIt.registerSingleton(RewardHubService());
  getIt.registerSingleton(ChatService());
  getIt.registerSingleton(LiveSessionService());
  getIt.registerSingleton(YouTubeVideoService());
}
