import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

Widget buildCategoryBadges(BuildContext context, String genres) {
  final genreList = genres.split(",").asMap().entries;
  return Align(
    alignment: Alignment.centerLeft,
    child: SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: genreList
            .map(
              (entry) => Container(
                  margin: EdgeInsets.only(bottom: 10, left: entry.key > 0 ? 5 : 0),
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(10), color: const Color.fromRGBO(188, 140, 75, 1)),
                  width: 100,
                  height: 35,
                  child: Center(
                      child: Text(entry.value,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: const TextStyle(color: Color.fromRGBO(15, 23, 41, 1))))),
            )
            .toList(),
      ),
    ),
  );
}

String removeAllHtmlTags(String htmlText) {
  RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);

  return htmlText.replaceAll(exp, '');
}

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  PositionData(this.position, this.bufferedPosition, this.duration);
}

String formatTime(int seconds) {
  return '${(Duration(seconds: seconds))}'.split('.')[0].padLeft(8, '0');
}

class CustomTrackShape extends RoundedRectSliderTrackShape {
  final bool isMiniPlayer;
  CustomTrackShape(this.isMiniPlayer);

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double? trackHeight = sliderTheme.trackHeight;
    final double trackLeft = offset.dx;
    final double trackTop = offset.dy + (parentBox.size.height - trackHeight!) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, isMiniPlayer ? trackTop : trackTop - 2, trackWidth, isMiniPlayer ? 20 : 10);
  }
}

class SeekBar extends StatefulWidget {
  final Color? color;
  final bool? isPlay;
  final bool isMiniPlayer;
  final Duration duration;
  final Duration position;
  final Duration bufferedPosition;
  final ValueChanged<Duration>? onChanged;
  final ValueChanged<Duration>? onChangeEnd;

  const SeekBar({
    Key? key,
    required this.isMiniPlayer,
    required this.duration,
    required this.position,
    this.bufferedPosition = Duration.zero,
    this.onChanged,
    this.isPlay,
    this.color,
    this.onChangeEnd,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SeekBarState createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  double? _dragValue;
  bool _dragging = false;
  late SliderThemeData _sliderThemeData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _sliderThemeData = SliderTheme.of(context).copyWith(
      trackHeight: 5.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final value = min(
      _dragValue ?? widget.position.inMilliseconds.toDouble(),
      widget.duration.inMilliseconds.toDouble(),
    );
    if (_dragValue != null && !_dragging) {
      _dragValue = null;
    }
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Positioned(
          width: size.width,
          child: SliderTheme(
            data: _sliderThemeData.copyWith(
              trackShape: CustomTrackShape(widget.isMiniPlayer),
              thumbShape: HiddenThumbComponentShape(),
              activeTrackColor: Colors.blue.shade100,
              inactiveTrackColor: Colors.grey.shade300,
            ),
            child: ExcludeSemantics(
              child: Slider(
                min: 0.0,
                max: widget.duration.inMilliseconds.toDouble(),
                value: min(widget.bufferedPosition.inMilliseconds.toDouble(), widget.duration.inMilliseconds.toDouble()),
                onChanged: (value) {},
              ),
            ),
          ),
        ),
        SizedBox(
          width: size.width,
          child: SliderTheme(
            data: _sliderThemeData.copyWith(
              trackShape: CustomTrackShape(widget.isMiniPlayer),
              thumbShape: HiddenThumbComponentShape(),
              activeTrackColor: widget.isMiniPlayer ? Color.fromRGBO(99, 163, 253, 1) : widget.color,
              inactiveTrackColor:
                  widget.isMiniPlayer ? const Color.fromRGBO(62, 62, 62, 1) : const Color.fromRGBO(15, 23, 41, 1),
            ),
            child: Slider(
              min: 0.0,
              max: widget.duration.inMilliseconds.toDouble(),
              value: value,
              onChanged: (value) {
                if (!_dragging) {
                  _dragging = true;
                }
                setState(() {
                  _dragValue = value;
                });
                if (widget.onChanged != null) {
                  widget.onChanged!(Duration(milliseconds: value.round()));
                }
              },
              onChangeEnd: (value) {
                if (widget.onChangeEnd != null) {
                  widget.onChangeEnd!(Duration(milliseconds: value.round()));
                }
                _dragging = false;
              },
            ),
          ),
        ),
        widget.isMiniPlayer
            ? Positioned(
                top: 0,
                right: 0,
                child: ClipPath(
                    clipper: CustomClipperRightCorner(), // <--
                    child: Container(
                      width: 10,
                      height: 6,
                      color: const Color.fromRGBO(15, 23, 41, 1),
                    )))
            : SizedBox(),
        widget.isMiniPlayer
            ? Positioned(
                top: 0,
                left: 0,
                child: ClipPath(
                    clipper: CustomClipperLeftCorner(), // <--
                    child: Container(
                      width: 10,
                      height: 6,
                      color: const Color.fromRGBO(15, 23, 41, 1),
                    )))
            : SizedBox(),
      ],
    );
  }

  // Duration get _remaining => widget.duration - widget.position;
}

class CustomClipperRightCorner extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double radius = 10;
    Path path = Path()
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..arcToPoint(const Offset(0, 0), radius: Radius.circular(radius), clockwise: false)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class CustomClipperLeftCorner extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double radius = 10;
    Path path = Path()
      ..lineTo(size.width, 0)
      ..arcToPoint(Offset(0, size.height), radius: Radius.circular(radius), clockwise: false)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class HiddenThumbComponentShape extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size.zero;

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {}
}

class LoggingAudioHandler extends CompositeAudioHandler {
  LoggingAudioHandler(AudioHandler inner) : super(inner) {
    playbackState.listen((state) {
      _log('playbackState changed: $state');
    });
    queue.listen((queue) {
      _log('queue changed: $queue');
    });
    queueTitle.listen((queueTitle) {
      _log('queueTitle changed: $queueTitle');
    });
    mediaItem.listen((mediaItem) {
      _log('mediaItem changed: $mediaItem');
    });
    ratingStyle.listen((ratingStyle) {
      _log('ratingStyle changed: $ratingStyle');
    });
    androidPlaybackInfo.listen((androidPlaybackInfo) {
      _log('androidPlaybackInfo changed: $androidPlaybackInfo');
    });
    customEvent.listen((dynamic customEventStream) {
      _log('customEvent changed: $customEventStream');
    });
    customState.listen((dynamic customState) {
      _log('customState changed: $customState');
    });
  }

  // ignore: todo
  // TODO: Use logger. Use different log levels.
  // ignore: avoid_print
  void _log(String s) => print('----- LOG: $s');

  @override
  Future<void> prepare() {
    _log('prepare()');
    return super.prepare();
  }

  @override
  Future<void> prepareFromMediaId(String mediaId, [Map<String, dynamic>? extras]) {
    _log('prepareFromMediaId($mediaId, $extras)');
    return super.prepareFromMediaId(mediaId, extras);
  }

  @override
  Future<void> prepareFromSearch(String query, [Map<String, dynamic>? extras]) {
    _log('prepareFromSearch($query, $extras)');
    return super.prepareFromSearch(query, extras);
  }

  @override
  Future<void> prepareFromUri(Uri uri, [Map<String, dynamic>? extras]) {
    _log('prepareFromSearch($uri, $extras)');
    return super.prepareFromUri(uri, extras);
  }

  @override
  Future<void> play() {
    _log('play()');
    return super.play();
  }

  @override
  Future<void> playFromMediaId(String mediaId, [Map<String, dynamic>? extras]) {
    _log('playFromMediaId($mediaId, $extras)');
    return super.playFromMediaId(mediaId, extras);
  }

  @override
  Future<void> playFromSearch(String query, [Map<String, dynamic>? extras]) {
    _log('playFromSearch($query, $extras)');
    return super.playFromSearch(query, extras);
  }

  @override
  Future<void> playFromUri(Uri uri, [Map<String, dynamic>? extras]) {
    _log('playFromUri($uri, $extras)');
    return super.playFromUri(uri, extras);
  }

  @override
  Future<void> playMediaItem(MediaItem mediaItem) {
    _log('playMediaItem($mediaItem)');
    return super.playMediaItem(mediaItem);
  }

  @override
  Future<void> pause() {
    _log('pause()');
    return super.pause();
  }

  @override
  Future<void> click([MediaButton button = MediaButton.media]) {
    _log('click($button)');
    return super.click(button);
  }

  @override
  Future<void> stop() {
    _log('stop()');
    return super.stop();
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) {
    _log('addQueueItem($mediaItem)');
    return super.addQueueItem(mediaItem);
  }

  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems) {
    _log('addQueueItems($mediaItems)');
    return super.addQueueItems(mediaItems);
  }

  @override
  Future<void> insertQueueItem(int index, MediaItem mediaItem) {
    _log('insertQueueItem($index, $mediaItem)');
    return super.insertQueueItem(index, mediaItem);
  }

  @override
  Future<void> updateQueue(List<MediaItem> queue) {
    _log('updateQueue($queue)');
    return super.updateQueue(queue);
  }

  @override
  Future<void> updateMediaItem(MediaItem mediaItem) {
    _log('updateMediaItem($mediaItem)');
    return super.updateMediaItem(mediaItem);
  }

  @override
  Future<void> removeQueueItem(MediaItem mediaItem) {
    _log('removeQueueItem($mediaItem)');
    return super.removeQueueItem(mediaItem);
  }

  @override
  Future<void> removeQueueItemAt(int index) {
    _log('removeQueueItemAt($index)');
    return super.removeQueueItemAt(index);
  }

  @override
  Future<void> skipToNext() {
    _log('skipToNext()');
    return super.skipToNext();
  }

  @override
  Future<void> skipToPrevious() {
    _log('skipToPrevious()');
    return super.skipToPrevious();
  }

  @override
  Future<void> fastForward() {
    _log('fastForward()');
    return super.fastForward();
  }

  @override
  Future<void> rewind() {
    _log('rewind()');
    return super.rewind();
  }

  @override
  Future<void> skipToQueueItem(int index) {
    _log('skipToQueueItem($index)');
    return super.skipToQueueItem(index);
  }

  @override
  Future<void> seek(Duration position) {
    _log('seek($position)');
    return super.seek(position);
  }

  @override
  Future<void> setRating(Rating rating, [Map<String, dynamic>? extras]) {
    _log('setRating($rating, $extras)');
    return super.setRating(rating, extras);
  }

  @override
  Future<void> setCaptioningEnabled(bool enabled) {
    _log('setCaptioningEnabled($enabled)');
    return super.setCaptioningEnabled(enabled);
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) {
    _log('setRepeatMode($repeatMode)');
    return super.setRepeatMode(repeatMode);
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) {
    _log('setShuffleMode($shuffleMode)');
    return super.setShuffleMode(shuffleMode);
  }

  @override
  Future<void> seekBackward(bool begin) {
    _log('seekBackward($begin)');
    return super.seekBackward(begin);
  }

  @override
  Future<void> seekForward(bool begin) {
    _log('seekForward($begin)');
    return super.seekForward(begin);
  }

  @override
  Future<void> setSpeed(double speed) {
    _log('setSpeed($speed)');
    return super.setSpeed(speed);
  }

  @override
  Future<dynamic> customAction(String name, [Map<String, dynamic>? extras]) async {
    _log('customAction($name, extras)');
    final dynamic result = await super.customAction(name, extras);
    _log('customAction -> $result');
    return result;
  }

  @override
  Future<void> onTaskRemoved() {
    _log('onTaskRemoved()');
    return super.onTaskRemoved();
  }

  @override
  Future<void> onNotificationDeleted() {
    _log('onNotificationDeleted()');
    return super.onNotificationDeleted();
  }

  @override
  Future<List<MediaItem>> getChildren(String parentMediaId, [Map<String, dynamic>? options]) async {
    _log('getChildren($parentMediaId, $options)');
    final result = await super.getChildren(parentMediaId, options);
    _log('getChildren -> $result');
    return result;
  }

  @override
  ValueStream<Map<String, dynamic>> subscribeToChildren(String parentMediaId) {
    _log('subscribeToChildren($parentMediaId)');
    final result = super.subscribeToChildren(parentMediaId);
    result.listen((options) {
      _log('$parentMediaId children changed with options $options');
    });
    return result;
  }

  @override
  Future<MediaItem?> getMediaItem(String mediaId) async {
    _log('getMediaItem($mediaId)');
    final result = await super.getMediaItem(mediaId);
    _log('getMediaItem -> $result');
    return result;
  }

  @override
  Future<List<MediaItem>> search(String query, [Map<String, dynamic>? extras]) async {
    _log('search($query, $extras)');
    final result = await super.search(query, extras);
    _log('search -> $result');
    return result;
  }

  @override
  Future<void> androidSetRemoteVolume(int volumeIndex) {
    _log('androidSetRemoteVolume($volumeIndex)');
    return super.androidSetRemoteVolume(volumeIndex);
  }

  @override
  Future<void> androidAdjustRemoteVolume(AndroidVolumeDirection direction) {
    _log('androidAdjustRemoteVolume($direction)');
    return super.androidAdjustRemoteVolume(direction);
  }
}

void showSliderDialog({
  required BuildContext context,
  required String title,
  required int divisions,
  required double min,
  required double max,
  String valueSuffix = '',
  // ignore: todo
  // TODO: Replace these two by ValueStream.
  required double value,
  required Stream<double> stream,
  required ValueChanged<double> onChanged,
}) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title, textAlign: TextAlign.center),
      content: StreamBuilder<double>(
        stream: stream,
        builder: (context, snapshot) => SizedBox(
          height: 100.0,
          child: Column(
            children: [
              Text('${snapshot.data?.toStringAsFixed(1)}$valueSuffix',
                  style: const TextStyle(fontFamily: 'Fixed', fontWeight: FontWeight.bold, fontSize: 24.0)),
              Slider(
                divisions: divisions,
                min: min,
                max: max,
                value: snapshot.data ?? value,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class QueueState {
  static const QueueState empty = QueueState([], 0, [], AudioServiceRepeatMode.none);

  final List<MediaItem> queue;
  final int? queueIndex;
  final List<int>? shuffleIndices;
  final AudioServiceRepeatMode repeatMode;

  const QueueState(this.queue, this.queueIndex, this.shuffleIndices, this.repeatMode);

  bool get hasPrevious => repeatMode != AudioServiceRepeatMode.none || (queueIndex ?? 0) > 0;
  bool get hasNext => repeatMode != AudioServiceRepeatMode.none || (queueIndex ?? 0) + 1 < queue.length;

  List<int> get indices => shuffleIndices ?? List.generate(queue.length, (i) => i);
}

class SelectEpisodePage extends ChangeNotifier {
  bool isSelectedPage = false;

  void changeTrue() {
    isSelectedPage = true;
    notifyListeners();
  }

  void changeFalse() {
    isSelectedPage = false;
    notifyListeners();
  }
}
