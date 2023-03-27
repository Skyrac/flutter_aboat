import 'dart:convert';

import 'package:Talkaboat/models/podcasts/podcast-genre.model.dart';
import 'package:Talkaboat/models/podcasts/podcast-rank.model.dart';
import 'package:Talkaboat/services/user/user.service.dart';
import 'package:Talkaboat/utils/preference-keys.const.dart';
import 'package:flutter/material.dart';

import '../../injection/injector.dart';
import '../../models/podcasts/episode.model.dart';
import '../../models/podcasts/podcast.model.dart';
import '../../models/response.model.dart';
import '../../models/search/search_result.model.dart';
import '../device/connection-state.service.dart';
import '../repositories/podcast.repository.dart';
import '../user/store.service.dart';

class PodcastService {
  Podcast? podcast;
  final userService = getIt<UserService>();
  final store = getIt<StoreService>();
  final connectionState = getIt<ConnectionStateService>();
  Map<Rank, List<Podcast>> randomRankPodcasts = {};



  Future<List<Episode>> getPodcastDetailEpisodes(podcastId, sort, amount) async {
    final sortValue = await store.get(PreferenceKeys.sortState, (sort == "asc" ? 1 : -1));
    sort = sortValue == 0 ? "asc" : "desc";
    await getPodcastDetails(podcastId, sort, amount);

    final episodes = podcast?.episodes ?? List.empty();
    for(var episode in episodes) {

      final storedPlayTime = await store.get("${PreferenceKeys.episodePlaytime}${episode.id}", episode.playTime);
      if(storedPlayTime != null && episode.playTime == null || episode.playTime == 0) {
        episode.playTime = storedPlayTime;
      }
    }
    return episodes;
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
    if(connectionState.isConnected) {
      podcast = await PodcastRepository.getPodcastDetails(podcastId, sort, amount, 0);
    } else {
      final podcastRaw = await store.get("${PreferenceKeys.podcastDetails}${podcastId}", "");

      if(podcastRaw != "") {
        podcast = Podcast.fromJson(jsonDecode(podcastRaw));
        podcast?.episodes = await getStoredPodcastEpisodes(podcastId);
      }
    }
    return podcast ?? Podcast.empty();
  }

  Future<List<Episode>> getStoredPodcastEpisodes(int podcastId) async {
    var list = List<String>.empty();
    final episodeListRaw = await store.get(
        "${PreferenceKeys.storedEpisodes}${podcastId}",
        jsonEncode(list));
    if (episodeListRaw.isNotEmpty) {
      list = List<String>.from((jsonDecode(
          episodeListRaw) as List<dynamic>)
          .map((dynamic item) => item.toString()));
    }
    var episodes = List<Episode>.empty(growable: true);
    for(var episodeId in list) {
      var episodeRaw = await store.get("${PreferenceKeys.episodeDetails}${episodeId}", "");
      if(episodeRaw == "") {
        continue;
      }

      episodes.add(Episode.fromJson(jsonDecode(episodeRaw)));
    }
    return episodes;
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

  Future<List<SearchResult>> search(String search, {int? genre, int amount = 10, int offset = 0, Rank? rank}) {
    return PodcastRepository.search(search, amount, offset, genre: genre, rank: rank, language: userService.selectedLanguage);
  }
}

enum PodcastOwnershipMethods { FULL, KYC, OWNED, ERROR, UNDEFINED }
