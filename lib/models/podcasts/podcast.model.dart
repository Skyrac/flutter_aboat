import '../search/search_result.model.dart';
import 'episode.model.dart';

class Podcast extends SearchResult {
  int? podcastId;
  @override
  int? id;
  @override
  String? image;
  String? genreIds;
  String? thumbnail;
  String? titleOriginal;
  String? listennotesUrl;
  String? titleHighlighted;
  String? publisherOriginal;
  String? publisherHighlighted;
  String? rss;
  String? type;
  String? email;
  List<Episode>? episodes;
  @override
  String? title;
  String? country;
  String? website;
  String? language;
  int? itunesId;
  String? publisher;
  bool? isClaimed;
  @override
  String? description;
  int? totalEpisodes;
  bool? explicitContent;
  int? latestPubDateMs;
  int? earliestPubDateMs;
  DateTime? lastUpdate;

  Podcast(
      {this.podcastId,
      super.id,
      this.image,
      this.genreIds,
      this.thumbnail,
      this.titleOriginal,
      this.listennotesUrl,
      this.titleHighlighted,
      this.publisherOriginal,
      this.publisherHighlighted,
      this.rss,
      this.type,
      this.email,
      this.episodes,
      this.title,
      this.country,
      this.website,
      this.language,
      this.itunesId,
      this.publisher,
      this.isClaimed,
      this.description,
      this.totalEpisodes,
      this.explicitContent,
      this.latestPubDateMs,
      this.earliestPubDateMs,
      this.lastUpdate});

  Podcast.fromJson(Map<String, dynamic> json) {
    if (json['podcastId'] != null) {
      podcastId = json['podcastId'];
      id = json['podcastId'];
    } else {
      podcastId = json['id'];
      id = json['id'];
    }
    image = json['image'];
    genreIds = json['genres'];
    thumbnail = json['thumbnail'];
    titleOriginal = json['title'];
    listennotesUrl = json['listennotes_url'];
    titleHighlighted = json['title_highlighted'];
    publisherOriginal = json['publisher_original'];
    publisherHighlighted = json['publisher_highlighted'];
    rss = json['rss'];
    type = json['type'];
    email = json['email'];

    totalEpisodes = json['totalEpisodes'];
    if (json['episodes'] != null) {
      if (json["episodes"].runtimeType == int) {
        totalEpisodes = json["episodes"];
      } else {
        episodes = [];
        json['episodes'].forEach((v) {
          episodes!.add(Episode.fromJson(v));
        });
      }
    }
    title = json['title'];
    country = json['country'];
    website = json['website'];
    language = json['language'];
    itunesId = json['itunes_id'];
    publisher = json['publisher'];
    isClaimed = json['is_claimed'];
    description = json['description'];
    explicitContent = json['explicitContent'];
    latestPubDateMs = json['latestPubDate'];
    earliestPubDateMs = json['earliest_pub_date_ms'];
    lastUpdate = json['lastUpdate'] != null ? DateTime.parse(json['lastUpdate']) : null;
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['podcastId'] = podcastId;
    data['id'] = podcastId;
    data['image'] = image;
    data['genres'] = genreIds;
    data['thumbnail'] = thumbnail;
    data['title_original'] = titleOriginal;
    data['listennotes_url'] = listennotesUrl;
    data['title_highlighted'] = titleHighlighted;
    data['publisher_original'] = publisherOriginal;
    data['publisher_highlighted'] = publisherHighlighted;
    data['rss'] = rss;
    data['type'] = type;
    data['email'] = email;
    if (episodes != null) {
      data['episodes'] = episodes!.map((v) => v.toJson()).toList();
    }
    data['title'] = title;
    data['country'] = country;
    data['website'] = website;
    data['language'] = language;
    data['itunes_id'] = itunesId;
    data['publisher'] = publisher;
    data['is_claimed'] = isClaimed;
    data['description'] = description;
    data['total_episodes'] = totalEpisodes;
    data['explicit_content'] = explicitContent;
    data['latestPubDate'] = latestPubDateMs;
    data['earliest_pub_date_ms'] = earliestPubDateMs;
    data['lastUpdate'] = lastUpdate;
    return data;
  }
}
