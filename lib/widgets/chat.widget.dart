import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/models/chat/chat-dtos.dart';
import 'package:Talkaboat/models/chat/join-room-dto.dart';
import 'package:Talkaboat/models/chat/message-history-request-dto.dart';
import 'package:Talkaboat/services/hubs/chat/chat.service.dart';
import 'package:Talkaboat/widgets/chat-message-tile.widget.dart';
import 'package:flutter/material.dart';

import '../models/chat/delete-message-dto.dart';
import '../services/user/user.service.dart';

class Chat extends StatefulWidget {
  final int roomId;
  final int messageType;
  final SliverPersistentHeader? header;
  final FocusNode focusNode;
  final Function replyToMessage;
  final Function editMessage;
  final void Function() cancelReplyAndEdit;

  const Chat(
      {Key? key,
      required this.roomId,
      required this.messageType,
      required this.focusNode,
      required this.cancelReplyAndEdit,
      required this.editMessage,
      required this.replyToMessage,
      this.header})
      : super(key: key);

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final chatService = getIt<ChatService>();
  final userService = getIt<UserService>();
  int? selectedIndex;
  Future<List<ChatMessageDto>>? _getMessages;

  @override
  initState() {
    super.initState();
    Future.microtask(() => chatService.joinRoom(JoinRoomDto(widget.roomId)));
    _getMessages = getMessages(widget.roomId);
  }

  @override
  dispose() {
    Future.microtask(() => chatService.leaveRoom(JoinRoomDto(widget.roomId)));
    super.dispose();
  }

  Widget buildMessages(List<ChatMessageDto> data) => ListView.builder(
      physics: const ScrollPhysics(),
      shrinkWrap: true,
      itemCount: data.length,
      scrollDirection: Axis.vertical,
      itemBuilder: (BuildContext context, int index) {
        var item = data[index];
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
          scrollToItem: () {},
        );
      });

  Future<List<ChatMessageDto>> getMessages(int roomId) async {
    if (!chatService.isConnected) {
      await chatService.connect();
    }
    return await chatService.getHistory(MessageHistoryRequestDto(roomId: roomId, direction: 0));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: chatService,
      builder: (BuildContext context, Widget? child) {
        return FutureBuilder(
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      '${snapshot.error} occurred',
                      style: const TextStyle(fontSize: 18),
                    ),
                  );
                } else if (snapshot.hasData && snapshot.data != null) {
                  // Extracting data from snapshot object
                  return buildMessages(snapshot.data!);
                }
              }

              return const Center(
                child: CircularProgressIndicator(),
              );
            },
            future: _getMessages);
      },
    );
  }
}
