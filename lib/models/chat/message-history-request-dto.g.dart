// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message-history-request-dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageHistoryRequestDto _$MessageHistoryRequestDtoFromJson(
        Map<String, dynamic> json) =>
    MessageHistoryRequestDto(
      roomId: json['roomId'] as int,
      direction: json['direction'] as int,
      amount: json['amount'] as int?,
      offset: json['offset'] as int?,
    );

Map<String, dynamic> _$MessageHistoryRequestDtoToJson(
        MessageHistoryRequestDto instance) =>
    <String, dynamic>{
      'roomId': instance.roomId,
      'direction': instance.direction,
      'amount': instance.amount,
      'offset': instance.offset,
    };
