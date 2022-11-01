// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat-dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatRoomDto _$ChatRoomDtoFromJson(Map<String, dynamic> json) => ChatRoomDto(
      id: json['id'] as int,
      name: json['name'] as String,
      roomType: json['roomType'] as int,
      superAdmin: json['superAdmin'] as int,
      encryption: json['encryption'] as String?,
      messages: (json['messages'] as List<dynamic>?)
          ?.map((e) => ChatMessageDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      members: (json['members'] as List<dynamic>?)
          ?.map((e) => ChatMemberDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ChatRoomDtoToJson(ChatRoomDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'roomType': instance.roomType,
      'superAdmin': instance.superAdmin,
      'encryption': instance.encryption,
      'messages': instance.messages,
      'members': instance.members,
    };

ChatMessageDto _$ChatMessageDtoFromJson(Map<String, dynamic> json) =>
    ChatMessageDto(
      id: json['id'] as int,
      chatRoomId: json['chatRoomId'] as int,
      answeredMessage: json['answeredMessage'] == null
          ? null
          : ChatMessageDto.fromJson(
              json['answeredMessage'] as Map<String, dynamic>),
      messageType: json['messageType'] as int,
      typeId: json['typeId'] as int?,
      content: json['content'] as String,
      senderName: json['senderName'] as String,
      updated: json['updated'] == null
          ? null
          : DateTime.parse(json['updated'] as String),
      isEdited: json['isEdited'] as bool,
      chatMember: json['chatMember'] == null
          ? null
          : ChatMemberDto.fromJson(json['chatMember'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ChatMessageDtoToJson(ChatMessageDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'chatRoomId': instance.chatRoomId,
      'answeredMessage': instance.answeredMessage,
      'messageType': instance.messageType,
      'typeId': instance.typeId,
      'content': instance.content,
      'senderName': instance.senderName,
      'updated': instance.updated?.toIso8601String(),
      'isEdited': instance.isEdited,
      'chatMember': instance.chatMember,
    };

ChatMemberDto _$ChatMemberDtoFromJson(Map<String, dynamic> json) =>
    ChatMemberDto(
      json['userId'] as int,
      json['username'] as String,
      json['isAdmin'] as bool,
    );

Map<String, dynamic> _$ChatMemberDtoToJson(ChatMemberDto instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'username': instance.username,
      'isAdmin': instance.isAdmin,
    };