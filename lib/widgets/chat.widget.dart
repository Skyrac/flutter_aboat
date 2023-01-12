import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/models/chat/chat-dtos.dart';
import 'package:Talkaboat/models/chat/join-room-dto.dart';
import 'package:Talkaboat/services/hubs/chat/chat.service.dart';
import 'package:Talkaboat/widgets/chat-message-tile.widget.dart';
import 'package:flutter/material.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

import '../models/chat/delete-message-dto.dart';
import '../services/user/user.service.dart';

class Chat extends StatefulWidget {
  final int roomId;
  final int messageType;
  final SliverPersistentHeader? header;
  final FocusNode focusNode;
  final Function replyToMessage;
  final Function editMessage;
  final ScrollController controller;
  final void Function() cancelReplyAndEdit;
  final bool reverse;
  final bool padBottom;
  final bool neverScroll;

  const Chat(
      {super.key,
      required this.roomId,
      required this.messageType,
      required this.focusNode,
      required this.cancelReplyAndEdit,
      required this.editMessage,
      required this.replyToMessage,
      this.header,
      required this.controller,
      this.reverse = false,
      this.padBottom = true,
      this.neverScroll = true});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final chatService = getIt<ChatService>();
  final userService = getIt<UserService>();
  int? selectedMessage;

  bool loading = true;

  @override
  initState() {
    super.initState();
    Future.microtask(() {
      chatService.joinRoom(JoinRoomDto(widget.roomId));
      setState(() {
        loading = false;
      });
    });
  }

  @override
  dispose() {
    Future.microtask(() => chatService.leaveRoom(JoinRoomDto(widget.roomId)));
    super.dispose();
  }

  late ListObserverController observerController = ListObserverController(controller: widget.controller);

  Widget buildMessages(List<ChatMessageDto> data) => ListViewObserver(
        controller: observerController,
        child: ListView.builder(
            controller: widget.controller,
            physics: widget.neverScroll ? const NeverScrollableScrollPhysics() : const ScrollPhysics(),
            shrinkWrap: true,
            itemCount: data.length + (widget.padBottom ? 1 : 0),
            reverse: widget.reverse,
            scrollDirection: Axis.vertical,
            itemBuilder: (BuildContext context, int index) {
              if (index == data.length) {
                return const SizedBox(
                  height: 60,
                );
              }
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
                  selectMessage: (id) => setState(() {
                        selectedMessage = id;
                      }),
                  index: index,
                  selectedMessage: selectedMessage,
                  userService: userService,
                  scrollToMessage: () {
                    index = 0;
                    for (var element in data) {
                      var idMessage = element.id;
                      var idMessageAnswer = item.answeredMessage?.id;
                      if (idMessageAnswer == idMessage) {
                        debugPrint("scroll $index");
                        observerController.animateTo(
                          index: index,
                          duration: const Duration(seconds: 1),
                          curve: Curves.ease,
                        );
                        break;
                      }
                      index++;
                    }
                  });
            }),
      );

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return AnimatedBuilder(
        animation: chatService,
        builder: (BuildContext context, Widget? child) {
          final rawData = chatService.messages(widget.roomId);
          final data = widget.reverse ? rawData.reversed.toList(growable: false) : rawData;
          debugPrint("rebuild chat");
          return Container(
            alignment: Alignment.topCenter,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                buildMessages(data),
              ],
            ),
          );
        });
  }
}
