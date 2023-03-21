import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/services/audio/podcast.service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../models/search/search_result.model.dart';
import 'episode-list.widget.dart';


class EpisodeHeaderList extends StatefulWidget {
  const EpisodeHeaderList({super.key, required this.podcastSearchResult, this.controller});

  final SearchResult podcastSearchResult;
  final ScrollController? controller;

  @override
  State<EpisodeHeaderList> createState() => _EpisodeHeaderListState();
}

class _EpisodeHeaderListState extends State<EpisodeHeaderList> {
  final podcastService = getIt<PodcastService>();

  // 0 for asc 1 for desc
  int sort = 0;

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Text("Published: "),
          AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return RotationTransition(turns: animation, child: child);
              },
              child: IconButton(
                icon: FaIcon(
                  sort == 0 ? FontAwesomeIcons.sortUp : FontAwesomeIcons.sortDown,
                  key: ValueKey<int>(sort),
                ),
                onPressed: () {
                  setState(() {
                    if (sort == 0) {
                      sort = 1;
                    } else {
                      sort = 0;
                    }
                  });
                },
              ))
        ],
      ),
      FutureBuilder(
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return SizedBox(
                  height: 100,
                  child: Center(
                    child: Text(
                      '${snapshot.error} occurred',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ));
            } else if (snapshot.hasData && snapshot.data != null) {
              // Extracting data from snapshot object
              return Flexible(
                  flex: 1,
                  child: EpisodeList(
                    podcastImage: widget.podcastSearchResult.image,
                    episodes: snapshot.data!,
                    controller: widget.controller,
                  ));
            }
          }
          return const SizedBox(height: 105, child: Center(child: CircularProgressIndicator()));
        },
        future: podcastService.getPodcastDetailEpisodes(widget.podcastSearchResult.id, sort == 0 ? "asc" : "desc", -1),
      )
    ]);
  }
}
