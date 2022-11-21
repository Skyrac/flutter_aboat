import 'dart:async';

import 'package:Talkaboat/models/chat/chat-dtos.dart';
import 'package:Talkaboat/models/chat/create-message-dto.dart';
import 'package:Talkaboat/models/chat/delete-message-dto.dart';
import 'package:Talkaboat/models/chat/edit-message-dto.dart';
import 'package:Talkaboat/models/chat/join-room-dto.dart';
import 'package:Talkaboat/models/chat/message-history-request-dto.dart';
import 'package:Talkaboat/services/hubs/chat/chat-hub.service.dart';
import 'package:flutter/material.dart';

// https://stackoverflow.com/a/42091982
class AsyncMutex {
  Future _next = Future.value(null);

  /// Request [operation] to be run exclusively.
  ///
  /// Waits for all previously requested operations to complete,
  /// then runs the operation and completes the returned future with the
  /// result.
  Future<T> run<T>(FutureOr<T> Function() operation) {
    var completer = Completer<T>();
    _next.whenComplete(() {
      completer.complete(Future<T>.sync(operation));
    });
    return _next = completer.future;
  }
}

class ChatService extends ChangeNotifier {
  static final List<String> messageType = ["", "Podcast", "Episode"];

  final ChatHubService _hub = ChatHubService();
  final Map<int, List<ChatMessageDto>?> _rooms = {};
  final AsyncMutex _mutex = AsyncMutex();

  bool get isConnected => _hub.isConnected;

  _reconcileNewMessage(ChatMessageDto message) {
    _mutex.run(() {
      if (_rooms[message.chatRoomId] != null) {
        if (_rooms[message.chatRoomId]!.any((x) => x.id < 0 && x.content == message.content)) {
          int index = _rooms[message.chatRoomId]!.indexWhere((x) => x.id < 0 && x.content == message.content);
          if (index != -1) {
            throw "unreachable";
          }
          _rooms[message.chatRoomId]!.removeAt(index);
          _rooms[message.chatRoomId]!.insert(index, message);
        } else {
          _rooms[message.chatRoomId]!.add(message);
        }
        notifyListeners();
      } else {
        print("Tried to edit message that was not cached localy");
      }
    });
  }

  _reconcileEditMessageFull(ChatMessageDto message) {
    _mutex.run(() {
      if (_rooms[message.chatRoomId] != null) {
        int index = _rooms[message.chatRoomId]!.indexWhere((x) => x.id == message.id);
        _rooms[message.chatRoomId]!.removeAt(index);
        _rooms[message.chatRoomId]!.insert(index, message);
        notifyListeners();
      } else {
        print("Tried to edit message that was not cached localy");
      }
    });
  }

  _reconcileRemoveMessage(int roomId, int messageId) {
    _mutex.run(() {
      if (_rooms[roomId] != null) {
        _rooms[roomId]!.removeWhere((value) => value.id == messageId);
        notifyListeners();
      } else {
        print("Tried to delete message that was not cached localy");
      }
    });
  }

  connect() async {
    await _hub.connect();
    _hub.onDeleteMessage.listen((event) => _reconcileRemoveMessage(event.chatRoomId, event.id));
    _hub.onEditMessage.listen((event) => _reconcileEditMessageFull(event));
    _hub.onReceiveMessage.listen((event) => _reconcileNewMessage(event));
  }

  //#region RPC Calls
  sendMessage(CreateMessageDto message, String username) async {
    await _hub.sendMessage(message);
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
