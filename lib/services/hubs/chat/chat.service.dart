import 'package:Talkaboat/models/chat/chat-dtos.dart';
import 'package:Talkaboat/models/chat/create-message-dto.dart';
import 'package:Talkaboat/models/chat/delete-message-dto.dart';
import 'package:Talkaboat/models/chat/edit-message-dto.dart';
import 'package:Talkaboat/models/chat/join-room-dto.dart';
import 'package:Talkaboat/models/chat/message-history-request-dto.dart';
import 'package:Talkaboat/services/hubs/chat/chat-hub.service.dart';
import 'package:flutter/material.dart';

class ChatService extends ChangeNotifier {
  final ChatHubService _hub = ChatHubService();
  final Map<int, List<ChatMessageDto>?> _rooms = {};

  bool get isConnected => _hub.isConnected;

  connect() async {
    await _hub.connect();
    // TODO: locking to be async safe
    _hub.onDeleteMessage.listen((event) {
      if (_rooms[event.chatRoomId] != null) {
        _rooms[event.chatRoomId]!.removeWhere((value) => value.id == event.id);
        notifyListeners();
      } else {
        print("Tried to delete message that was not cached localy");
      }
    });
    _hub.onEditMessage.listen((event) {
      if (_rooms[event.chatRoomId] != null) {
        _rooms[event.chatRoomId]!.removeWhere((value) => value.id == event.id);
        _rooms[event.chatRoomId]!.add(event);
        notifyListeners();
      } else {
        print("Tried to edit message that was not cached localy");
      }
    });
    _hub.onReceiveMessage.listen((event) {
      if (_rooms[event.chatRoomId] != null) {
        _rooms[event.chatRoomId]!.add(event);
        notifyListeners();
      } else {
        print("Tried to edit message that was not cached localy");
      }
    });
  }

  //#region RPC Calls
  sendMessage(CreateMessageDto message) async {
    await _hub.sendMessage(message);
    _rooms[message.chatRoomId]!.add(ChatMessageDto(
        chatRoomId: message.chatRoomId,
        messageType: message.messageType,
        id: -1,
        content: message.content,
        senderName: "acc",
        isEdited: false));
    notifyListeners();
  }

  editMessage(EditMessageDto message) async {
    await _hub.editMessage(message);
  }

  deleteMessage(DeleteMessageDto message) async {
    await _hub.deleteMessage(message);
  }

  joinRoom(JoinRoomDto data) async {
    await _hub.joinRoom(data);
    _rooms[data.roomId] = List.empty(growable: true);
  }

  leaveRoom(JoinRoomDto data) async {
    await _hub.leaveRoom(data);
    _rooms[data.roomId] = null;
  }

  Future<List<ChatMessageDto>> getHistory(MessageHistoryRequestDto data, {bool forceRefresh = false}) async {
    if (_rooms[data.roomId] == null) {
      _rooms[data.roomId] = List.empty(growable: true);
    }
    if (_rooms[data.roomId]!.isEmpty || forceRefresh) {
      List<ChatMessageDto> messages = await _hub.getHistory(data);
      _rooms[data.roomId]!.addAll(messages);
    }
    return _rooms[data.roomId] ?? List.empty();
  }
  //#endregion
}
