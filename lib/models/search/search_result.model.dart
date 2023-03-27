class SearchResult {
  int? id;
  int? roomId;
  int? totalEpisodes;
  int? rank;
  String? title;
  String? image;
  String? description;

  SearchResult({
    this.id,
    this.title,
    this.image,
    this.description,
    this.roomId,
    this.totalEpisodes
  });

  SearchResult.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    image = json['image'];
    description = json['description'];
    roomId = json['roomId'];
    totalEpisodes = json['totalEpisodes'];
    rank = json['rank'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['image'] = image;
    data['description'] = description;
    data['roomId'] = roomId;
    data['totalEpisodes'] = totalEpisodes;
    data['rank'] = rank;
    return data;
  }
}
