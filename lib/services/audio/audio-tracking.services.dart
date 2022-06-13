import 'package:audio_service/audio_service.dart';
import 'package:talkaboat/services/repositories/tracking.repository.dart';

int heartbeatCounter = 0;
const heartbeatLimit = 30;
Future<void> receiveUpdate(
    PlaybackState state, MediaItem? currentMediaItem, Duration position) async {
  if (currentMediaItem != null) {
    var playTime = position.inSeconds;
    int podcastId = currentMediaItem.extras!["podcastId"];
    int episodeId = currentMediaItem.extras!["episodeId"];
    if (state.playing) {
      await TrackingRepository.Play(podcastId, episodeId, playTime);
    } else if (!state.playing) {
      await TrackingRepository.Pause(podcastId, episodeId, playTime);
    }
  }
}

Future<void> positionUpdate(
    Duration position, MediaItem? currentMediaItem) async {
  if (currentMediaItem != null) {
    heartbeatCounter++;
    if (heartbeatCounter > heartbeatLimit) {
      heartbeatCounter = 0;
      var playTime = position.inSeconds;
      int podcastId = currentMediaItem.extras!["podcastId"];
      int episodeId = currentMediaItem.extras!["episodeId"];
      print("Heartbeat!");
      await TrackingRepository.Heartbeat(podcastId, episodeId, playTime);
    }
  }
}
