import 'package:Talkaboat/models/podcasts/podcast-genre.model.dart';

import '../../models/podcasts/episode.model.dart';
import '../../models/podcasts/podcast.model.dart';
import '../../models/response.model.dart';
import '../repositories/podcast.repository.dart';

class PodcastService {
  Podcast? podcast = null;

  Future<List<Episode>> getPodcastDetailEpisodes(podcastId, sort, amount) async {
    if (podcast != null && podcast!.episodes != null && podcast!.episodes!.isNotEmpty && podcast!.podcastId == podcastId) {
      podcast!.episodes!.sort((a, b) => a.pubDateMs!.compareTo(b.pubDateMs!) * (sort == "asc" ? 1 : -1));
    } else {
      await getPodcastDetails(podcastId, sort, amount);
    }
    return podcast?.episodes ?? List.empty();
  }

  Future<PodcastOwnershipMethods> getPodcastOwnershipMethods(int podcastId) async {
    var viableOption = await PodcastRepository.getPodcastOwnership(podcastId);

    switch (viableOption.text) {
      case 'full':
        return PodcastOwnershipMethods.FULL;
      case 'kyc':
        return PodcastOwnershipMethods.KYC;
      case 'owned':
        return PodcastOwnershipMethods.OWNED;
      default:
        return PodcastOwnershipMethods.ERROR;
    }
  }

  Future<ResponseModel> getPodcastOwnerDetails(int podcastId) {
    return PodcastRepository.getPodcastOwnership(podcastId);
  }

  Future<Podcast> getPodcastDetails(int podcastId, String sort, int amount) async {
    if (podcast == null || podcast!.podcastId != podcastId) {
      podcast = await PodcastRepository.getPodcastDetails(podcastId, sort, amount, 0);
    }
    return podcast ?? Podcast();
  }

  Future<List<Podcast>> getTopPodcastByGenre(int amount, int genre) {
    return PodcastRepository.getTopPodcastByGenre(amount, genre);
  }

  Future<List<Podcast>> getNewcomersByGenre(int amount, int genre) {
    return PodcastRepository.getNewcomersByGenre(amount, genre);
  }

  List<PodcastGenre>? genres;

  Future<List<PodcastGenre>> getGenres({bool forceRefresh = false}) async {
    if (genres != null && !forceRefresh) {
      print(genres);
      return genres!;
    } else {
      print("no genres");
      genres = await PodcastRepository.getGenres();
      print(genres);
      return genres!;
    }
  }
}

enum PodcastOwnershipMethods { FULL, KYC, OWNED, ERROR, UNDEFINED }
