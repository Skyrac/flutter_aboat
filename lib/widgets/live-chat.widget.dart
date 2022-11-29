import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/models/chat/chat-dtos.dart';
import 'package:Talkaboat/models/chat/delete-message-dto.dart';
import 'package:Talkaboat/models/chat/join-room-dto.dart';
import 'package:Talkaboat/services/hubs/chat/chat.service.dart';
import 'package:Talkaboat/services/user/user.service.dart';
import 'package:Talkaboat/widgets/chat-message-tile.widget.dart';
import 'package:flutter/material.dart';

class LiveChat extends StatefulWidget {
  const LiveChat({super.key, required this.roomId});

  final int roomId;

  @override
  State<LiveChat> createState() => _LiveChatState();
}

class _LiveChatState extends State<LiveChat> {
  final chatService = getIt<ChatService>();
  final userService = getIt<UserService>();
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

  Future<List<ChatMessageDto>> getMessages(int roomId) async {
    if (!chatService.isConnected) {
      await chatService.connect();
    }
    return [
      ChatMessageDto(id: 1, chatRoomId: 2, messageType: 0, content: "heyo 1", senderName: "boi", isEdited: false),
      ChatMessageDto(id: 2, chatRoomId: 2, messageType: 0, content: "heyo 2", senderName: "boi 2", isEdited: false),
      ChatMessageDto(id: 3, chatRoomId: 2, messageType: 0, content: "heyo 3", senderName: "boi 3", isEdited: false),
      ChatMessageDto(id: 4, chatRoomId: 2, messageType: 0, content: "heyo 4", senderName: "boi 4", isEdited: false),
      ChatMessageDto(id: 5, chatRoomId: 2, messageType: 0, content: "heyo 5", senderName: "boi 5", isEdited: false),
      ChatMessageDto(id: 6, chatRoomId: 2, messageType: 0, content: "heyo 6", senderName: "boi 5", isEdited: false),
      ChatMessageDto(id: 7, chatRoomId: 2, messageType: 0, content: "heyo 7", senderName: "boi 5", isEdited: false)
    ]; //await chatService.getHistory(MessageHistoryRequestDto(roomId: roomId, direction: 0));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: chatService,
      builder: (BuildContext context, Widget? child) {
        final size = MediaQuery.of(context).size;
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
                  return SizedBox(
                      height: size.height / 2, width: size.width - (10 * 2), child: buildMessages(snapshot.data!));
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
              userService: userService);
        });
  }
}
