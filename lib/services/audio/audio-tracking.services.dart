import 'package:audio_service/audio_service.dart';
import 'package:talkaboat/models/podcasts/episode.model.dart';
import 'package:talkaboat/services/repositories/tracking.repository.dart';

int heartbeatCounter = 0;
const heartbeatLimit = 30;
MediaItem? currentlyPlayingMediaItem;
Function? setEpisode;

Future<void> receiveUpdate(PlaybackState state, MediaItem? currentMediaItem,
    Duration position, Episode? episode) async {
  currentlyPlayingMediaItem = currentMediaItem;
  if (currentMediaItem != null) {
    var playTime = position.inSeconds;
    int podcastId = currentMediaItem.extras!["podcastId"];
    int episodeId = currentMediaItem.extras!["episodeId"];
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
      int podcastId = currentMediaItem.extras!["podcastId"];
      int episodeId = currentMediaItem.extras!["episodeId"];
      await TrackingRepository.Heartbeat(podcastId, episodeId, playTime);
    }
  }
}
