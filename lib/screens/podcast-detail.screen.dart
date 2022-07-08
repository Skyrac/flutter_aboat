import 'package:flutter/material.dart';
import 'package:talkaboat/models/podcasts/episode.model.dart';
import 'package:talkaboat/models/search/search_result.model.dart';
import 'package:talkaboat/services/audio/audio-handler.services.dart';
import 'package:talkaboat/services/audio/podcast.service.dart';

import '../injection/injector.dart';
import '../themes/colors.dart';
import '../widgets/episode-preview.widget.dart';
import '../widgets/podcast-detail-sliver.widget.dart';

class PodcastDetailScreen extends StatefulWidget {
  final SearchResult? podcastSearchResult;
  const PodcastDetailScreen({Key? key, this.podcastSearchResult})
      : super(key: key);

  @override
  State<PodcastDetailScreen> createState() => _PodcastDetailScreenState();
}

class _PodcastDetailScreenState extends State<PodcastDetailScreen> {
  final audioPlayer = getIt<AudioPlayerHandler>();
  final podcastService = getIt<PodcastService>();
  var sort = "asc";
  var isDescOpen = false;
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
    return Scaffold(
        body: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
              DefaultColors.primaryColor.shade900,
              DefaultColors.secondaryColor.shade900,
              DefaultColors.secondaryColor.shade900
            ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
            child: CustomScrollView(
              slivers: [
                SliverPersistentHeader(
                  delegate: PodcastDetailSliver(
                      expandedHeight: size.height * 0.5,
                      podcast: widget.podcastSearchResult!),
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
                                  widget.podcastSearchResult?.description ?? '',
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
                      widget.podcastSearchResult!.id!, sort, -1),
                ),
              ],
            )));
  }
}
