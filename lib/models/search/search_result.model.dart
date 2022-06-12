class SearchResult {
  int? id;
  String? title;
  String? image;
  int? episodes;
  String? description;

  SearchResult(
      {this.id, this.title, this.image, this.episodes, this.description});

  SearchResult.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    image = json['image'];
    episodes = json['episodes'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['image'] = this.image;
    data['episodes'] = this.episodes;
    data['description'] = this.description;
    return data;
  }
}
