import 'package:Talkaboat/models/podcasts/podcast-genre.model.dart';
import 'package:Talkaboat/models/podcasts/podcast-rank.model.dart';
import 'package:Talkaboat/services/user/user.service.dart';
import 'package:Talkaboat/utils/preference-keys.const.dart';
import 'package:flutter/material.dart';

import '../../injection/injector.dart';
import '../../models/podcasts/episode.model.dart';
import '../../models/podcasts/podcast.model.dart';
import '../../models/response.model.dart';
import '../repositories/podcast.repository.dart';
import '../user/store.service.dart';

class PodcastService {
  Podcast? podcast;
  final userService = getIt<UserService>();
  final store = getIt<StoreService>();
  Map<Rank, List<Podcast>> randomRankPodcasts = {};



  Future<List<Episode>> getPodcastDetailEpisodes(podcastId, sort, amount) async {
    final sortValue = await store.get(PreferenceKeys.sortState, (sort == "asc" ? 1 : -1));
    sort = sortValue == 0 ? "asc" : "desc";
    await getPodcastDetails(podcastId, sort, amount);

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

  Future<bool> sendPodcastKycOwnershipRequest(int podcastId) async {
    return await PodcastRepository.sendPodcastKycOwnershipRequest(podcastId);
  }

  Future<ResponseModel> getPodcastOwnerDetails(int podcastId) {
    return PodcastRepository.getPodcastOwnership(podcastId);
  }

  Future<List<Podcast>> getRandomPodcastsByRank(int amount, Rank rank) async {
    if(!randomRankPodcasts.containsKey(rank) || randomRankPodcasts[rank]!.length < amount) {
      randomRankPodcasts[rank] = await PodcastRepository.getRandomPodcastsByRank(amount, rank, userService.selectedLanguage);
    }
    return Future.value(randomRankPodcasts[rank]!.take(amount).toList());
  }

  Future<Podcast> getPodcastDetails(int podcastId, String sort, int amount) async {
    podcast = await PodcastRepository.getPodcastDetails(podcastId, sort, amount, 0);

    return podcast ?? Podcast();
  }

  Future<List<Podcast>> getTopPodcastByGenre(int amount, int genre) {
    return PodcastRepository.getTopPodcastByGenre(amount, genre, userService.selectedLanguage);
  }

  Future<List<Podcast>> getNewcomersByGenre(int amount, int genre) {
    return PodcastRepository.getNewcomersByGenre(amount, genre, userService.selectedLanguage);
  }

  List<PodcastGenre>? genres;

  Future<List<PodcastGenre>> getGenres({bool forceRefresh = false}) async {
    if (genres != null && !forceRefresh) {
      return genres!;
    } else {
      genres = await PodcastRepository.getGenres();
      return genres!;
    }
  }

  Future<List<Podcast>> search(String search, {int? genre, int amount = 10, int offset = 0, Rank? rank}) {
    return PodcastRepository.search(search, amount, offset, genre: genre, rank: rank, language: userService.selectedLanguage);
  }
}

enum PodcastOwnershipMethods { FULL, KYC, OWNED, ERROR, UNDEFINED }
