import 'dart:async';

import 'package:Talkaboat/services/hubs/chat/chat.service.dart';
import 'package:Talkaboat/services/user/user.service.dart';
import 'package:Talkaboat/utils/common.dart';
import 'package:Talkaboat/widgets/chat.widget.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../injection/injector.dart';
import '../models/podcasts/episode.model.dart';
import '../models/search/search_result.model.dart';
import '../services/audio/audio-handler.services.dart';
import '../services/audio/podcast.service.dart';
import '../themes/colors.dart';
import '../utils/scaffold_wave.dart';
import '../widgets/episode-preview.widget.dart';
import '../widgets/podcast-detail-sliver.widget.dart';

class PodcastDetailScreen extends StatefulWidget {
  final SearchResult? podcastSearchResult;
  final int? podcastId;
  final AppBar? appBar;
  final Function escapeWithNav;
  const PodcastDetailScreen(this.escapeWithNav, {Key? key, this.podcastSearchResult, this.podcastId, this.appBar})
      : super(key: key);

  @override
  State<PodcastDetailScreen> createState() => _PodcastDetailScreenState();
}

class _PodcastDetailScreenState extends State<PodcastDetailScreen> {
  final audioPlayer = getIt<AudioPlayerHandler>();
  final podcastService = getIt<PodcastService>();
  final ChatService chatService = getIt<ChatService>();
  final userService = getIt<UserService>();
  final sort = "asc";
  final isDescOpen = false;
  Future<SearchResult?>? _getPodcast;

  @override
  initState() {
    super.initState();
    _getPodcast = getPodcast();
  }

  selectEpisode(int index, List<Episode> data) async {
    var selectedEpisode = data[index];
    if (audioPlayer.isListeningEpisode(selectedEpisode.episodeId)) {
      audioPlayer.togglePlaybackState();
    } else {
      await audioPlayer.updateEpisodeQueue(data, index: index);
    }
  }

  Future<SearchResult?> getPodcast() async {
    if (widget.podcastSearchResult != null) {
      return widget.podcastSearchResult!;
    } else if (widget.podcastId != null) {
      return await podcastService.getPodcastDetails(widget.podcastId!, sort, -1);
    } else {
      return null;
    }
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
            podcastSearchResult.title!,
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
                            "Check the Podcast ${podcastSearchResult.title} on Talkaboat.online mobile App! Start listening and earn while supporting new and upcoming podcasters.\n\n Download it now on \nAndroid: https://play.google.com/store/apps/details?id=com.aboat.talkaboat\n",
                            subject: "Check this out! A Podcast on Talkaboat.online.")
                      }),
            ),
            !userService.isConnected
                ? const SizedBox()
                : userService.isInFavorites(podcastSearchResult.id!)
                    // : isFav
                    ? Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: IconButton(
                          icon: const Icon(Icons.favorite, color: Color.fromRGBO(99, 163, 253, 0.5), size: 36),
                          tooltip: '',
                          onPressed: () async {
                            await userService.removeFromFavorites(podcastSearchResult.id!);
                            setState(() {});
                          },
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: IconButton(
                          icon: const Icon(Icons.favorite_border, color: Color.fromRGBO(99, 163, 253, 0.5), size: 36),
                          tooltip: '',
                          onPressed: () async {
                            await userService.addToFavorites(podcastSearchResult.id!);
                            setState(() {});
                          },
                        ),
                      ),
          ],
        ),
        body: TabBarView(children: [
          CustomScrollView(
            slivers: [
              SliverPersistentHeader(
                delegate: PodcastDetailSliver(widget.escapeWithNav,
                    expandedHeight: size.height * 0.4, podcast: podcastSearchResult),
                pinned: true,
              ),
              FutureBuilder(
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasError) {
                      return SliverToBoxAdapter(
                        child: Center(
                          child: Text(
                            '${snapshot.error} occurred',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      );
                    } else if (snapshot.hasData && snapshot.data != null) {
                      // Extracting data from snapshot object
                      if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                        return buildEpisodes(snapshot.data!);
                      }
                    }
                  }
                  return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
                },
                future: podcastService.getPodcastDetailEpisodes(podcastSearchResult.id!, sort, -1),
              ),
            ],
          ),
          CustomScrollView(
            slivers: [
              SliverPersistentHeader(
                delegate: PodcastDetailSliver(widget.escapeWithNav,
                    expandedHeight: size.height * 0.4, podcast: podcastSearchResult),
                pinned: true,
              ),
              SliverToBoxAdapter(
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
                      // Extracting data from snapshot object
                      return Container(
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
                                    snapshot.data!.title!,
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
                                  const Text(
                                    "Episodes",
                                    style: TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  Text(snapshot.data!.totalEpisodes!.toString())
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
                                snapshot.data!.publisher!,
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
                            buildCategoryBadges(context, snapshot.data!.genreIds!),
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
                                snapshot.data!.description!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(color: const Color.fromRGBO(99, 163, 253, 1)),
                              ),
                            )
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
              ))
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
                    messageType: 1,
                    header: SliverPersistentHeader(
                      delegate: PodcastDetailSliver(widget.escapeWithNav,
                          expandedHeight: size.height * 0.4, podcast: podcastSearchResult),
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
}
