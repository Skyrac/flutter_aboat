import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/models/podcasts/episode.model.dart';
import 'package:Talkaboat/services/audio/audio-handler.services.dart';
import 'package:Talkaboat/services/audio/media.state.dart';
import 'package:Talkaboat/services/audio/podcast.service.dart';
import 'package:Talkaboat/services/downloading/file-downloader.service.dart';
import 'package:Talkaboat/services/user/user.service.dart';
import 'package:Talkaboat/utils/common.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class PodcastEpisodeDetails extends StatefulWidget {
  const PodcastEpisodeDetails({super.key, required this.episode, required this.position});

  final Episode episode;
  final Duration position;

  @override
  State<PodcastEpisodeDetails> createState() => _PodcastEpisodeDetailsState();
}

class _PodcastEpisodeDetailsState extends State<PodcastEpisodeDetails> {
  final audioPlayer = getIt<AudioPlayerHandler>();
  final userService = getIt<UserService>();
  final podcastService = getIt<PodcastService>();

  Stream<MediaState> get _mediaStateStream => Rx.combineLatest2<MediaItem?, Duration, MediaState>(
      audioPlayer.mediaItem, AudioService.position, (mediaItem, position) => MediaState(mediaItem, position));

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: podcastService.getPodcastDetails(widget.episode.podcastId!, "asc", -1),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  '${snapshot.error} occurred',
                  style: const TextStyle(fontSize: 18),
                ),
              );
            } else if (snapshot.hasData && snapshot.data != null) {
              final episodeItem = snapshot.data;
              // Extracting data from snapshot object
              return StreamBuilder<MediaState>(
                  stream: _mediaStateStream,
                  builder: (context, snapshot) {
                    final mediaState = snapshot.data;
                    final duration = mediaState?.mediaItem?.duration ?? Duration.zero;
                    final position = mediaState?.position ?? widget.position;
                    return Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 20),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  StreamBuilder<PlaybackState>(
                                    stream: audioPlayer.playbackState,
                                    builder: (context, snapshot) {
                                      final playbackState = snapshot.data;
                                      final processingState = playbackState?.processingState;
                                      final playing = playbackState?.playing;
                                      if (processingState == AudioProcessingState.loading ||
                                          processingState == AudioProcessingState.buffering) {
                                        return RawMaterialButton(
                                          child: Container(
                                            alignment: Alignment.center,
                                            width: 130,
                                            height: 40,
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(10),
                                                border: Border.all(width: 1, color: const Color.fromRGBO(99, 163, 253, 1))),
                                            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
                                              SizedBox(
                                                width: 20.0,
                                                height: 20.0,
                                                child: CircularProgressIndicator(),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Text("Play", style: TextStyle(color: Color.fromRGBO(99, 163, 253, 1)))
                                            ]),
                                          ),
                                          onPressed: () {},
                                        );
                                      } else if (playing != true) {
                                        return ButtonEpisode(
                                            func: audioPlayer.play,
                                            image: "assets/images/play.png",
                                            title: "Play",
                                            borderAndTextColor: const Color.fromRGBO(99, 163, 253, 1));
                                      } else {
                                        return ButtonEpisode(
                                            func: audioPlayer.pause,
                                            image: "assets/images/pause.png",
                                            title: "Stop",
                                            borderAndTextColor: const Color.fromRGBO(188, 140, 75, 1));
                                      }
                                    },
                                  ),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  FileDownloadService.containsFile(widget.episode.audio!)
                                      ? ButtonEpisode(
                                          func: () async {
                                            if (!userService.isInFavorites(widget.episode.podcastId!)) {
                                              await userService.addToFavorites(widget.episode.podcastId!);
                                            }
                                            await FileDownloadService.cacheOrDelete(widget.episode.audio!);
                                            setState(() {});
                                          },
                                          image: "assets/images/cloud_complete.png",
                                          title: "Downloaded",
                                          borderAndTextColor: const Color.fromRGBO(76, 175, 80, 1),
                                        )
                                      : ButtonEpisode(
                                          func: () async {
                                            if (!userService.isInFavorites(widget.episode.podcastId!)) {
                                              await userService.addToFavorites(widget.episode.podcastId!);
                                            }
                                            await FileDownloadService.cacheOrDelete(widget.episode.audio!);
                                            setState(() {});
                                          },
                                          image: "assets/images/cloud.png",
                                          title: "Download",
                                          borderAndTextColor: const Color.fromRGBO(99, 163, 253, 1),
                                        )
                                ],
                              ),
                              StreamBuilder<PlaybackState>(
                                  stream: audioPlayer.playbackState,
                                  builder: (context, snapshot) {
                                    final playbackState = snapshot.data;
                                    final playing = playbackState?.playing;
                                    if (playing != true) {
                                      return buildEpisodeDetails(
                                          context, position, duration, const Color.fromRGBO(99, 163, 253, 1), false);
                                    } else {
                                      return buildEpisodeDetails(
                                          context, position, duration, const Color.fromRGBO(188, 140, 75, 1), true);
                                    }
                                  }),
                            ],
                          ),
                        ),
                        Center(
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 30),
                                child: Column(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(top: 10),
                                      height: 40,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        "General",
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                              color: const Color.fromRGBO(99, 163, 253, 1),
                                            ),
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                        const SizedBox(
                                          width: 30,
                                          child: Text(
                                            "Titel",
                                            style: TextStyle(fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        SizedBox(
                                          width: 250,
                                          child: Text(
                                            mediaState?.mediaItem?.title ?? "",
                                            textAlign: TextAlign.end,
                                          ),
                                        ),
                                      ]),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const SizedBox(
                                            width: 60,
                                            child: Text(
                                              "Podcast",
                                              style: TextStyle(fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          SizedBox(
                                            width: 250,
                                            child: Text(
                                              episodeItem!.title.toString(),
                                              textAlign: TextAlign.end,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            "Duration",
                                            style: TextStyle(fontWeight: FontWeight.w600),
                                          ),
                                          Text.rich(TextSpan(children: [
                                            TextSpan(text: duration.inHours != 0 ? '${duration.inHours % 60}st ' : ""),
                                            TextSpan(text: duration.inMinutes != 0 ? '${duration.inMinutes % 60}min ' : ""),
                                            TextSpan(
                                              text: '${duration.inSeconds % 60}sec',
                                            ),
                                          ])),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 6),
                                      alignment: Alignment.centerLeft,
                                      child: const Text(
                                        "Authors",
                                        style: TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.fromLTRB(20, 0, 0, 10),
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        episodeItem.publisher ?? "",
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: const Color.fromRGBO(99, 163, 253, 0.5),
                                            ),
                                      ),
                                    ),
                                    Container(
                                      alignment: Alignment.centerLeft,
                                      margin: const EdgeInsets.only(bottom: 7),
                                      child: const Text(
                                        "Categories",
                                        style: TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    buildCategoryBadges(context, episodeItem.genreIds ?? ""),
                                    Container(
                                      alignment: Alignment.centerLeft,
                                      margin: const EdgeInsets.only(bottom: 10),
                                      child: Text(
                                        "Description",
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                              color: const Color.fromRGBO(99, 163, 253, 1),
                                            ),
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      child: Text(
                                        removeAllHtmlTags(widget.episode.description ?? ""),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(color: const Color.fromRGBO(99, 163, 253, 1)),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    );
                  });
            } else {
              return const Center(
                child: Text(
                  'No data found for this podcast. Please try again later!',
                  style: TextStyle(fontSize: 18),
                ),
              );
            }
          }
          return const SizedBox();
        });
  }

  buildEpisodeDetails(context, Duration position, Duration duration, Color color, bool isPlay) => Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              mainAxisAlignment: isPlay ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
              children: [
                Text.rich(TextSpan(children: [
                  TextSpan(text: position.inHours != 0 ? '${position.inHours % 60}st ' : "", style: TextStyle(color: color)),
                  TextSpan(
                      text: position.inMinutes != 0 ? '${position.inMinutes % 60}min ' : "", style: TextStyle(color: color)),
                  TextSpan(
                    text: '${position.inSeconds % 60}sec',
                    style: TextStyle(color: color),
                  ),
                ])),
                isPlay
                    ? const SizedBox()
                    : Text(
                        "/",
                        style: TextStyle(color: color),
                      ),
                Text.rich(TextSpan(children: [
                  TextSpan(text: duration.inHours != 0 ? '${duration.inHours % 60}st ' : "", style: TextStyle(color: color)),
                  TextSpan(
                      text: duration.inMinutes != 0 ? '${duration.inMinutes % 60}min ' : "", style: TextStyle(color: color)),
                  TextSpan(
                    text: '${duration.inSeconds % 60}sec',
                    style: TextStyle(color: color),
                  ),
                ])),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 5),
            padding: EdgeInsets.symmetric(horizontal: 0.2),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: color)),
            height: 11,
            width: 333,
            child: SeekBar(
              color: color,
              isPlay: isPlay,
              isMiniPlayer: false,
              duration: duration ?? Duration.zero,
              position: position ?? Duration.zero,
              onChangeEnd: (newPosition) {
                audioPlayer.seek(newPosition);
              },
            ),
          ),
        ],
      );
}

class ButtonEpisode extends StatelessWidget {
  final String image;
  final String title;
  final VoidCallback func;
  final Color borderAndTextColor;

  const ButtonEpisode({
    super.key,
    required this.image,
    required this.func,
    required this.title,
    required this.borderAndTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: func,
      child: Container(
        width: 130,
        height: 40,
        decoration:
            BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(width: 1, color: borderAndTextColor)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Image.asset(
            image,
            width: 23,
          ),
          const SizedBox(
            width: 10,
          ),
          Text(
            title,
            style: TextStyle(color: borderAndTextColor),
          )
        ]),
      ),
    );
  }
}

class CustomTrackShape extends RoundedRectSliderTrackShape {
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
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, 8);
  }
}
