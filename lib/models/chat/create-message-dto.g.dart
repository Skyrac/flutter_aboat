// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create-message-dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateMessageDto _$CreateMessageDtoFromJson(Map<String, dynamic> json) =>
    CreateMessageDto(
      json['userId'] as int,
      json['chatRoomId'] as int,
      json['content'] as String,
      json['messageType'] as int,
      json['typeId'] as int?,
      json['answerId'] as int?,
    );

Map<String, dynamic> _$CreateMessageDtoToJson(CreateMessageDto instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'chatRoomId': instance.chatRoomId,
      'content': instance.content,
      'messageType': instance.messageType,
      'typeId': instance.typeId,
      'answerId': instance.answerId,
    };
