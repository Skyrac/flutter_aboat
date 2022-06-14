class SearchResult {
  int? id;
  String? title;
  String? image;
  String? description;

  SearchResult({this.id, this.title, this.image, this.description});

  SearchResult.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    image = json['image'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['image'] = image;
    data['description'] = description;
    return data;
  }
}
