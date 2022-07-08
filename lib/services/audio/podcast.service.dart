import 'package:talkaboat/models/podcasts/episode.model.dart';
import 'package:talkaboat/services/repositories/podcast.repository.dart';

class PodcastService {
  List<Episode> podcastDetailEpisodes = [];

  Future<List<Episode>> getPodcastDetailEpisodes(
      podcastId, sort, amount) async {
    if (podcastDetailEpisodes.isNotEmpty &&
        podcastDetailEpisodes[0].podcastId == podcastId) {
      podcastDetailEpisodes.sort((a, b) =>
          a.pubDateMs!.compareTo(b.pubDateMs!) * (sort == "asc" ? 1 : -1));
    } else {
      podcastDetailEpisodes = await PodcastRepository.getEpisodesOfPodcast(
          podcastId, sort, amount, 0);
    }
    return podcastDetailEpisodes;
  }
}
