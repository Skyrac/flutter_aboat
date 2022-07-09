

import '../../models/podcasts/episode.model.dart';
import '../../models/response.model.dart';
import '../repositories/podcast.repository.dart';

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

  Future<PodcastOwnershipMethods> getPodcastOwnershipMethods(int podcastId) async {
    var viableOption = await PodcastRepository.getPodcastOwnership(podcastId);

    switch(viableOption.text) {
      case 'full': return PodcastOwnershipMethods.FULL;
      case 'kyc': return PodcastOwnershipMethods.KYC;
      case 'owned': return PodcastOwnershipMethods.OWNED;
      default: return PodcastOwnershipMethods.ERROR;
    }
  }

  Future<ResponseModel> getPodcastOwnerDetails(int podcastId) {
    return PodcastRepository.getPodcastOwnership(podcastId);
  }
}

enum PodcastOwnershipMethods {
  FULL,
  KYC,
  OWNED,
  ERROR
}
