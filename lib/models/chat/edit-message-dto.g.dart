// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit-message-dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EditMessageDto _$EditMessageDtoFromJson(Map<String, dynamic> json) =>
    EditMessageDto(
      json['messageId'] as int,
      json['roomId'] as int,
      json['message'] as String,
    );

Map<String, dynamic> _$EditMessageDtoToJson(EditMessageDto instance) =>
    <String, dynamic>{
      'messageId': instance.messageId,
      'roomId': instance.roomId,
      'message': instance.message,
    };
