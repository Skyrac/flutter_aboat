import '../chat/join-room-dto.dart';

class SearchResult {
  int? id;
  int? roomId;
  String? title;
  String? image;
  String? description;

  SearchResult({
    this.id,
    this.title,
    this.image,
    this.description,
    this.roomId,
  });

  SearchResult.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    image = json['image'];
    description = json['description'];
    roomId = json['roomId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['image'] = image;
    data['description'] = description;
    data['roomId'] = roomId;
    return data;
  }
}
