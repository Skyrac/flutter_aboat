// -- create_chat_room_dto.dart --
import 'package:json_annotation/json_annotation.dart';

part 'create-chat-room-dto.g.dart';

@JsonSerializable()
class CreateChatRoomDto {
  String name;
  int roomType;
  String encryption;

  CreateChatRoomDto(this.name,this.roomType,this.encryption,);

  factory CreateChatRoomDto.fromJson(Map<String, dynamic> json) => _$CreateChatRoomDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreateChatRoomDtoToJson(this);
}
