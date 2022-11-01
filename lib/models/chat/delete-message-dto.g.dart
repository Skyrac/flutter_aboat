// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete-message-dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeleteMessageDto _$DeleteMessageDtoFromJson(Map<String, dynamic> json) =>
    DeleteMessageDto(
      json['messageId'] as int,
      json['roomId'] as int,
    );

Map<String, dynamic> _$DeleteMessageDtoToJson(DeleteMessageDto instance) =>
    <String, dynamic>{
      'messageId': instance.messageId,
      'roomId': instance.roomId,
    };
