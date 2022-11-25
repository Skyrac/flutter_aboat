import 'package:Talkaboat/services/user/user.service.dart';
import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:page_transition/page_transition.dart';
import 'package:rxdart/rxdart.dart';
import 'package:share_plus/share_plus.dart';

import '../injection/injector.dart';
import '../models/podcasts/episode.model.dart';
import '../models/podcasts/podcast-rank.model.dart';
import '../models/podcasts/podcast.model.dart';
import '../models/search/search_result.model.dart';
import '../services/audio/audio-handler.services.dart';
import '../services/audio/media.state.dart';
import '../services/audio/podcast.service.dart';
import '../services/downloading/file-downloader.service.dart';
import '../themes/colors.dart';
import '../utils/scaffold_wave.dart';
import '../widgets/bottom-sheets/playlist.bottom-sheet.dart';
import '../widgets/chat.widget.dart';
import '../widgets/episode-preview.widget.dart';
import '../widgets/podcast-episode-sliver.widget.dart';
import 'login.screen.dart';

class PodcastEpisodeScreen extends StatefulWidget {
  final SearchResult? podcastSearchResult;
  final Episode? episode;
  final int? podcastId;
  final AppBar? appBar;
  final Function escapeWithNav;
  final Duration position;
  const PodcastEpisodeScreen(
    this.escapeWithNav, {
    Key? key,
    this.podcastSearchResult,
    this.podcastId,
    this.appBar,
    this.episode,
    required this.position,
  }) : super(key: key);

  @override
  State<PodcastEpisodeScreen> createState() => _PodcastEpisodeScreenState();
}

class _PodcastEpisodeScreenState extends State<PodcastEpisodeScreen> {
  final audioPlayer = getIt<AudioPlayerHandler>();
  final podcastService = getIt<PodcastService>();
  final sort = "asc";
  final isDescOpen = false;
  final userService = getIt<UserService>();
  final audioHandler = getIt<AudioPlayerHandler>();
  Future<SearchResult?>? _getPodcast;

  selectEpisode(int index, List<Episode> data) async {
    var selectedEpisode = data[index];
    if (audioPlayer.isListeningEpisode(selectedEpisode.episodeId)) {
      audioPlayer.togglePlaybackState();
    } else {
      await audioPlayer.updateEpisodeQueue(data, index: index);
    }
  }

  @override
  initState() {
    super.initState();
    _getPodcast = getPodcast(widget.episode, widget.podcastId);
  }

  Widget buildEpisodes(List<Episode> data) => SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            var episode = data[index];
            var episodeIndex = index;
            return EpisodePreviewWidget(episode, Axis.vertical, () => {selectEpisode(episodeIndex, data)},
                () => setState(() {}), widget.escapeWithNav);
          },
          childCount: data.length, // 1000 list items
        ),
      );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    userService.UpdatePodcastVisitDate(widget.podcastId ?? widget.podcastSearchResult?.id);
    return Scaffold(
        body: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
              DefaultColors.primaryColor.shade900,
              DefaultColors.secondaryColor.shade900,
              DefaultColors.secondaryColor.shade900
            ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
            child: FutureBuilder<SearchResult?>(
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
                    // Extracting data from snapshot object
                    return createCustomScrollView(snapshot.data!);
                  } else {
                    return const Center(
                      child: Text(
                        'No data found for this podcast. Please try again later!',
                        style: TextStyle(fontSize: 18),
                      ),
                    );
                  }
                }
                return SizedBox(
                    height: size.height,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Center(child: CircularProgressIndicator()),
                          const SizedBox(
                            height: 50,
                          ),
                          InkWell(
                            onTap: (() {
                              Navigator.pop(context);
                            }),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.arrow_back),
                                SizedBox(
                                  width: 10,
                                ),
                                Text("Back")
                              ],
                            ),
                          )
                        ]));
              },
              future: _getPodcast,
            )));
  }

  Stream<MediaState> get _mediaStateStream => Rx.combineLatest2<MediaItem?, Duration, MediaState>(
      audioHandler.mediaItem, AudioService.position, (mediaItem, position) => MediaState(mediaItem, position));

  Widget createCustomScrollView(SearchResult podcastSearchResult) {
    final size = MediaQuery.of(context).size;
    return DefaultTabController(
      animationDuration: Duration.zero,
      length: 3,
      child: ScaffoldWave(
        height: 33,
        appBar: AppBar(
          centerTitle: false,
          leadingWidth: 35,
          titleSpacing: 3,
          backgroundColor: const Color.fromRGBO(29, 40, 58, 1),
          title: Text(
            widget.episode!.title!,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: const Color.fromRGBO(99, 163, 253, 1),
                ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 5),
              child: IconButton(
                  icon: const Icon(Icons.share, color: Color.fromRGBO(99, 163, 253, 0.5), size: 36),
                  tooltip: '',
                  onPressed: () => {
                        //TODO: Geräte Abhängigkeit prüfen
                        Share.share(
                            "Check the Podcast ${widget.episode!.title} on Talkaboat.online mobile App! Start listening and earn while supporting new and upcoming podcasters.\n\n Download it now on \nAndroid: https://play.google.com/store/apps/details?id=com.aboat.talkaboat\n",
                            subject: "Check this out! A Podcast on Talkaboat.online.")
                      }),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: IconButton(
                icon: const Icon(Icons.format_list_bulleted, color: Color.fromRGBO(99, 163, 253, 0.5), size: 36),
                tooltip: '',
                onPressed: () {
                  if (!userService.isConnected) {
                    widget.escapeWithNav(PageTransition(
                        alignment: Alignment.bottomCenter,
                        curve: Curves.bounceOut,
                        type: PageTransitionType.rightToLeftWithFade,
                        duration: const Duration(milliseconds: 500),
                        reverseDuration: const Duration(milliseconds: 500),
                        child: LoginScreen(true, refreshParent: () => setState(() {}))));
                  } else {
                    showModalBottomSheet(
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                        context: context,
                        builder: (context) => Container(
                              margin: const EdgeInsets.only(top: 24),
                              child: FractionallySizedBox(
                                  heightFactor: 1, child: PlaylistBottomSheet(episodeToAdd: widget.episode!)),
                            ));
                  }
                },
              ),
            )
          ],
        ),
        body: TabBarView(children: [
          CustomScrollView(
            slivers: [
              SliverPersistentHeader(
                delegate: PodcastEpisodeSliver(
                    expandedHeight: size.height * 0.4,
                    // podcast: podcastSearchResult,
                    episode: widget.episode!),
                pinned: true,
              ),
              SliverToBoxAdapter(
                child: FutureBuilder(
                    future: podcastService.getPodcastDetails(podcastSearchResult.id!, sort, -1),
                    builder: (context, snapshot) {
                      final episodeItem = snapshot.data;
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              '${snapshot.error} occurred',
                              style: const TextStyle(fontSize: 18),
                            ),
                          );
                        } else if (snapshot.hasData && snapshot.data != null) {
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
                                                            border: Border.all(
                                                                width: 1, color: const Color.fromRGBO(99, 163, 253, 1))),
                                                        child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: const [
                                                              SizedBox(
                                                                width: 20.0,
                                                                height: 20.0,
                                                                child: CircularProgressIndicator(),
                                                              ),
                                                              SizedBox(
                                                                width: 10,
                                                              ),
                                                              Text("Play",
                                                                  style: TextStyle(color: Color.fromRGBO(99, 163, 253, 1)))
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
                                              FileDownloadService.containsFile(widget.episode!.audio!)
                                                  ? ButtonEpisode(
                                                      func: () async {
                                                        if (!userService.isInFavorites(widget.episode!.podcastId!)) {
                                                          await userService.addToFavorites(widget.episode!.podcastId!);
                                                        }
                                                        await FileDownloadService.cacheOrDelete(widget.episode!.audio!);
                                                        setState(() {});
                                                      },
                                                      image: "assets/images/cloud_complete.png",
                                                      title: "Downloaded",
                                                      borderAndTextColor: const Color.fromRGBO(76, 175, 80, 1),
                                                    )
                                                  : ButtonEpisode(
                                                      func: () async {
                                                        if (!userService.isInFavorites(widget.episode!.podcastId!)) {
                                                          await userService.addToFavorites(widget.episode!.podcastId!);
                                                        }
                                                        await FileDownloadService.cacheOrDelete(widget.episode!.audio!);
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
                                                  return buildEpisodeDetails(context, position, duration,
                                                      const Color.fromRGBO(99, 163, 253, 1), false);
                                                } else {
                                                  return buildEpisodeDetails(context, position, duration,
                                                      const Color.fromRGBO(188, 140, 75, 1), true);
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
                                                        TextSpan(
                                                            text:
                                                                duration.inHours != 0 ? '${duration.inHours % 60}st ' : ""),
                                                        TextSpan(
                                                            text: duration.inMinutes != 0
                                                                ? '${duration.inMinutes % 60}min '
                                                                : ""),
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
                                                    episodeItem.publisher!,
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
                                                Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: Container(
                                                      margin: const EdgeInsets.only(bottom: 35),
                                                      decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(10),
                                                          color: const Color.fromRGBO(188, 140, 75, 1)),
                                                      width: 100,
                                                      height: 35,
                                                      child: Center(
                                                          child: Text(
                                                              textAlign: TextAlign.center,
                                                              overflow: TextOverflow.ellipsis,
                                                              maxLines: 2,
                                                              episodeItem.genreIds!,
                                                              style:
                                                                  const TextStyle(color: Color.fromRGBO(15, 23, 41, 1))))),
                                                ),
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
                                                    widget.episode!.transcript!,
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
                    }),
              )
            ],
          ),
          CustomScrollView(
            slivers: [
              SliverPersistentHeader(
                delegate: PodcastEpisodeSliver(
                    expandedHeight: size.height * 0.4,
                    // podcast: podcastSearchResult,
                    episode: widget.episode!),
                pinned: true,
              ),
              SliverToBoxAdapter(
                  child: Center(
                      child: FutureBuilder(
                          future: podcastService.getPodcastDetails(podcastSearchResult.id!, sort, -1),
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
                                final podcast = snapshot.data;
                                // Extracting data from snapshot object
                                return Container(
                                  padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
                                  height: 105,
                                  width: MediaQuery.of(context).size.width,
                                  child: RawMaterialButton(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                    onPressed: () {},
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.transparent,
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.only(right: 5),
                                            width: 100,
                                            height: 100,
                                            child: Center(
                                              child: Stack(
                                                children: [
                                                  ClipRRect(
                                                      borderRadius: BorderRadius.circular(10),
                                                      child: SizedBox(
                                                          child: CachedNetworkImage(
                                                        imageUrl: podcast!.image ?? 'https://picsum.photos/200',
                                                        cacheManager: CacheManager(Config(
                                                            widget.episode!.image ?? 'https://picsum.photos/200',
                                                            stalePeriod: const Duration(days: 2))),
                                                        fit: BoxFit.fill,
                                                        placeholder: (_, __) =>
                                                            const Center(child: CircularProgressIndicator()),
                                                        errorWidget: (context, url, error) => const Icon(Icons.error),
                                                      ))),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          SizedBox(
                                            height: 105,
                                            width: 218,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Flexible(
                                                  fit: FlexFit.loose,
                                                  child: Text(
                                                    podcast.title!,
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    style: const TextStyle(
                                                        color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
                                                  ),
                                                ),
                                                Flexible(
                                                  fit: FlexFit.loose,
                                                  child: Text(removeAllHtmlTags(podcast.publisher!),
                                                      overflow: TextOverflow.ellipsis,
                                                      maxLines: 2,
                                                      style: const TextStyle(color: Colors.white, fontSize: 12)),
                                                ),
                                                FutureBuilder(
                                                    future: getPodcast(widget.episode, widget.podcastId),
                                                    builder: (context, snapshot) {
                                                      if (snapshot.connectionState == ConnectionState.done) {
                                                        if (snapshot.hasError) {
                                                          return Center(
                                                            child: Text(
                                                              '${snapshot.error} occurred',
                                                              style: const TextStyle(fontSize: 18),
                                                            ),
                                                          );
                                                        }
                                                        if (snapshot.data != null) {
                                                          final podcast = snapshot.data!;
                                                          final rank = PodcastRankfromNumber(podcast.rank);
                                                          String? reward = PodcastMultiplerfromRank(rank);
                                                          return reward != null
                                                              ? Row(
                                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                  children: [
                                                                    Text(
                                                                        '${podcast.totalEpisodes!.toString()} Episodes     - ',
                                                                        style: Theme.of(context).textTheme.titleMedium),
                                                                    const SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    const Image(
                                                                      image: AssetImage("assets/icons/icon_fire.png"),
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    Text("Reward $reward",
                                                                        style: Theme.of(context).textTheme.titleMedium)
                                                                  ],
                                                                )
                                                              : Row(
                                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                  children: [
                                                                    Text(
                                                                        '${podcast.totalEpisodes!.toString()} Episodes       ',
                                                                        style: Theme.of(context).textTheme.titleMedium),
                                                                    const SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                  ],
                                                                );
                                                        }
                                                      }
                                                      return const SizedBox(
                                                          width: 15.0, height: 15.0, child: CircularProgressIndicator());
                                                    }),
                                              ],
                                            ),
                                          ),
                                          buildPopupButton(context, widget.episode!),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
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
                          })))
            ],
          ),
          FutureBuilder(
              future: podcastSearchResult.roomId != null
                  ? Future.value(podcastSearchResult)
                  : podcastService.getPodcastDetails(widget.podcastSearchResult!.id!, sort, -1),
              builder: ((context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  return Chat(
                    roomId: snapshot.data!.roomId!,
                    messageType: 2,
                    header: SliverPersistentHeader(
                      delegate: PodcastEpisodeSliver(expandedHeight: size.height * 0.4, episode: widget.episode!),
                      pinned: true,
                    ),
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              })),
        ]),
      ),
    );
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
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: color)),
            height: 10,
            width: 333,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                  trackHeight: 8.0,
                  thumbColor: color,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                  // thumbShape: HiddenThumbComponentShape(),
                  activeTrackColor: color,
                  inactiveTrackColor: const Color.fromRGBO(15, 23, 41, 1),
                  trackShape: CustomTrackShape()
                  // thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0.0)
                  ),
              child: Slider(
                  value: (duration.inSeconds.toDouble() < position.inSeconds.toDouble() ? 0 : position.inSeconds.toDouble()),
                  onChanged: (double value) {},
                  min: 0,
                  max: duration.inSeconds.toDouble()),
            ),
            // )
          ),
        ],
      );

  buildPopupButton(context, Episode entry) => PopupMenuButton(
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: Color.fromRGBO(188, 140, 75, 1)),
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        constraints: const BoxConstraints.expand(width: 196, height: 110),
        color: const Color.fromRGBO(15, 23, 41, 1),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 30, 14, 30),
          child: Image.asset(
            "assets/images/options.png",
            width: 6,
          ),
        ),
        onSelected: (value) async {
          switch (value) {
            case 'download':
              if (!userService.isInFavorites(entry.podcastId!)) {
                await userService.addToFavorites(entry.podcastId!);
                // widget.refresh();
              }
              await FileDownloadService.cacheOrDelete(entry.audio!);
              break;
            case "add":
              if (!userService.isConnected) {
                widget.escapeWithNav(PageTransition(
                    alignment: Alignment.bottomCenter,
                    curve: Curves.bounceOut,
                    type: PageTransitionType.rightToLeftWithFade,
                    duration: const Duration(milliseconds: 500),
                    reverseDuration: const Duration(milliseconds: 500),
                    child: LoginScreen(true, refreshParent: () => setState(() {}))));
              } else {
                showModalBottomSheet(
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                    context: context,
                    builder: (context) => Container(
                          margin: const EdgeInsets.only(top: 24),
                          child: FractionallySizedBox(heightFactor: 0.95, child: PlaylistBottomSheet(episodeToAdd: entry)),
                        ));
              }
              break;
          }
          setState(() {});
        },
        itemBuilder: (BuildContext context) {
          return popupMenu(context, entry);
        },
      );

  popupMenu(BuildContext context, Episode entry) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
            value: 'add',
            child: Container(
                width: 176,
                height: 30,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: const Color.fromRGBO(29, 40, 58, 0.97),
                    border: Border.all(color: const Color.fromRGBO(188, 140, 75, 0.25))),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    const Icon(Icons.format_list_bulleted, color: Color.fromRGBO(99, 163, 253, 1), size: 25),
                    const SizedBox(
                      width: 10,
                    ),
                    Text('Add to playlist',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(color: const Color.fromRGBO(99, 163, 253, 1))),
                  ],
                ))),
        PopupMenuItem<String>(
            value: 'download',
            child: Container(
                width: 176,
                height: 30,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: const Color.fromRGBO(29, 40, 58, 0.97),
                    border: Border.all(color: const Color.fromRGBO(188, 140, 75, 0.25))),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    Image.asset(
                      "assets/images/cloud.png",
                      width: 22,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(FileDownloadService.containsFile(entry.audio!) ? 'Delete' : 'Download',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(color: const Color.fromRGBO(99, 163, 253, 1))),
                  ],
                ))),
      ];

  String removeAllHtmlTags(String htmlText) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);

    return htmlText.replaceAll(exp, '');
  }

  Future<Podcast?> getPodcast(Episode? episode, int? podcastId) {
    if (episode != null) {
      if (episode.podcast != null) {
        return Future.value(episode.podcast);
      }
    }
    if (podcastId != null || (episode != null && episode.podcastId != null)) {
      return podcastService.getPodcastDetails(podcastId ?? episode!.podcastId!, sort, 1);
    }
    return Future.value(null);
  }
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
