// -- edit_message_dto.dart --
import 'package:json_annotation/json_annotation.dart';

part 'edit-message-dto.g.dart';

@JsonSerializable()
class EditMessageDto {
  int messageId;
  int roomId;
  String message;

  EditMessageDto(this.messageId,this.roomId,this.message,);

  factory EditMessageDto.fromJson(Map<String, dynamic> json) => _$EditMessageDtoFromJson(json);

  Map<String, dynamic> toJson() => _$EditMessageDtoToJson(this);
}
