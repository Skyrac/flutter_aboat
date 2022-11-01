// -- delete_message_dto.dart --
import 'package:json_annotation/json_annotation.dart';

part 'delete-message-dto.g.dart';

@JsonSerializable()
class DeleteMessageDto {
  int messageId;
  int roomId;

  DeleteMessageDto(this.messageId,this.roomId,);

  factory DeleteMessageDto.fromJson(Map<String, dynamic> json) => _$DeleteMessageDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DeleteMessageDtoToJson(this);
}
