import 'episode.model.dart';

class Podcast {
  int? aboatId;
  String? id;
  Null? image;
  Null? genreIds;
  Null? thumbnail;
  Null? titleOriginal;
  Null? listennotesUrl;
  Null? titleHighlighted;
  Null? publisherOriginal;
  Null? publisherHighlighted;
  Null? listenScoreGlobalRank;
  Null? rss;
  Null? type;
  Null? email;
  Null? extra;
  List<Episode>? episodes;
  Null? title;
  Null? country;
  Null? website;
  Null? language;
  int? itunesId;
  Null? publisher;
  bool? isClaimed;
  Null? description;
  int? totalEpisodes;
  bool? explicitContent;
  int? latestPubDateMs;
  int? earliestPubDateMs;

  Podcast(
      {this.aboatId,
      this.id,
      this.image,
      this.genreIds,
      this.thumbnail,
      this.titleOriginal,
      this.listennotesUrl,
      this.titleHighlighted,
      this.publisherOriginal,
      this.publisherHighlighted,
      this.listenScoreGlobalRank,
      this.rss,
      this.type,
      this.email,
      this.extra,
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
      this.earliestPubDateMs});

  Podcast.fromJson(Map<String, dynamic> json) {
    aboatId = json['aboat_id'];
    id = json['id'];
    image = json['image'];
    genreIds = json['genre_ids'];
    thumbnail = json['thumbnail'];
    titleOriginal = json['title_original'];
    listennotesUrl = json['listennotes_url'];
    titleHighlighted = json['title_highlighted'];
    publisherOriginal = json['publisher_original'];
    publisherHighlighted = json['publisher_highlighted'];
    listenScoreGlobalRank = json['listen_score_global_rank'];
    rss = json['rss'];
    type = json['type'];
    email = json['email'];
    extra = json['extra'];
    if (json['episodes'] != null) {
      episodes = <Episode>[];
      json['episodes'].forEach((v) {
        episodes!.add(new Episode.fromJson(v));
      });
    }
    title = json['title'];
    country = json['country'];
    website = json['website'];
    language = json['language'];
    itunesId = json['itunes_id'];
    publisher = json['publisher'];
    isClaimed = json['is_claimed'];
    description = json['description'];
    totalEpisodes = json['total_episodes'];
    explicitContent = json['explicit_content'];
    latestPubDateMs = json['latest_pub_date_ms'];
    earliestPubDateMs = json['earliest_pub_date_ms'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['aboat_id'] = this.aboatId;
    data['id'] = this.id;
    data['image'] = this.image;
    data['genre_ids'] = this.genreIds;
    data['thumbnail'] = this.thumbnail;
    data['title_original'] = this.titleOriginal;
    data['listennotes_url'] = this.listennotesUrl;
    data['title_highlighted'] = this.titleHighlighted;
    data['publisher_original'] = this.publisherOriginal;
    data['publisher_highlighted'] = this.publisherHighlighted;
    data['listen_score_global_rank'] = this.listenScoreGlobalRank;
    data['rss'] = this.rss;
    data['type'] = this.type;
    data['email'] = this.email;
    data['extra'] = this.extra;
    if (this.episodes != null) {
      data['episodes'] = this.episodes!.map((v) => v.toJson()).toList();
    }
    data['title'] = this.title;
    data['country'] = this.country;
    data['website'] = this.website;
    data['language'] = this.language;
    data['itunes_id'] = this.itunesId;
    data['publisher'] = this.publisher;
    data['is_claimed'] = this.isClaimed;
    data['description'] = this.description;
    data['total_episodes'] = this.totalEpisodes;
    data['explicit_content'] = this.explicitContent;
    data['latest_pub_date_ms'] = this.latestPubDateMs;
    data['earliest_pub_date_ms'] = this.earliestPubDateMs;
    return data;
  }
}
