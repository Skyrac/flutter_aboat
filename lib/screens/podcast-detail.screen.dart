import 'package:flutter/material.dart';
import 'package:talkaboat/models/podcasts/episode.model.dart';
import 'package:talkaboat/models/search/search_result.model.dart';

import '../services/repositories/podcast.repository.dart';
import '../themes/colors.dart';
import '../utils/image_widget.dart';
import '../widgets/episode-list.widget.dart';
import '../widgets/podcast-detail-sliver.widget.dart';

class PodcastDetailScreen extends StatefulWidget {
  final SearchResult? podcastSearchResult;
  const PodcastDetailScreen({Key? key, this.podcastSearchResult})
      : super(key: key);

  @override
  State<PodcastDetailScreen> createState() => _PodcastDetailScreenState();
}

class _PodcastDetailScreenState extends State<PodcastDetailScreen> {
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

  // buildImages() => SliverToBoxAdapter(
  //         child: Container(
  //       height: 800,
  //       child: FutureBuilder(
  //         builder: (context, snapshot) {
  //           if (snapshot.connectionState == ConnectionState.done) {
  //             if (snapshot.hasError) {
  //               return Center(
  //                 child: Text(
  //                   '${snapshot.error} occurred',
  //                   style: TextStyle(fontSize: 18),
  //                 ),
  //               );
  //             } else if (snapshot.hasData && snapshot.data != null) {
  //               // Extracting data from snapshot object
  //               final data = snapshot.data as List<Episode>?;
  //               if (data != null && data.isNotEmpty) {
  //                 var searchResults = data;
  //                 return GridView.builder(
  //                     gridDelegate:
  //                         const SliverGridDelegateWithFixedCrossAxisCount(
  //                             crossAxisCount: 2),
  //                     primary: false,
  //                     shrinkWrap: true,
  //                     itemCount: searchResults.length,
  //                     itemBuilder: (context, index) =>
  //                         EpisodePreviewWidget(searchResults[index]));
  //               }
  //             }
  //           }
  //           return const Center(child: CircularProgressIndicator());
  //         },
  //         future: PodcastRepository.getEpisodesMock(10),
  //       ),
  //     ));

  Widget buildImages() => SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => ImageWidget(index: index),
          childCount: 20,
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
            delegate:
                CustomSliverAppBarDelegate(expandedHeight: size.height * 0.5),
            pinned: true,
          ),
          buildImages(),
        ],
      ),
    ));
    return Scaffold(
        body: Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
        DefaultColors.primaryColor.shade900,
        DefaultColors.secondaryColor.shade900,
        DefaultColors.secondaryColor.shade900
      ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
      child: Column(
        children: [
          topContent(context),
          Expanded(
            child: OverflowBox(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
              child: FutureBuilder(
                builder: (context, snapshot) {
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
                      final data = snapshot.data as List<Episode>?;
                      if (data != null && data.isNotEmpty) {
                        var searchResults = data;
                        return EpisodeListWidget(
                            direction: Axis.vertical, episodes: searchResults);
                      }
                    }
                  }
                  return const Center(child: CircularProgressIndicator());
                },
                future: PodcastRepository.getEpisodesMock(10),
              ),
            ),
          )
        ],
      ),
    ));
  }
}
