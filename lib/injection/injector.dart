import 'package:audio_service/audio_service.dart';
import 'package:get_it/get_it.dart';
import 'package:talkaboat/services/audio/audio-handler.services.dart';
import 'package:talkaboat/services/user/user.service.dart';

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
}
