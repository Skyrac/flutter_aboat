import 'package:Talkaboat/services/user/user.service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../injection/injector.dart';
import '../models/podcasts/episode.model.dart';
import '../models/search/search_result.model.dart';
import '../services/audio/audio-handler.services.dart';
import '../services/audio/podcast.service.dart';
import '../themes/colors.dart';
import '../widgets/episode-preview.widget.dart';
import '../widgets/podcast-detail-sliver.widget.dart';

class PodcastDetailScreen extends StatefulWidget {
  final SearchResult? podcastSearchResult;
  final int? podcastId;
  const PodcastDetailScreen({Key? key, this.podcastSearchResult, this.podcastId})
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
  Widget topContent(context) => Stack(
        children: <Widget>[
          Container(
              padding: const EdgeInsets.only(left: 10.0),
              height: MediaQuery.of(context).size.height * 0.5,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(widget.podcastSearchResult!.image!),
                  fit: BoxFit.cover,
                ),
              )),
          Container(
            height: MediaQuery.of(context).size.height * 0.5,
            padding: const EdgeInsets.all(40.0),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                color: DefaultColors.secondaryColorAlphaBlend.shade900),
            child: Center(
              child: Text(
                widget.podcastSearchResult!.title!,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          Positioned(
            left: 8.0,
            top: 60.0,
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(Icons.arrow_back, color: Colors.white),
            ),
          )
        ],
      );

  selectEpisode(int index, List<Episode> data) async {
    var selectedEpisode = data[index];
    if (audioPlayer.isListeningEpisode(selectedEpisode.episodeId)) {
      audioPlayer.togglePlaybackState();
    } else {
      await audioPlayer.updateEpisodeQueue(data, index: index);
    }
  }

  Future<SearchResult?> GetPodcast() async {
    if(widget.podcastSearchResult != null) {
      return widget.podcastSearchResult!;
    } else if(widget.podcastId != null) {
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
            return EpisodePreviewWidget(episode, Axis.vertical,
                () => selectEpisode(episodeIndex, data));
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
            child:
            FutureBuilder<SearchResult?>(builder: (context, snapshot)
            {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      '${snapshot.error} occurred',
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                } else if (snapshot.hasData && snapshot.data != null) {
                  // Extracting data from snapshot object
                  return createCustomScrollView(snapshot.data!);
                } else {
                  return Center(
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
                  children: [const Center(child: CircularProgressIndicator()),
                  SizedBox(height: 50,),
                  InkWell(
                    onTap: (() { Navigator.pop(context); }),
                    child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_back),
                      SizedBox(width: 10,),
                      Text("Back")
                    ],
                  ),)]));

              },
              future: GetPodcast(),
            )
        ));
  }

  Widget createCustomScrollView(SearchResult podcastSearchResult) {
    final size = MediaQuery.of(context).size;
    return CustomScrollView(
      slivers: [
        SliverPersistentHeader(
          delegate: PodcastDetailSliver(
              expandedHeight: size.height * 0.5,
              podcast: podcastSearchResult),
          pinned: true,
        ),
        SliverToBoxAdapter(
          child: Padding(
              padding:
              EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Card(
                        child: InkWell(
                          onTap: (() {
                            setState(() {
                              isDescOpen = !isDescOpen;
                            });
                          }),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              podcastSearchResult.description ?? '',
                              maxLines: isDescOpen ? 9999 : 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 15, bottom: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: (() {
                            setState(() {
                              sort = sort == "asc" ? "desc" : "asc";
                            });
                          }),
                          child: RotatedBox(
                            quarterTurns: sort == "asc" ? 0 : 2,
                            child: Icon(Icons.sort),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              )),
        ),
        FutureBuilder(
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Text(
                      '${snapshot.error} occurred',
                      style: TextStyle(fontSize: 18),
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
            return SliverToBoxAdapter(
                child:
                const Center(child: CircularProgressIndicator()));
          },
          future: podcastService.getPodcastDetailEpisodes(
              podcastSearchResult.id!, sort, -1),
        ),
      ],
    );
  }
}
