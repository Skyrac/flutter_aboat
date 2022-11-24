import 'package:Talkaboat/screens/podcast-episode.screen.dart';
import 'package:Talkaboat/widgets/player-control.widget.dart';
import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:rxdart/rxdart.dart';

import '../injection/injector.dart';
import '../models/podcasts/episode.model.dart';
import '../services/audio/audio-handler.services.dart';
import '../services/audio/media.state.dart';
import '../services/state/state.service.dart';
import '../utils/common.dart';

class MiniPlayerWidget extends StatefulWidget {
  const MiniPlayerWidget(this.escapeWithNav, {Key? key, required this.episode, required this.navKey}) : super(key: key);
  final Episode? episode;
  final Function escapeWithNav;
  final GlobalKey<NavigatorState> navKey;

  @override
  State<MiniPlayerWidget> createState() => _MiniPlayerWidgetState();
}

class _MiniPlayerWidgetState extends State<MiniPlayerWidget> {
  Episode? currentEpisode;
  late final audioHandler = getIt<AudioPlayerHandler>();
  final stateHandler = getIt<StateService>();

  @override
  initState() {
    super.initState();
    stateHandler.setMiniplayerFunction(() => setState(() {}));
  }

  /// A stream reporting the combined state of the current media item and its
  /// current position.
  Stream<MediaState> get _mediaStateStream => Rx.combineLatest2<MediaItem?, Duration, MediaState>(
      audioHandler.mediaItem, AudioService.position, (mediaItem, position) => MediaState(mediaItem, position));

  @override
  Widget build(BuildContext context) {
    if (widget.episode == null) {
      return const SizedBox();
    }
    Size deviceSize = MediaQuery.of(context).size;
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      width: deviceSize.width * 0.9,
      height: 56,
      decoration: BoxDecoration(color: const Color.fromRGBO(29, 40, 58, 0.7), borderRadius: BorderRadius.circular(10)),
      child: StreamBuilder<MediaState>(
          stream: _mediaStateStream,
          builder: (context, snapshot) {
            final mediaState = snapshot.data;
            final position = mediaState?.position ?? Duration.zero;
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                    height: 6,
                    width: deviceSize.width * 0.9,
                    child: SeekBar(
                      duration: mediaState?.mediaItem?.duration ?? Duration.zero,
                      position: mediaState?.position ?? Duration.zero,
                      onChangeEnd: (newPosition) {
                        audioHandler.seek(newPosition);
                      },
                    )),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                  child: InkWell(
                    onTap: (() async => {
                          widget.navKey.currentState!.push(PageTransition(
                              alignment: Alignment.bottomCenter,
                              curve: Curves.bounceOut,
                              type: PageTransitionType.rightToLeftWithFade,
                              duration: const Duration(milliseconds: 500),
                              reverseDuration: const Duration(milliseconds: 500),
                              child: PodcastEpisodeScreen(
                                widget.escapeWithNav,
                                podcastId: widget.episode?.podcastId,
                                episode: widget.episode,
                                position: position,
                              )))
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
                                          imageUrl: widget.episode!.image ?? 'https://picsum.photos/200',
                                          fit: BoxFit.fill,
                                          placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
                                          errorWidget: (context, url, error) => const Icon(Icons.error),
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
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  removeAllHtmlTags(widget.episode!.description!),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                        AnimatedContainer(
                            padding: const EdgeInsets.only(right: 5),
                            duration: const Duration(milliseconds: 500),
                            width: 60,
                            height: 50,
                            child: PlayerControlWidget(widget.escapeWithNav)),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
    );
  }

  String removeAllHtmlTags(String htmlText) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);

    return htmlText.replaceAll(exp, '');
  }
}
