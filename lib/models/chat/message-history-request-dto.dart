// -- message_history_request_dto.dart --
import 'package:json_annotation/json_annotation.dart';

part 'message-history-request-dto.g.dart';

@JsonSerializable()
class MessageHistoryRequestDto {
  int roomId;
  int direction;
  int? amount;
  int? offset;

  MessageHistoryRequestDto({required this.roomId, required this.direction,this.amount,this.offset});

  factory MessageHistoryRequestDto.fromJson(Map<String, dynamic> json) => _$MessageHistoryRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MessageHistoryRequestDtoToJson(this);
}
