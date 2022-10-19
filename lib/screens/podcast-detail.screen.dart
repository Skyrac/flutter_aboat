import 'package:Talkaboat/services/user/user.service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  const PodcastDetailScreen(
      {Key? key, this.podcastSearchResult, this.podcastId, this.appBar})
      : super(key: key);

  @override
  State<PodcastDetailScreen> createState() => _PodcastDetailScreenState();
}

class _PodcastDetailScreenState extends State<PodcastDetailScreen> {
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
            return EpisodePreviewWidget(episode, Axis.vertical,
                () => selectEpisode(episodeIndex, data));
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
    return DefaultTabController(
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
                  icon: const Icon(Icons.share,
                      color: Color.fromRGBO(99, 163, 253, 0.5), size: 36),
                  tooltip: '',
                  onPressed: () => {
                        //TODO: Geräte Abhängigkeit prüfen
                        Share.share(
                            "Check the Podcast ${podcastSearchResult.title} on Talkaboat.online mobile App! Start listening and earn while supporting new and upcoming podcasters.\n\n Download it now on \nAndroid: https://play.google.com/store/apps/details?id=com.aboat.talkaboat\n",
                            subject:
                                "Check this out! A Podcast on Talkaboat.online.")
                      }),
            ),
            !userService.isConnected
                ? const SizedBox()
                : userService.isInFavorites(podcastSearchResult.id!)
                    ? Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: IconButton(
                          icon: const Icon(Icons.favorite,
                              color: Color.fromRGBO(99, 163, 253, 0.5),
                              size: 36),
                          tooltip: '',
                          onPressed: () async {
                            await userService
                                .removeFromFavorites(podcastSearchResult.id!);
                            setState(() {});
                          },
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: IconButton(
                          icon: const Icon(Icons.favorite_border,
                              color: Color.fromRGBO(99, 163, 253, 0.5),
                              size: 36),
                          tooltip: '',
                          onPressed: () async {
                            await userService
                                .addToFavorites(podcastSearchResult.id!);
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
                delegate: PodcastDetailSliver(
                    expandedHeight: size.height * 0.4,
                    podcast: podcastSearchResult),
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
                      final data = snapshot.data as List<Episode>?;
                      if (data != null && data.isNotEmpty) {
                        return buildEpisodes(data);
                      }
                    }
                  }
                  return const SliverToBoxAdapter(
                      child: Center(child: CircularProgressIndicator()));
                },
                future: podcastService.getPodcastDetailEpisodes(
                    podcastSearchResult.id!, sort, -1),
              ),
            ],
          ),
          CustomScrollView(
            slivers: [
              SliverPersistentHeader(
                delegate: PodcastDetailSliver(
                    expandedHeight: size.height * 0.4,
                    podcast: podcastSearchResult),
                pinned: true,
              ),
              const SliverToBoxAdapter(child: Center(child: Placeholder()))
            ],
          ),
          CustomScrollView(
            slivers: [
              SliverPersistentHeader(
                delegate: PodcastDetailSliver(
                    expandedHeight: size.height * 0.4,
                    podcast: podcastSearchResult),
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
