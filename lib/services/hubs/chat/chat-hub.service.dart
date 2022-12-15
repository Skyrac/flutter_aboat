import 'dart:async';
import 'dart:convert';

import 'package:Talkaboat/models/chat/chat-dtos.dart';
import 'package:Talkaboat/models/chat/create-message-dto.dart';
import 'package:Talkaboat/models/chat/delete-message-dto.dart';
import 'package:Talkaboat/models/chat/edit-message-dto.dart';
import 'package:Talkaboat/models/chat/join-room-dto.dart';
import 'package:Talkaboat/models/chat/message-history-request-dto.dart';
import 'package:Talkaboat/services/hubs/hub-service.dart';
import 'package:flutter/foundation.dart';

class ChatHubService extends HubService {
  @override
  String get hubName => "chat";

  ChatHubService() : super() {
    connection.on("ReceiveMessage", receiveNewMessage);
    connection.on("EditMessage", receiveEditedMessage);
    connection.on("DeleteMessage", receiveDeletedMessage);
  }

  //#region Events
  final StreamController<ChatMessageDto> onReceiveMessageController = StreamController.broadcast();
  final StreamController<ChatMessageDto> onEditMessageController = StreamController.broadcast();
  final StreamController<ChatMessageDto> onDeleteMessageController = StreamController.broadcast();

  Stream<ChatMessageDto> get onReceiveMessage => onReceiveMessageController.stream;
  Stream<ChatMessageDto> get onEditMessage => onEditMessageController.stream;
  Stream<ChatMessageDto> get onDeleteMessage => onDeleteMessageController.stream;
  void receiveNewMessage(List<Object?>? data) {
    if (data != null && data[0] != null) {
      var value = data[0];
      var message = ChatMessageDto.fromJson(jsonDecode(jsonEncode(value)));
      onReceiveMessageController.add(message);
    }
  }

  void receiveEditedMessage(List<Object?>? data) {
    if (data != null && data[0] != null) {
      var value = data[0];
      var message = ChatMessageDto.fromJson(jsonDecode(jsonEncode(value)));
      onEditMessageController.add(message);
    }
  }

  void receiveDeletedMessage(List<Object?>? data) {
    if (data != null && data[0] != null) {
      var value = data[0];
      var message = ChatMessageDto.fromJson(jsonDecode(jsonEncode(value)));
      onDeleteMessageController.add(message);
    }
  }
  //#endregion

  //#region RPC Calls
  sendMessage(CreateMessageDto message) async {
    if (!await checkConnection()) {
      return;
    }
    try {
      return await connection.invoke("SendMessage", args: <Object>[message]);
    } catch (e) {
      debugPrint("$e");
    }
  }

  editMessage(EditMessageDto message) async {
    if (!await checkConnection()) {
      return;
    }
    try {
      return await connection.invoke("EditMessage", args: <Object>[message]);
    } catch (e) {
      debugPrint("$e");
    }
  }

  deleteMessage(DeleteMessageDto message) async {
    if (!await checkConnection()) {
      return;
    }
    try {
      return await connection.invoke("DeleteMessage", args: <Object>[message]);
    } catch (e) {
      debugPrint("$e");
    }
  }

  joinRoom(JoinRoomDto data) async {
    if (!await checkConnection()) {
      return;
    }
    try {
      return await connection.invoke("JoinRoom", args: <Object>[data]);
    } catch (e) {
      debugPrint("$e");
    }
  }

  leaveRoom(JoinRoomDto data) async {
    if (!await checkConnection()) {
      return;
    }
    try {
      return await connection.invoke("LeaveRoom", args: <Object>[data]);
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future<List<ChatMessageDto>> getHistory(MessageHistoryRequestDto data) async {
    if (!await checkConnection()) {
      return List.empty();
    }
    try {
      var response = await connection.invoke("GetHistory", args: <Object>[data]);
      if (response == null) {
        return List.empty();
      }
      var convertedData =
          List<ChatMessageDto>.from(json.decode(json.encode(response)).map((data) => ChatMessageDto.fromJson(data)));
      return convertedData;
    } catch (e) {
      debugPrint("$e");
      return List.empty();
    }
  }
  //#endregion
}
