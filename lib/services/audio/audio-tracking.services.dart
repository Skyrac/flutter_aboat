import 'package:Talkaboat/services/hubs/reward/reward-hub.service.dart';
import 'package:audio_service/audio_service.dart';
import '../../injection/injector.dart';
import '../../models/podcasts/episode.model.dart';

int heartbeatCounter = 0;
const heartbeatLimit = 10;
MediaItem? currentlyPlayingMediaItem;
Function? setEpisode;
RewardHubService _rewardHub = getIt<RewardHubService>();

Future<void> receiveUpdate(PlaybackState state, MediaItem? currentMediaItem, Duration position, Episode? episode) async {
  currentlyPlayingMediaItem = currentMediaItem;
  if (currentMediaItem != null) {
    var playTime = position.inSeconds;
    int podcastId = currentMediaItem.extras!["podcastId"] ?? 0;
    int episodeId = currentMediaItem.extras!["episodeId"] ?? 0;
    if (state.playing) {
      if (setEpisode != null && episode != null) {
        setEpisode!(episode);
      }
      await _rewardHub.Play(podcastId, episodeId, playTime);
    } else if (!state.playing) {
      if (setEpisode != null && episode != null) {
        setEpisode!(episode);
      }
      await _rewardHub.Pause(podcastId, episodeId, playTime);
    }
  }
}

Future<void> positionUpdate(Duration position, MediaItem? currentMediaItem) async {
  currentlyPlayingMediaItem = currentMediaItem;
  if (currentMediaItem != null) {
    heartbeatCounter++;
    if (heartbeatCounter > heartbeatLimit) {
      heartbeatCounter = 0;
      var playTime = position.inSeconds;
      currentMediaItem.extras!["playTime"] = playTime;
      int podcastId = currentMediaItem.extras!["podcastId"] ?? 0;
      int episodeId = currentMediaItem.extras!["episodeId"] ?? 0;
      await _rewardHub.Heartbeat(podcastId, episodeId, playTime);
    }
  }
}
