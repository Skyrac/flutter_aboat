// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create-chat-room-dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateChatRoomDto _$CreateChatRoomDtoFromJson(Map<String, dynamic> json) =>
    CreateChatRoomDto(
      json['name'] as String,
      json['roomType'] as int,
      json['encryption'] as String,
    );

Map<String, dynamic> _$CreateChatRoomDtoToJson(CreateChatRoomDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'roomType': instance.roomType,
      'encryption': instance.encryption,
    };
