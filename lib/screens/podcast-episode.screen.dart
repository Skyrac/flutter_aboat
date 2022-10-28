import 'package:Talkaboat/services/user/user.service.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:page_transition/page_transition.dart';
import 'package:share_plus/share_plus.dart';

import '../injection/injector.dart';
import '../models/podcasts/episode.model.dart';
import '../models/search/search_result.model.dart';
import '../services/audio/audio-handler.services.dart';
import '../services/audio/podcast.service.dart';
import '../services/downloading/file-downloader.service.dart';
import '../themes/colors.dart';
import '../utils/scaffold_wave.dart';
import '../widgets/bottom-sheets/playlist.bottom-sheet.dart';
import '../widgets/episode-preview.widget.dart';
import '../widgets/podcast-detail-sliver.widget.dart';
import '../widgets/podcast-episode-sliver.widget.dart';
import 'login.screen.dart';

class PodcastEpisodeScreen extends StatefulWidget {
  final SearchResult? podcastSearchResult;
  final Episode? episode;
  final int? podcastId;
  final AppBar? appBar;
  const PodcastEpisodeScreen(
      {Key? key,
      this.podcastSearchResult,
      this.podcastId,
      this.appBar,
      this.episode})
      : super(key: key);

  @override
  State<PodcastEpisodeScreen> createState() => _PodcastEpisodeScreenState();
}

class _PodcastEpisodeScreenState extends State<PodcastEpisodeScreen> {
  final audioPlayer = getIt<AudioPlayerHandler>();
  final podcastService = getIt<PodcastService>();
  var sort = "asc";
  var isDescOpen = false;
  var userService = getIt<UserService>();

  selectEpisode(int index, List<Episode> data) async {
    var selectedEpisode = data[index];
    if (audioPlayer.isListeningEpisode(selectedEpisode.episodeId)) {
      audioPlayer.togglePlaybackState();
    } else {
      await audioPlayer.updateEpisodeQueue(data, index: index);
    }
  }

  Future<SearchResult?> GetPodcast() async {
    if (widget.podcastSearchResult != null) {
      return widget.podcastSearchResult!;
    } else if (widget.podcastId != null) {
      return await podcastService.getPodcastDetails(
          widget.podcastId!, sort, -1);
    } else {
      return null;
    }
  }

  Widget buildEpisodes(List<Episode> data) => SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            var episode = data[index];
            var episodeIndex = index;
            return EpisodePreviewWidget(
                episode,
                Axis.vertical,
                () => {selectEpisode(episodeIndex, data)},
                () => setState(() {}));
          },
          childCount: data.length, // 1000 list items
        ),
      );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    userService.UpdatePodcastVisitDate(
        widget.podcastId ?? widget.podcastSearchResult?.id);
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
                              children: [
                                const Icon(Icons.arrow_back),
                                const SizedBox(
                                  width: 10,
                                ),
                                const Text("Back")
                              ],
                            ),
                          )
                        ]));
              },
              future: GetPodcast(),
            )));
  }

  Widget createCustomScrollView(SearchResult podcastSearchResult) {
    final size = MediaQuery.of(context).size;
    final remaining = Duration(
        seconds: (widget.episode!.audioLengthSec! - widget.episode!.playTime!)
            .toInt());
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
                  icon: const Icon(Icons.share,
                      color: Color.fromRGBO(99, 163, 253, 0.5), size: 36),
                  tooltip: '',
                  onPressed: () => {
                        //TODO: Geräte Abhängigkeit prüfen
                        Share.share(
                            "Check the Podcast ${widget.episode!.title} on Talkaboat.online mobile App! Start listening and earn while supporting new and upcoming podcasters.\n\n Download it now on \nAndroid: https://play.google.com/store/apps/details?id=com.aboat.talkaboat\n",
                            subject:
                                "Check this out! A Podcast on Talkaboat.online.")
                      }),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: IconButton(
                icon: const Icon(Icons.format_list_bulleted_add,
                    color: Color.fromRGBO(99, 163, 253, 0.5), size: 36),
                tooltip: '',
                onPressed: () {
                  if (!userService.isConnected) {
                    Navigator.push(
                        context,
                        PageTransition(
                            alignment: Alignment.bottomCenter,
                            curve: Curves.bounceOut,
                            type: PageTransitionType.rightToLeftWithFade,
                            duration: const Duration(milliseconds: 500),
                            reverseDuration: const Duration(milliseconds: 500),
                            child: LoginScreen(() => setState(() {}))));
                  } else {
                    showModalBottomSheet(
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20))),
                        context: context,
                        builder: (context) =>
                            PlaylistBottomSheet(episodeToAdd: widget.episode!));
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
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 20),
                      height: 40,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          StreamBuilder<PlaybackState>(
                            stream: audioPlayer.playbackState,
                            builder: (context, snapshot) {
                              final playbackState = snapshot.data;
                              final processingState =
                                  playbackState?.processingState;
                              final playing = playbackState?.playing;
                              if (processingState ==
                                      AudioProcessingState.loading ||
                                  processingState ==
                                      AudioProcessingState.buffering) {
                                return RawMaterialButton(
                                  child: Container(
                                    alignment: Alignment.center,
                                    width: 130,
                                    height: 40,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            width: 1,
                                            color: const Color.fromRGBO(
                                                99, 163, 253, 1))),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 20.0,
                                            height: 20.0,
                                            child:
                                                const CircularProgressIndicator(),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          const Text("Abspielen",
                                              style: TextStyle(
                                                  color: Color.fromRGBO(
                                                      99, 163, 253, 1)))
                                        ]),
                                  ),
                                  onPressed: () {},
                                );
                              } else if (playing != true) {
                                return ButtonEpisode(
                                    func: audioPlayer.play,
                                    image: "assets/images/play.png",
                                    title: "Abspielen");
                              } else {
                                return ButtonEpisode(
                                    func: audioPlayer.pause,
                                    image: "assets/images/pause.png",
                                    title: "Abspielen");
                              }
                            },
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          FileDownloadService.containsFile(
                                  widget.episode!.audio!)
                              ? ButtonEpisode(
                                  func: () async {
                                    if (!userService.isInFavorites(
                                        widget.episode!.podcastId!)) {
                                      await userService.addToFavorites(
                                          widget.episode!.podcastId!);
                                    }
                                    await FileDownloadService.cacheOrDelete(
                                        widget.episode!.audio!);
                                    setState(() {});
                                  },
                                  image: "assets/images/cloud_complete.png",
                                  title: "Download")
                              : ButtonEpisode(
                                  func: () async {
                                    if (!userService.isInFavorites(
                                        widget.episode!.podcastId!)) {
                                      await userService.addToFavorites(
                                          widget.episode!.podcastId!);
                                    }
                                    await FileDownloadService.cacheOrDelete(
                                        widget.episode!.audio!);
                                    setState(() {});
                                  },
                                  image: "assets/images/cloud.png",
                                  title: "Download")
                        ],
                      ),
                    ),
                    FutureBuilder(
                      future: podcastService.getPodcastDetails(
                          podcastSearchResult.id!, sort, -1),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                '${snapshot.error} occurred',
                                style: const TextStyle(fontSize: 18),
                              ),
                            );
                          } else if (snapshot.hasData &&
                              snapshot.data != null) {
                            // Extracting data from snapshot object
                            return Center(
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 30),
                                    child: Column(
                                      children: [
                                        Container(
                                          margin:
                                              const EdgeInsets.only(top: 10),
                                          height: 40,
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            "Allgemeines",
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge
                                                ?.copyWith(
                                                  color: const Color.fromRGBO(
                                                      99, 163, 253, 1),
                                                ),
                                          ),
                                        ),
                                        Container(
                                          margin:
                                              const EdgeInsets.only(bottom: 10),
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const SizedBox(
                                                  width: 30,
                                                  child: Text(
                                                    "Titel",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                SizedBox(
                                                  width: 250,
                                                  child: Text(
                                                    widget.episode!.title!,
                                                    textAlign: TextAlign.end,
                                                  ),
                                                ),
                                              ]),
                                        ),
                                        Container(
                                          margin:
                                              const EdgeInsets.only(bottom: 10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const SizedBox(
                                                width: 60,
                                                child: Text(
                                                  "Podcast",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              SizedBox(
                                                width: 250,
                                                child: Text(
                                                  snapshot.data!.title
                                                      .toString(),
                                                  textAlign: TextAlign.end,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          margin:
                                              const EdgeInsets.only(bottom: 10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                "Dauer",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                              Text.rich(TextSpan(children: [
                                                TextSpan(
                                                    text: remaining.inHours != 0
                                                        ? '${remaining.inHours % 60}st '
                                                        : ""),
                                                TextSpan(
                                                    text: remaining.inMinutes !=
                                                            0
                                                        ? '${remaining.inMinutes % 60}min '
                                                        : ""),
                                                TextSpan(
                                                  text:
                                                      '${remaining.inSeconds % 60}sec',
                                                ),
                                              ])),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          margin:
                                              const EdgeInsets.only(bottom: 6),
                                          alignment: Alignment.centerLeft,
                                          child: const Text(
                                            "Author",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.fromLTRB(
                                              20, 0, 0, 10),
                                          alignment: Alignment.topLeft,
                                          child: Text(
                                            snapshot.data!.publisher!,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: const Color.fromRGBO(
                                                      99, 163, 253, 0.5),
                                                ),
                                          ),
                                        ),
                                        Container(
                                          alignment: Alignment.centerLeft,
                                          margin:
                                              const EdgeInsets.only(bottom: 7),
                                          child: const Text(
                                            "Kategorien",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Container(
                                              margin: const EdgeInsets.only(
                                                  bottom: 35),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: const Color.fromRGBO(
                                                      188, 140, 75, 1)),
                                              width: 100,
                                              height: 35,
                                              child: Center(
                                                  child: Text(
                                                      textAlign:
                                                          TextAlign.center,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 2,
                                                      snapshot.data!.genreIds!,
                                                      style: const TextStyle(
                                                          color: Color.fromRGBO(
                                                              15,
                                                              23,
                                                              41,
                                                              1))))),
                                        ),
                                        Container(
                                          alignment: Alignment.centerLeft,
                                          margin:
                                              const EdgeInsets.only(bottom: 10),
                                          child: Text(
                                            "Beschreibung",
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge
                                                ?.copyWith(
                                                  color: const Color.fromRGBO(
                                                      99, 163, 253, 1),
                                                ),
                                          ),
                                        ),
                                        Container(
                                          margin:
                                              const EdgeInsets.only(bottom: 10),
                                          child: Text(
                                            widget.episode!.transcript!,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.copyWith(
                                                    color: const Color.fromRGBO(
                                                        99, 163, 253, 1)),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
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
                      },
                    ),
                  ],
                ),
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
              const SliverToBoxAdapter(child: Center(child: Placeholder()))
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
              const SliverToBoxAdapter(child: Center(child: Placeholder()))
            ],
          ),
        ]),
      ),
    );
  }
}

class ButtonEpisode extends StatelessWidget {
  final String image;
  final String title;
  final VoidCallback func;

  const ButtonEpisode({
    super.key,
    required this.image,
    required this.func,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: func,
      child: Container(
        width: 130,
        height: 40,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                width: 1, color: const Color.fromRGBO(99, 163, 253, 1))),
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
            style: TextStyle(color: Color.fromRGBO(99, 163, 253, 1)),
          )
        ]),
      ),
    );
  }
}
