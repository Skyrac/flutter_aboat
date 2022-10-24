import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
  const MiniPlayerWidget({Key? key, required this.episode}) : super(key: key);
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
      return const SizedBox();
    }
    Size deviceSize = MediaQuery.of(context).size;
    final id = widget.episode!.id!;
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      width: deviceSize.width * 0.9,
      height: 56,
      decoration: BoxDecoration(
          color: const Color.fromRGBO(29, 40, 58, 0.7),
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 6,
            width: deviceSize.width * 0.9,
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
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
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
                            child: PodcastDetailScreen(
                                podcastId: widget.episode?.podcastId)))
                  }),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Stack(
                    alignment: Alignment.bottomLeft,
                    children: [
                      ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                              height: 50,
                              width: 50,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CachedNetworkImage(
                                    imageUrl: widget.episode!.image ??
                                        'https://picsum.photos/200',
                                    fit: BoxFit.fill,
                                    placeholder: (_, __) => const Center(
                                        child: CircularProgressIndicator()),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                  ),
                                ],
                              )))
                    ],
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.episode!.title!,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: Colors.white),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            removeAllHtmlTags(widget.episode!.description!),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 0, 5, 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        StreamBuilder<PlaybackState>(
                          stream: audioHandler.playbackState,
                          builder: (context, snapshot) {
                            final playbackState = snapshot.data;
                            final processingState =
                                playbackState?.processingState;
                            final playing = playbackState?.playing;
                            if (processingState ==
                                    AudioProcessingState.loading ||
                                processingState ==
                                    AudioProcessingState.buffering) {
                              return Container(
                                margin: const EdgeInsets.fromLTRB(0, 0, 10, 8),
                                width: 16.0,
                                height: 16.0,
                                child: const CircularProgressIndicator(),
                              );
                            } else if (playing != true) {
                              return IconButton(
                                color: const Color.fromRGBO(99, 163, 253, 1),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: const Icon(Icons.play_arrow),
                                iconSize: 34.0,
                                onPressed: audioHandler.play,
                              );
                            } else {
                              return IconButton(
                                color: const Color.fromRGBO(99, 163, 253, 1),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: const Icon(Icons.pause),
                                iconSize: 34.0,
                                onPressed: audioHandler.pause,
                              );
                            }
                          },
                        ),
                        Container(
                          padding: const EdgeInsets.only(right: 7),
                          child: Row(
                            children: [
                              Text(
                                '$id',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                        fontSize: 10, color: Colors.white),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Image.asset(
                                'assets/images/aboat.png',
                                width: 10,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String removeAllHtmlTags(String htmlText) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);

    return htmlText.replaceAll(exp, '');
  }
}
