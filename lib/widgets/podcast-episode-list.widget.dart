import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/models/podcasts/episode.model.dart';
import 'package:Talkaboat/services/audio/audio-handler.services.dart';
import 'package:Talkaboat/services/audio/podcast.service.dart';
import 'package:Talkaboat/widgets/episode-preview.widget.dart';
import 'package:flutter/material.dart';

class PodcastEpisodeList extends StatefulWidget {
  const PodcastEpisodeList({super.key, required this.podcastId, required this.escapeWithNav});

  final int podcastId;
  final Function escapeWithNav;

  @override
  State<PodcastEpisodeList> createState() => _PodcastEpisodeListState();
}

class _PodcastEpisodeListState extends State<PodcastEpisodeList> {
  final podcastService = getIt<PodcastService>();
  final audioPlayer = getIt<AudioPlayerHandler>();

  selectEpisode(int index, List<Episode> data) async {
    var selectedEpisode = data[index];
    if (audioPlayer.isListeningEpisode(selectedEpisode.episodeId)) {
      audioPlayer.togglePlaybackState();
    } else {
      await audioPlayer.updateEpisodeQueue(data, index: index);
    }
  }

  Widget buildEpisodes(List<Episode> data) => ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          var episode = data[index];
          var episodeIndex = index;
          return EpisodePreviewWidget(episode, Axis.vertical, () => {selectEpisode(episodeIndex, data)},
              () => setState(() {}), widget.escapeWithNav);
        },
        itemCount: data.length, // 1000 list items
      );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
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
            if (snapshot.data != null && snapshot.data!.isNotEmpty) {
              return SizedBox(height: 105.0 * snapshot.data!.length, child: buildEpisodes(snapshot.data!));
            }
          }
        }
        return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
      },
      future: podcastService.getPodcastDetailEpisodes(widget.podcastId, "asc", -1),
    );
  }
}
