import 'package:audio_service/audio_service.dart';

Future<void> receiveUpdate(
    PlaybackState state, MediaItem? currentMediaItem) async {
  print(state);
}

Future<void> positionUpdate(
    Duration position, MediaItem? currentMediaItem) async {
  print(currentMediaItem?.extras!['episodeId']);
}
