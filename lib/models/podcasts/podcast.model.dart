class Podcast {
  final int aboatId;
  final String title;
  final String image;

  const Podcast(
      {required this.aboatId, required this.image, required this.title});

  factory Podcast.fromJson(Map<String, dynamic> json) {
    return Podcast(
      aboatId: json['aboat_id'],
      image: json['image'],
      title: json['title'],
    );
  }
}
