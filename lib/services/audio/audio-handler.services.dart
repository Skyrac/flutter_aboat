import 'dart:io';

import 'package:Talkaboat/services/downloading/file-downloader.service.dart';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

import '../../models/podcasts/episode.model.dart';
import '../../utils/common.dart';
import 'audio-tracking.services.dart';

/// An [AudioHandler] for playing a list of podcast episodes.
///
/// This class exposes the interface and not the implementation.
abstract class AudioPlayerHandler implements AudioHandler {
  Stream<QueueState> get queueState;
  Future<void> moveQueueItem(int currentIndex, int newIndex);
  ValueStream<double> get volume;
  Future<void> setVolume(double volume);
  ValueStream<double> get speed;
  Future<void> updateEpisodeQueue(List<Episode> episodes, {int index = 0});
  bool isListeningEpisode(episodeId);
  bool isListeningPodcast(podcastId);
  void setEpisodeRefreshFunction(Function setEpisode) {}

  void togglePlaybackState() {}
}

/// The implementation of [AudioPlayerHandler].
///
/// This handler is backed by a just_audio player. The player's effective
/// sequence is mapped onto the handler's queue, and the player's state is
/// mapped onto the handler's state.
class AudioPlayerHandlerImpl extends BaseAudioHandler with SeekHandler implements AudioPlayerHandler {
  List<Episode>? episodes;
  // ignore: close_sinks
  final BehaviorSubject<List<MediaItem>> _recentSubject = BehaviorSubject.seeded(<MediaItem>[]);
  // final _mediaLibrary = MediaLibrary();
  final _player = AudioPlayer();
  final _playlist = ConcatenatingAudioSource(children: []);
  @override
  final BehaviorSubject<double> volume = BehaviorSubject.seeded(1.0);
  @override
  final BehaviorSubject<double> speed = BehaviorSubject.seeded(1.0);
  final _mediaItemExpando = Expando<MediaItem>();

  @override
  bool isListeningPodcast(podcastId) {
    var currentlyPlayingPodcastId = currentlyPlayingMediaItem?.extras!["podcastId"];
    return currentlyPlayingPodcastId == podcastId;
  }

  @override
  bool isListeningEpisode(episodeId) {
    var currentlyPlayingEpisodeId = currentlyPlayingMediaItem?.extras!["episodeId"];
    return currentlyPlayingEpisodeId == episodeId;
  }

  @override
  void togglePlaybackState() {
    _player.playing ? pause() : play();
  }

  /// A stream of the current effective sequence from just_audio.
  Stream<List<IndexedAudioSource>> get _effectiveSequence =>
      Rx.combineLatest3<List<IndexedAudioSource>?, List<int>?, bool, List<IndexedAudioSource>?>(
          _player.sequenceStream, _player.shuffleIndicesStream, _player.shuffleModeEnabledStream,
          (sequence, shuffleIndices, shuffleModeEnabled) {
        if (sequence == null) return [];
        if (!shuffleModeEnabled) return sequence;
        if (shuffleIndices == null) return null;
        if (shuffleIndices.length != sequence.length) return null;
        return shuffleIndices.map((i) => sequence[i]).toList();
      }).whereType<List<IndexedAudioSource>>();

  /// Computes the effective queue index taking shuffle mode into account.
  int? getQueueIndex(int? currentIndex, bool shuffleModeEnabled, List<int>? shuffleIndices) {
    final effectiveIndices = _player.effectiveIndices ?? [];
    final shuffleIndicesInv = List.filled(effectiveIndices.length, 0);
    for (var i = 0; i < effectiveIndices.length; i++) {
      shuffleIndicesInv[effectiveIndices[i]] = i;
    }
    return (shuffleModeEnabled && ((currentIndex ?? 0) < shuffleIndicesInv.length))
        ? shuffleIndicesInv[currentIndex ?? 0]
        : currentIndex;
  }

  /// A stream reporting the combined state of the current queue and the current
  /// media item within that queue.
  @override
  Stream<QueueState> get queueState => Rx.combineLatest3<List<MediaItem>, PlaybackState, List<int>, QueueState>(
      queue,
      playbackState,
      _player.shuffleIndicesStream.whereType<List<int>>(),
      (queue, playbackState, shuffleIndices) => QueueState(
            queue,
            playbackState.queueIndex,
            playbackState.shuffleMode == AudioServiceShuffleMode.all ? shuffleIndices : null,
            playbackState.repeatMode,
          )).where((state) => state.shuffleIndices == null || state.queue.length == state.shuffleIndices!.length);

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    final enabled = shuffleMode == AudioServiceShuffleMode.all;
    if (enabled) {
      await _player.shuffle();
    }
    playbackState.add(playbackState.value.copyWith(shuffleMode: shuffleMode));
    await _player.setShuffleModeEnabled(enabled);
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    playbackState.add(playbackState.value.copyWith(repeatMode: repeatMode));
    await _player.setLoopMode(LoopMode.values[repeatMode.index]);
  }

  @override
  Future<void> setSpeed(double speed) async {
    this.speed.add(speed);
    await _player.setSpeed(speed);
  }

  @override
  Future<void> setVolume(double volume) async {
    this.volume.add(volume);
    await _player.setVolume(volume);
  }

  AudioPlayerHandlerImpl() {
    _init();
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
    // Broadcast speed changes. Debounce so that we don't flood the notification
    // with updates.
    speed.debounceTime(const Duration(milliseconds: 250)).listen((speed) {
      playbackState.add(playbackState.value.copyWith(speed: speed));
    });
    // Load and broadcast the initial queue
    // await updateQueue(_mediaLibrary.items[MediaLibrary.albumsRootId]!);
    // For Android 11, record the most recent item so it can be resumed.
    mediaItem.whereType<MediaItem>().listen((item) => _recentSubject.add([item]));
    // Broadcast media item changes.
    Rx.combineLatest4<int?, List<MediaItem>, bool, List<int>?, MediaItem?>(
        _player.currentIndexStream, queue, _player.shuffleModeEnabledStream, _player.shuffleIndicesStream,
        (index, queue, shuffleModeEnabled, shuffleIndices) {
      final queueIndex = getQueueIndex(index, shuffleModeEnabled, shuffleIndices);
      return (queueIndex != null && queueIndex < queue.length) ? queue[queueIndex] : null;
    }).whereType<MediaItem>().distinct().listen(mediaItem.add);
    // Propagate all events from the audio player to AudioService clients.
    _player.playbackEventStream.listen(_broadcastState);
    _player.shuffleModeEnabledStream.listen((enabled) => _broadcastState(_player.playbackEvent));
    // In this example, the service stops when reaching the end.
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        stop();
        _player.seek(Duration.zero, index: 0);
      }
    });
    // Broadcast the current queue.
    _effectiveSequence.map((sequence) => sequence.map((source) => _mediaItemExpando[source]!).toList()).pipe(queue);
    AudioService.position.listen((event) async => await positionUpdate(event, mediaItem.value));
    playbackState.listen((PlaybackState state) async => await receiveUpdate(
        state, mediaItem.value, _player.position, episodes == null ? null : episodes![_player.currentIndex!]));
  }

  AudioSource _itemToSource(MediaItem mediaItem) {
    final audioSource = AudioSource.uri(Uri.parse(mediaItem.id));
    _mediaItemExpando[audioSource] = mediaItem;
    return audioSource;
  }

  List<AudioSource> _itemsToSources(List<MediaItem> mediaItems) => mediaItems.map(_itemToSource).toList();

  // @override
  // Future<List<MediaItem>> getChildren(String parentMediaId,
  //     [Map<String, dynamic>? options]) async {
  //   switch (parentMediaId) {
  //     case AudioService.recentRootId:
  //       // When the user resumes a media session, tell the system what the most
  //       // recently played item was.
  //       return _recentSubject.value;
  //     default:
  //       // Allow client to browse the media library.
  //       return _mediaLibrary.items[parentMediaId]!;
  //   }
  // }

  // @override
  // ValueStream<Map<String, dynamic>> subscribeToChildren(String parentMediaId) {
  //   switch (parentMediaId) {
  //     case AudioService.recentRootId:
  //       final stream = _recentSubject.map((_) => <String, dynamic>{});
  //       return _recentSubject.hasValue
  //           ? stream.shareValueSeeded(<String, dynamic>{})
  //           : stream.shareValue();
  //     default:
  //       return Stream.value(_mediaLibrary.items[parentMediaId])
  //           .map((_) => <String, dynamic>{})
  //           .shareValue();
  //   }
  // }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    await _playlist.add(_itemToSource(mediaItem));
  }

  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems) async {
    await _playlist.addAll(_itemsToSources(mediaItems));
  }

  @override
  Future<void> insertQueueItem(int index, MediaItem mediaItem) async {
    await _playlist.insert(index, _itemToSource(mediaItem));
  }

  @override
  Future<void> updateQueue(List<MediaItem> queue, {bool autoPlay = true, int index = 0}) async {
    await _player.pause();
    await _playlist.clear();
    await _playlist.addAll(_itemsToSources(queue));

    await _player.setAudioSource(_playlist);
    var continueTime = queue[index].extras!["playTime"];
    await _player.seek(Duration(seconds: continueTime ?? 0), index: index);
    if (autoPlay) {
      await _player.play();
    }
  }

  Future<MediaItem> convertEpisodeToMediaItem(Episode episode) async {
    var playTime = episode.playTime!;
    if (episode.audioLengthSec! < episode.playTime! + 20) {
      playTime = 0;
    }
    final episodeId = episode.episodeId;
    final podcastId = episode.podcastId;
    final Map<String, dynamic> extraMap = {"episodeId": episodeId, "podcastId": podcastId, "playTime": playTime};
    var file = (await FileDownloadService.getFile(episode.audio!))?.file.path;
    if (file != null && Platform.isIOS) {
      file = "file:$file";
    }
    var id = file ?? episode.audio!;

    final mediaItem = MediaItem(
        id: id,
        duration: Duration(seconds: episode.audioLengthSec! as int),
        album: episode.podcast != null && episode.podcast!.title != null ? episode.podcast!.title! : '',
        artUri: Uri.parse(episode.image ?? episode.podcast?.image ?? ''),
        title: episode.title!,
        extras: extraMap);
    return mediaItem;
  }

  @override
  Future<void> updateEpisodeQueue(List<Episode> episodes, {int index = 0}) async {
    this.episodes = episodes;
    await updateQueue(
        (await Future.wait(episodes.map((episode) async => await convertEpisodeToMediaItem(episode)))).toList(),
        index: index);
  }

  @override
  Future<void> updateMediaItem(MediaItem mediaItem) async {
    final index = queue.value.indexWhere((item) => item.id == mediaItem.id);
    _mediaItemExpando[_player.sequence![index]] = mediaItem;
  }

  @override
  Future<void> removeQueueItem(MediaItem mediaItem) async {
    final index = queue.value.indexOf(mediaItem);
    await _playlist.removeAt(index);
  }

  @override
  Future<void> moveQueueItem(int currentIndex, int newIndex) async {
    await _playlist.move(currentIndex, newIndex);
  }

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= _playlist.children.length) return;
    // This jumps to the beginning of the queue item at [index].
    _player.seek(Duration.zero, index: _player.shuffleModeEnabled ? _player.shuffleIndices![index] : index);
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() async {
    await _player.stop();
    await playbackState.firstWhere((state) => state.processingState == AudioProcessingState.idle);
  }

  /// Broadcasts the current state to all clients.
  void _broadcastState(PlaybackEvent event) {
    final playing = _player.playing;
    final queueIndex = getQueueIndex(event.currentIndex, _player.shuffleModeEnabled, _player.shuffleIndices);
    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.skipToPrevious,
        MediaControl.rewind,
        if (playing) MediaControl.pause else MediaControl.play,
        MediaControl.fastForward,
        MediaControl.skipToNext,
      ],
      systemActions: {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 2, 4],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: queueIndex,
    ));
  }

  @override
  void setEpisodeRefreshFunction(Function setEpisodeFunction) {
    setEpisode = setEpisodeFunction;
  }
}
