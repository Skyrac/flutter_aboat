import 'package:Talkaboat/services/user/social.service.dart';
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
  getIt.registerSingleton(await UserService.init());
  getIt.registerSingleton(PodcastService());
  getIt.registerSingleton(await StateService());
  getIt.registerSingleton(TokenService());
  getIt.registerSingleton(SocialService());
}
