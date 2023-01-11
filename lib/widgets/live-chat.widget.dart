import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/models/chat/chat-dtos.dart';
import 'package:Talkaboat/models/chat/delete-message-dto.dart';
import 'package:Talkaboat/models/chat/join-room-dto.dart';
import 'package:Talkaboat/models/chat/message-history-request-dto.dart';
import 'package:Talkaboat/services/hubs/chat/chat.service.dart';
import 'package:Talkaboat/services/user/user.service.dart';
import 'package:Talkaboat/widgets/chat-message-tile.widget.dart';
import 'package:flutter/material.dart';

class LiveChat extends StatefulWidget {
  const LiveChat({
    super.key,
    required this.roomId,
    this.visible = true,
    required this.focusNode,
    required this.cancelReplyAndEdit,
    required this.editMessage,
    required this.replyToMessage,
  });

  final int roomId;
  final bool visible;
  final FocusNode focusNode;
  final Function replyToMessage;
  final Function editMessage;
  final void Function() cancelReplyAndEdit;

  @override
  State<LiveChat> createState() => _LiveChatState();
}

class _LiveChatState extends State<LiveChat> {
  final chatService = getIt<ChatService>();
  final userService = getIt<UserService>();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  List<ChatMessageDto> _messages = List.empty(growable: true);
  int? selectedIndex;

  @override
  initState() {
    super.initState();
    Future.microtask(() async {
      if (!chatService.isConnected) {
        await chatService.connect();
      }
      await chatService.joinRoom(JoinRoomDto(widget.roomId));
      var messages = await chatService.getHistory(MessageHistoryRequestDto(roomId: widget.roomId, direction: 0));
      setState(() {
        _messages = messages;
      });
      chatService.addListener(updateMessages);
    });
  }

  @override
  dispose() {
    chatService.removeListener(updateMessages);
    Future.microtask(() => chatService.leaveRoom(JoinRoomDto(widget.roomId)));
    super.dispose();
  }

  updateMessages() async {
    int latestId = _messages[_messages.length - 1].id;
    var allMessages = await chatService.getHistory(MessageHistoryRequestDto(roomId: widget.roomId, direction: 0));
    // TODO: can this desync? probably
    var newMessages = allMessages.where((x) => x.id > latestId);

    int insertIndex = _messages.length;
    _messages.insertAll(insertIndex, newMessages);
    for (int offset = 0; offset < newMessages.length; offset++) {
      _listKey.currentState?.insertItem(insertIndex + offset);
    }

    var deletedMessages = _messages.where((x) => !allMessages.any((y) => x.id == y.id));
    for (var m in deletedMessages) {
      int index = _messages.indexOf(m);
      ChatMessageDto removedItem = _messages.removeAt(index);
      builder(context, animation) {
        return SizeTransition(
            sizeFactor: animation,
            child: ChatMessageTile(
              message: removedItem,
              onSwipedMessage: (message) {
                widget.replyToMessage(message);
                widget.focusNode.requestFocus();
              },
              onEditMessage: (message) {
                widget.editMessage(message);
                widget.focusNode.requestFocus();
              },
              onDeleteMessage: (message) => chatService.deleteMessage(DeleteMessageDto(message.id, message.chatRoomId)),
              cancelReplyAndEdit: widget.cancelReplyAndEdit,
              selectIndex: (index) => setState(() {
                selectedIndex = index;
              }),
              index: index,
              selectedIndex: selectedIndex,
              userService: userService,
              scrollToMessage: () {},
            ));
      }

      _listKey.currentState?.removeItem(index, builder);
    }

    var editedMessages = _messages.where((x) => allMessages.any((y) => x.id == y.id && x.content != y.content));
    for (var m in editedMessages) {
      int index = _messages.indexOf(m);
      _messages[index] = allMessages.where((x) => x.id == m.id).toList().first;
    }
    setState(() {
      _messages = _messages;
    });
  }

  Future<List<ChatMessageDto>> getMessages(int roomId) async {
    if (!chatService.isConnected) {
      await chatService.connect();
    }
    /*return [
      ChatMessageDto(id: 1, chatRoomId: 2, messageType: 0, content: "heyo 1", senderName: "boi", isEdited: false),
      ChatMessageDto(id: 2, chatRoomId: 2, messageType: 0, content: "heyo 2", senderName: "boi 2", isEdited: false),
      ChatMessageDto(id: 3, chatRoomId: 2, messageType: 0, content: "heyo 3", senderName: "boi 3", isEdited: false),
      ChatMessageDto(id: 4, chatRoomId: 2, messageType: 0, content: "heyo 4", senderName: "boi 4", isEdited: false),
      ChatMessageDto(id: 5, chatRoomId: 2, messageType: 0, content: "heyo 5", senderName: "boi 5", isEdited: false),
      ChatMessageDto(id: 6, chatRoomId: 2, messageType: 0, content: "heyo 6", senderName: "boi 5", isEdited: false),
      ChatMessageDto(id: 7, chatRoomId: 2, messageType: 0, content: "heyo 7", senderName: "boi 5", isEdited: false)
    ]; */
    return chatService.getHistory(MessageHistoryRequestDto(roomId: roomId, direction: 0));
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) {
      return const SizedBox();
    }
    final size = MediaQuery.of(context).size;
    return SizedBox(height: size.height / 2, width: size.width - (10 * 2), child: buildMessages(_messages));
  }

  Widget buildAnimatedMessages(List<ChatMessageDto> data) {
    final reversedData = data.reversed.toList(growable: false);
    return AnimatedList(
        key: _listKey,
        //shrinkWrap: true,
        reverse: true,
        initialItemCount: reversedData.length,
        itemBuilder: (BuildContext context, int index, animation) {
          final item = reversedData[index];
          return SizeTransition(
              sizeFactor: animation,
              child: ChatMessageTile(
                message: item,
                onSwipedMessage: (message) {
                  //widget.replyToMessage(message);
                  //widget.focusNode.requestFocus();
                },
                onEditMessage: (message) {
                  //widget.editMessage(message);
                  //widget.focusNode.requestFocus();
                },
                onDeleteMessage: (message) => chatService.deleteMessage(DeleteMessageDto(message.id, message.chatRoomId)),
                cancelReplyAndEdit: () {},
                selectIndex: (index) => setState(() {}),
                index: index,
                selectedIndex: 0,
                userService: userService,
                scrollToMessage: () {},
              ));
        });
  }

  Widget buildMessages(List<ChatMessageDto> data) {
    final reversedData = data.reversed.toList(growable: false);
    return ListView.builder(
        physics: const ScrollPhysics(),
        shrinkWrap: true,
        reverse: true,
        itemCount: reversedData.length,
        scrollDirection: Axis.vertical,
        itemBuilder: (BuildContext context, int index) {
          final item = reversedData[index];
          return ChatMessageTile(
            message: item,
            onSwipedMessage: (message) {
              widget.replyToMessage(message);
              widget.focusNode.requestFocus();
            },
            onEditMessage: (message) {
              widget.editMessage(message);
              widget.focusNode.requestFocus();
            },
            onDeleteMessage: (message) => chatService.deleteMessage(DeleteMessageDto(message.id, message.chatRoomId)),
            cancelReplyAndEdit: widget.cancelReplyAndEdit,
            selectIndex: (index) => setState(() {
              selectedIndex = index;
            }),
            index: index,
            selectedIndex: selectedIndex,
            userService: userService,
            scrollToMessage: () {},
          );
        });
  }
}
