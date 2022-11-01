// -- chat_room_dto.dart --
import 'package:json_annotation/json_annotation.dart';

part 'chat-dtos.g.dart';

@JsonSerializable()
class ChatRoomDto {
  int id;
  String name;
  int roomType;
  int superAdmin;
  String? encryption;
  List<ChatMessageDto>? messages;
  List<ChatMemberDto>? members;

  ChatRoomDto({required this.id,required this.name,required this.roomType,required this.superAdmin,this.encryption,this.messages,this.members});

  factory ChatRoomDto.fromJson(Map<String, dynamic> json) => _$ChatRoomDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ChatRoomDtoToJson(this);
}

@JsonSerializable()
class ChatMessageDto {
  int id;
  int chatRoomId;
  ChatMessageDto? answeredMessage;
  int messageType;
  int? typeId;
  String content;
  String senderName;
  DateTime? updated;
  bool isEdited;
  ChatMemberDto? chatMember;

  ChatMessageDto({required this.id,required this.chatRoomId,this.answeredMessage,required this.messageType,this.typeId,required this.content, required this.senderName,this.updated,required this.isEdited,this.chatMember});

  factory ChatMessageDto.fromJson(Map<String, dynamic> json) => _$ChatMessageDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ChatMessageDtoToJson(this);
}

@JsonSerializable()
class ChatMemberDto {
  int userId;
  String username;
  bool isAdmin;

  ChatMemberDto(this.userId,this.username,this.isAdmin,);

  factory ChatMemberDto.fromJson(Map<String, dynamic> json) => _$ChatMemberDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ChatMemberDtoToJson(this);
}
