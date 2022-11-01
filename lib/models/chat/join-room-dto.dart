// -- join_room_dto.dart --
import 'package:json_annotation/json_annotation.dart';

part 'join-room-dto.g.dart';

@JsonSerializable()
class JoinRoomDto {
  int roomId;

  JoinRoomDto(this.roomId);

  factory JoinRoomDto.fromJson(Map<String, dynamic> json) => _$JoinRoomDtoFromJson(json);

  Map<String, dynamic> toJson() => _$JoinRoomDtoToJson(this);
}
