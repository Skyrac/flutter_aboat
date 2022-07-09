import 'package:audio_service/audio_service.dart';
import '../../models/podcasts/episode.model.dart';
import '../repositories/tracking.repository.dart';

int heartbeatCounter = 0;
const heartbeatLimit = 30;
MediaItem? currentlyPlayingMediaItem;
Function? setEpisode;

Future<void> receiveUpdate(PlaybackState state, MediaItem? currentMediaItem,
    Duration position, Episode? episode) async {
  currentlyPlayingMediaItem = currentMediaItem;
  if (currentMediaItem != null) {
    var playTime = position.inSeconds;
    int podcastId = currentMediaItem.extras!["podcastId"] ?? 0;
    int episodeId = currentMediaItem.extras!["episodeId"] ?? 0;
    if (state.playing) {
      if (setEpisode != null && episode != null) {
        setEpisode!(episode);
      }
      await TrackingRepository.Play(podcastId, episodeId, playTime);
    } else if (!state.playing) {
      if (setEpisode != null && episode != null) {
        setEpisode!(episode);
      }
      await TrackingRepository.Pause(podcastId, episodeId, playTime);
    }
  }
}

Future<void> positionUpdate(
    Duration position, MediaItem? currentMediaItem) async {
  currentlyPlayingMediaItem = currentMediaItem;
  if (currentMediaItem != null) {
    heartbeatCounter++;
    if (heartbeatCounter > heartbeatLimit) {
      heartbeatCounter = 0;
      var playTime = position.inSeconds;
      int podcastId = currentMediaItem.extras!["podcastId"] ?? 0;
      int episodeId = currentMediaItem.extras!["episodeId"] ?? 0;
      await TrackingRepository.Heartbeat(podcastId, episodeId, playTime);
    }
  }
}
