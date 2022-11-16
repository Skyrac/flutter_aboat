import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/models/chat/chat-dtos.dart';
import 'package:Talkaboat/models/chat/message-history-request-dto.dart';
import 'package:Talkaboat/services/hubs/chat/chat.service.dart';
import 'package:flutter/material.dart';
import 'package:swipe_to/swipe_to.dart';

import '../models/chat/delete-message-dto.dart';
import '../services/user/user.service.dart';

class Chat extends StatefulWidget {
  final int roomId;
  final ValueChanged<ChatMessageDto> onSwipedMessage;
  final ValueChanged<ChatMessageDto> onEditMessage;
  final Function? cancelReplyAndEdit;

  const Chat(
      {Key? key,
      required this.roomId,
      required this.onSwipedMessage,
      required this.onEditMessage,
      required this.cancelReplyAndEdit})
      : super(key: key);

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final chatService = getIt<ChatService>();
  final focusNode = FocusNode();
  final List<String> messageType = ["", "Podcast", "Episode"];
  var userService = getIt<UserService>();
  int? selectedIndex;

  _showPopupMenu(Offset offset, ChatMessageDto entry) async {
    double left = offset.dx;
    double top = offset.dy;
    final result = await showMenu(
      color: const Color.fromRGBO(15, 23, 41, 1),
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: Color.fromRGBO(188, 140, 75, 1)),
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      context: context,
      position: RelativeRect.fromLTRB(left, top, 0, 0),
      items: [
        PopupMenuItem<String>(child: const Text('Answer'), value: 'Answer'),
      ],
      elevation: 8.0,
    );
    switch (result) {
      case 'Answer':
        widget.onSwipedMessage(entry);
        break;
    }
  }

  _showPopupMenuOwner(Offset offset, ChatMessageDto entry) async {
    double left = offset.dx;
    double top = offset.dy;
    final result = await showMenu(
      color: const Color.fromRGBO(15, 23, 41, 1),
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: Color.fromRGBO(188, 140, 75, 1)),
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      context: context,
      position: RelativeRect.fromLTRB(left, top, 0, 0),
      items: [
        PopupMenuItem<String>(child: const Text('Answer'), value: 'Answer'),
        PopupMenuItem<String>(child: const Text('Edit'), value: 'Edit'),
        PopupMenuItem<String>(child: const Text('Delete'), value: 'Delete'),
      ],
      elevation: 8.0,
    );
    switch (result) {
      case 'Answer':
        widget.onSwipedMessage(entry);
        break;
      case 'Edit':
        widget.onEditMessage(entry);
        break;
      case 'Delete':
        chatService.deleteMessage(DeleteMessageDto(entry.id, entry.chatRoomId));
        setState(() {
          selectedIndex = null;
        });
        widget.cancelReplyAndEdit!();
        break;
    }
  }

  Widget buildMessage(context, ChatMessageDto entry, int index) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 7.5, 20, 7.5),
        child: SwipeTo(
          onLeftSwipe: () {
            widget.onSwipedMessage(entry);
            setState(() {
              selectedIndex = index;
            });
          },
          child: GestureDetector(
            onLongPressStart: (LongPressStartDetails details) {
              setState(() {
                selectedIndex = index;
              });
              if (userService.isConnected) {
                if (userService.userInfo!.userName! == entry.senderName) {
                  _showPopupMenuOwner(details.globalPosition, entry);
                } else {
                  _showPopupMenu(details.globalPosition, entry);
                }
              }
            },
            child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: selectedIndex == index ? Color.fromRGBO(99, 163, 253, 1) : Color.fromRGBO(29, 40, 58, 0.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text(
                            entry.senderName.toString(),
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          selectedIndex == index
                              ? Row(
                                  children: [
                                    IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () {
                                          setState(() {
                                            selectedIndex = null;
                                          });
                                          widget.cancelReplyAndEdit!();
                                        },
                                        icon: Icon(
                                          Icons.cancel,
                                          color: Color.fromRGBO(154, 0, 0, 1),
                                          size: 28,
                                        )),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () {
                                          chatService.deleteMessage(DeleteMessageDto(entry.id, entry.chatRoomId));
                                          setState(() {
                                            selectedIndex = null;
                                          });
                                          widget.cancelReplyAndEdit!();
                                        },
                                        icon: Icon(
                                          Icons.delete,
                                          color: Color.fromRGBO(154, 0, 0, 1),
                                          size: 28,
                                        )),
                                  ],
                                )
                              : Text(messageType[entry.messageType],
                                  style: const TextStyle(color: Color.fromRGBO(99, 163, 253, 1))),
                        ]),
                      ),
                      entry.answeredMessage != null
                          ? Container(
                              padding: EdgeInsets.all(5),
                              margin: EdgeInsets.only(bottom: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Color.fromRGBO(48, 73, 123, 1),
                              ),
                              width: 300,
                              //child: Expanded(
                              child: Center(
                                  child: Text(
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                entry.answeredMessage!.content,
                              )),
                            )
                          : Container(),
                      Padding(
                        padding: const EdgeInsets.only(right: 25),
                        child: Align(alignment: Alignment.centerLeft, child: Text(entry.content.toString())),
                      ),
                    ],
                  ),
                )),
          ),
        ),
      );

  Widget buildMessages(List<ChatMessageDto> data) => ListView.builder(
      physics: const ScrollPhysics(),
      shrinkWrap: true,
      itemCount: data.length,
      scrollDirection: Axis.vertical,
      itemBuilder: (BuildContext context, int index) {
        final item = data[index];
        return buildMessage(context, item, index);
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
                  final data = snapshot.data as List<ChatMessageDto>?;
                  if (data != null && data.isNotEmpty) {
                    // return Text(data[1].content.toString());
                    return Container(
                      alignment: Alignment.topCenter,
                      // height: 400,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          buildMessages(data),
                        ],
                      ),
                    );
                  } else {
                    return SizedBox(
                      height: 300,
                      child: Stack(alignment: Alignment.bottomCenter, children: [
                        Positioned(
                          top: 0,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: const Text(
                              'No data found for this podcast. Please try again later!',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ]),
                    );
                  }
                }
              }

              return const Center(
                child: CircularProgressIndicator(),
              );
            },
            future: getMessages(widget.roomId));
      },
    );
  }
}
