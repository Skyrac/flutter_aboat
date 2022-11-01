import 'dart:async';
import 'dart:convert';

import 'package:Talkaboat/models/chat/chat-dtos.dart';
import 'package:Talkaboat/models/chat/create-message-dto.dart';
import 'package:Talkaboat/models/chat/delete-message-dto.dart';
import 'package:Talkaboat/models/chat/edit-message-dto.dart';
import 'package:Talkaboat/models/chat/join-room-dto.dart';
import 'package:Talkaboat/models/chat/message-history-request-dto.dart';
import 'package:Talkaboat/services/hubs/hub-service.dart';

class ChatHubService extends HubService {

  @override
  String get hubName => "chat";

  ChatHubService() : super() {
    connection.on("ReceiveMessage", receiveNewMessage);
    connection.on("EditMessage", receiveEditedMessage);
    connection.on("DeleteMessage", receiveDeletedMessage);
  }

  @override
  connect() async {
    await connect();
  }

  //#region Events
  final StreamController<ChatMessageDto> onReceiveMessageController = StreamController.broadcast();
  final StreamController<ChatMessageDto> onEditMessageController = StreamController.broadcast();
  final StreamController<ChatMessageDto> onDeleteMessageController = StreamController.broadcast();

  Stream<ChatMessageDto> get onReceiveMessage => onReceiveMessageController.stream;
  Stream<ChatMessageDto> get onEditMessage => onEditMessageController.stream;
  Stream<ChatMessageDto> get onDeleteMessage => onDeleteMessageController.stream;
  void receiveNewMessage(List<Object?>? data) {
    if(data != null && data[0] != null) {
      var value = data[0];
      var message = ChatMessageDto.fromJson(jsonDecode(jsonEncode(value)));
      onReceiveMessageController.add(message);
    }
  }

  void receiveEditedMessage(List<Object?>? data) {
    if(data != null && data[0] != null) {
      var value = data[0];
      var message = ChatMessageDto.fromJson(jsonDecode(jsonEncode(value)));
      onEditMessageController.add(message);
    }
  }

  void receiveDeletedMessage(List<Object?>? data) {
    if(data != null && data[0] != null) {
      var value = data[0];
      var message = ChatMessageDto.fromJson(jsonDecode(jsonEncode(value)));
      onDeleteMessageController.add(message);
    }
  }
  //#endregion

  //#region RPC Calls
  sendMessage(CreateMessageDto message) async {
     await connection.invoke("SendMessage", args: <Object>[message]);
  }
  editMessage(EditMessageDto message) async {
    await connection.invoke("EditMessage", args: <Object>[message]);
  }
  deleteMessage(DeleteMessageDto message) async {
    await connection.invoke("DeleteMessage", args: <Object>[message]);
  }
  joinRoom(JoinRoomDto data) async {
    await connection.invoke("JoinRoom", args: <Object>[data]);
  }
  leaveRoom(JoinRoomDto data) async {
    await connection.invoke("LeaveRoom", args: <Object>[data]);
  }
  Future<List<ChatMessageDto>> getHistory(MessageHistoryRequestDto data) async {
    var response = await connection.invoke("GetHistory", args: <Object>[data]);
    if(response == null) {
      return List.empty();
    }
    var convertedData = List<ChatMessageDto>.from(json.decode(json.encode(response)).map((data) => ChatMessageDto.fromJson(data)));
    return convertedData;
  }
  //#endregion
}