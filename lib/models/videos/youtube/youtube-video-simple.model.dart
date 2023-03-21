import 'package:json_annotation/json_annotation.dart';

part 'youtube-video-simple.model.g.dart';

@JsonSerializable()
class YoutubeVideoSimple {
  String id;
  String url;
  String title;
  String thumbnailUrl;
  String duration;
  String author;

  YoutubeVideoSimple(this.id,this.url,this.title,this.thumbnailUrl,this.duration,this.author,);

  factory YoutubeVideoSimple.fromJson(Map<String, dynamic> json) => _$YoutubeVideoFromJson(json);

  Map<String, dynamic> toJson() => _$YoutubeVideoToJson(this);
}