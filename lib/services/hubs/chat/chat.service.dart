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
  // TODO: maybe use some kind of ring instead of list so that we only keep the last x messages + paging
  final Map<int, List<ChatMessageDto>?> _rooms = {};
  final AsyncMutex _mutex = AsyncMutex();

  bool get isConnected => _hub.isConnected;

  _reconcileNewMessage(ChatMessageDto message) {
    _mutex.run(() {
      if (_rooms[message.chatRoomId] != null) {
        if (!_rooms[message.chatRoomId]!.any((x) => x.id == message.id)) {
          _rooms[message.chatRoomId]!.add(message);
          notifyListeners();
        }
      } else {
        debugPrint("Tried to edit message that was not cached localy");
      }
    });
  }

  _reconcileEditMessageFull(ChatMessageDto message) {
    _mutex.run(() {
      if (_rooms[message.chatRoomId] != null) {
        int index = _rooms[message.chatRoomId]!.indexWhere((x) => x.id == message.id);
        if (index > -1) {
          _rooms[message.chatRoomId]!.removeAt(index);
          _rooms[message.chatRoomId]!.insert(index, message);
          notifyListeners();
        }
      } else {
        debugPrint("Tried to edit message that was not cached localy");
      }
    });
  }

  _reconcileRemoveMessage(int roomId, int messageId) {
    _mutex.run(() {
      if (_rooms[roomId] != null) {
        _rooms[roomId]!.removeWhere((value) => value.id == messageId);
        notifyListeners();
      } else {
        debugPrint("Tried to delete message that was not cached localy");
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
    try {
      final m = await _hub.sendMessage(message);
      debugPrint("$m");
    } catch (e) {
      debugPrint("$e");
    }
  }

  editMessage(EditMessageDto message) async {
    try {
      await _hub.editMessage(message);
    } catch (e) {
      debugPrint("$e");
    }
  }

  deleteMessage(DeleteMessageDto message) async {
    try {
      await _hub.deleteMessage(message);
    } catch (e) {
      debugPrint("$e");
    }
  }

  joinRoom(JoinRoomDto data) async {
    try {
      await _hub.joinRoom(data);
      _mutex.run(() {
        if (_rooms[data.roomId] == null) {
          _rooms[data.roomId] = List.empty(growable: true);
        }
      });
    } catch (e) {
      debugPrint("$e");
    }
  }

  leaveRoom(JoinRoomDto data) async {
    try {
      await _hub.leaveRoom(data);
    } catch (e) {
      debugPrint("$e");
    }
    _mutex.run(() {
      _rooms[data.roomId] = null;
    });
  }

  Future<List<ChatMessageDto>> getHistory(MessageHistoryRequestDto data, {bool forceRefresh = false}) async {
    if (_rooms[data.roomId] == null) {
      _rooms[data.roomId] = List.empty(growable: true);
    }
    if (_rooms[data.roomId]!.isEmpty || forceRefresh) {
      try {
        List<ChatMessageDto> messages = await _hub.getHistory(data);
        _rooms[data.roomId]!.addAll(messages);
      } catch (e) {
        debugPrint("$e");
      }
    }
    return _rooms[data.roomId] ?? List.empty();
  }

  // assumed to be called after getHistory
  List<String> getUsersInChat(int roomId) {
    if (_rooms[roomId] == null) {
      return List.empty();
    }
    return _rooms[roomId]!.map((x) => x.senderName).toSet().toList();
  }
  //#endregion
}
