import 'package:Talkaboat/services/hubs/reward/reward-hub.service.dart';
import 'package:Talkaboat/utils/preference-keys.const.dart';
import 'package:audio_service/audio_service.dart';
import 'package:provider/provider.dart';
import '../../injection/injector.dart';
import '../../models/podcasts/episode.model.dart';
import '../user/store.service.dart';
import 'audio-handler.services.dart';

int heartbeatCounter = 0;
const heartbeatLimit = 10;
MediaItem? currentlyPlayingMediaItem;
Function? setEpisode;
RewardHubService _rewardHub = getIt<RewardHubService>();
StoreService _store = getIt<StoreService>();

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
      await _store.set("${PreferenceKeys.episodePlaytime}${episodeId}", playTime);
      await _rewardHub.Heartbeat(podcastId, episodeId, playTime);
    }
  }
}
