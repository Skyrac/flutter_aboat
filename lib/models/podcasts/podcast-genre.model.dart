class PodcastGenre {
  late String name;
  String? imageUrl;
  late int genreId;

  PodcastGenre(this.name, this.imageUrl, this.genreId);

  PodcastGenre.fromJson(Map<String, dynamic> json) {
    name = json['genreName'];
    imageUrl = json['genreIcon'];
    genreId = json['genreId'];
  }
}
