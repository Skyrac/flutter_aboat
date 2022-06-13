import 'package:audio_service/audio_service.dart';
import 'package:talkaboat/services/repositories/tracking.repository.dart';

int heartbeatCounter = 0;
const heartbeatLimit = 10;
Future<void> receiveUpdate(
    PlaybackState state, MediaItem? currentMediaItem) async {
  print(state);
}

Future<void> positionUpdate(
    Duration position, MediaItem? currentMediaItem) async {
  heartbeatCounter++;
  if (heartbeatCounter > heartbeatLimit) {
    heartbeatCounter = 0;
    TrackingRepository.Heartbeat(currentMediaItem?.extras?["podcastId"],
        currentMediaItem?.extras?["episodeId"], position.inSeconds);
  }
}
