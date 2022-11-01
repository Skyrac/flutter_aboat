// -- create_message_dto.dart --
import 'package:json_annotation/json_annotation.dart';

part 'create-message-dto.g.dart';

@JsonSerializable()
class CreateMessageDto {
  int userId;
  int chatRoomId;
  String content;
  int messageType;
  int? typeId;
  int? answerId;

  CreateMessageDto(this.userId,this.chatRoomId,this.content,this.messageType,this.typeId,this.answerId,);

  factory CreateMessageDto.fromJson(Map<String, dynamic> json) => _$CreateMessageDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreateMessageDtoToJson(this);
}