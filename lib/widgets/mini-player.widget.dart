import 'package:Talkaboat/widgets/player-control.widget.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:rxdart/rxdart.dart';

import '../injection/injector.dart';
import '../models/podcasts/episode.model.dart';
import '../screens/podcast-detail.screen.dart';
import '../services/audio/audio-handler.services.dart';
import '../services/audio/media.state.dart';
import '../services/state/state.service.dart';
import '../utils/common.dart';

class MiniPlayerWidget extends StatefulWidget {
  MiniPlayerWidget({Key? key, required this.episode}) : super(key: key);
  final Episode? episode;

  @override
  State<MiniPlayerWidget> createState() => _MiniPlayerWidgetState();
}

class _MiniPlayerWidgetState extends State<MiniPlayerWidget> {
  Episode? currentEpisode;
  late final audioHandler = getIt<AudioPlayerHandler>();
  final stateHandler = getIt<StateService>();
  late AnimationController _controller;

  @override
  initState() {
    super.initState();
    stateHandler.setMiniplayerFunction(() => setState(() {}));
  }

  /// A stream reporting the combined state of the current media item and its
  /// current position.
  Stream<MediaState> get _mediaStateStream =>
      Rx.combineLatest2<MediaItem?, Duration, MediaState>(
          audioHandler.mediaItem,
          AudioService.position,
          (mediaItem, position) => MediaState(mediaItem, position));

  @override
  Widget build(BuildContext context) {
    if (widget.episode == null) {
      return SizedBox();
    }
    Size deviceSize = MediaQuery.of(context).size;
    return Container(
      color: Theme.of(context).bottomAppBarColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
            child: InkWell(
              onTap: (() async => {
              Navigator.push(
              context,
              PageTransition(
              alignment: Alignment.bottomCenter,
              curve: Curves.bounceOut,
              type: PageTransitionType.rightToLeftWithFade,
              duration: const Duration(milliseconds: 500),
              reverseDuration: const Duration(milliseconds: 500),
              child: PodcastDetailScreen(podcastId: widget.episode?.podcastId)))
              }),
              child: Text(
                widget.episode!.title!,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: Colors.black),
              ),
            ),
          ),
          Container(
            height: 10,
            width: deviceSize.width,
            child: StreamBuilder<MediaState>(
              stream: _mediaStateStream,
              builder: (context, snapshot) {
                final mediaState = snapshot.data;
                return SeekBar(
                  duration: mediaState?.mediaItem?.duration ?? Duration.zero,
                  position: mediaState?.position ?? Duration.zero,
                  onChangeEnd: (newPosition) {
                    audioHandler.seek(newPosition);
                  },
                );
              },
            ),
          ),
          AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: deviceSize.width,
              height: 45,
              child: PlayerControlWidget()),
        ],
      ),
    );
  }
}
