import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/models/chat/chat-dtos.dart';
import 'package:Talkaboat/models/chat/create-message-dto.dart';
import 'package:Talkaboat/models/chat/edit-message-dto.dart';
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

  const Chat({Key? key, required this.roomId, required this.messageType, this.header}) : super(key: key);

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final chatService = getIt<ChatService>();
  final focusNode = FocusNode();
  var userService = getIt<UserService>();
  int? selectedIndex;
  Future<List<ChatMessageDto>>? _getMessages;
  ChatMessageDto? replyMessage;
  ChatMessageDto? editedMessage;
  String? messageRaw;

  void replyToMessage(ChatMessageDto message) {
    setState(() {
      editedMessage = null;
      replyMessage = message;
    });
  }

  void editMessage(ChatMessageDto message) {
    setState(() {
      replyMessage = null;
      editedMessage = message;
    });
  }

  void cancelReplyAndEdit() {
    setState(() {
      replyMessage = null;
      editedMessage = null;
    });
  }

  @override
  initState() {
    super.initState();
    chatService.joinRoom(JoinRoomDto(widget.roomId));
    _getMessages = getMessages(widget.roomId);
  }

  @override
  dispose() {
    chatService.leaveRoom(JoinRoomDto(widget.roomId));
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
              replyToMessage(message);
              focusNode.requestFocus();
            },
            onEditMessage: (message) {
              editMessage(message);
              focusNode.requestFocus();
            },
            onDeleteMessage: (message) => chatService.deleteMessage(DeleteMessageDto(message.id, message.chatRoomId)),
            cancelReplyAndEdit: cancelReplyAndEdit,
            selectIndex: (index) => setState(() {
                  selectedIndex = index;
                }),
            index: index,
            selectedIndex: selectedIndex,
            userService: userService);
      });

  Future<List<ChatMessageDto>> getMessages(int roomId) async {
    if (!chatService.isConnected) {
      await chatService.connect();
    }
    return await chatService.getHistory(MessageHistoryRequestDto(roomId: roomId, direction: 0));
  }

  @override
  Widget build(BuildContext context) {
    final isReplying = replyMessage != null;
    final isEdit = editedMessage != null;
    final textEditController = TextController(text: editedMessage != null ? editedMessage!.content : "");

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        CustomScrollView(
          slivers: [
            widget.header ?? const SliverToBoxAdapter(child: SizedBox()),
            SliverToBoxAdapter(
                child: AnimatedBuilder(
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
                          if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                            // return Text(data[1].content.toString());
                            return Container(
                              alignment: Alignment.topCenter,
                              // height: 400,
                              child: Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  buildMessages(snapshot.data!),
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
                    future: _getMessages);
              },
            ))
          ],
        ),
        userService.isConnected
            ? Positioned(
                bottom: 50,
                child: Container(
                  width: 350,
                  height: 50,
                  padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color.fromRGBO(15, 23, 41, 1),
                    border: Border.all(
                        color: const Color.fromRGBO(99, 163, 253, 1), // set border color
                        width: 1.0),
                  ),
                  child: Builder(builder: (context) {
                    return TextField(
                      focusNode: focusNode,
                      controller: textEditController,
                      onSubmitted: (content) {
                        messageRaw = content;
                        if (isReplying) {
                          chatService.sendMessage(
                              CreateMessageDto(0, widget.roomId, content, widget.messageType, 2, replyMessage!.id),
                              userService.userInfo!.userName!);
                          textEditController.clear();
                        } else if (isEdit) {
                          chatService.editMessage(
                            EditMessageDto(editedMessage!.id, editedMessage!.chatRoomId, content),
                          );
                          textEditController.clear();
                        } else {
                          chatService.sendMessage(
                              CreateMessageDto(0, widget.roomId, content, widget.messageType, null, null),
                              userService.userInfo!.userName!);
                          textEditController.clear();
                        }
                        cancelReplyAndEdit();
                      },
                      onChanged: (text) {
                        print(text);
                        messageRaw = text;
                      },
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color.fromRGBO(164, 202, 255, 1),
                          ),
                      keyboardType: TextInputType.text,
                      maxLines: null,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        alignLabelWithHint: true,
                        hintText: "Message",
                        prefixText: isReplying
                            ? "Answer: "
                            : isEdit
                                ? "Edit: "
                                : "",
                        prefixStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color.fromRGBO(99, 163, 253, 1),
                            ),
                        suffixIcon: IconButton(
                          onPressed: () async {
                            if (isReplying) {
                              chatService.sendMessage(
                                  CreateMessageDto(0, widget.roomId, messageRaw!, widget.messageType, 2, replyMessage!.id),
                                  userService.userInfo!.userName!);
                              textEditController.clear();
                            } else if (isEdit) {
                              chatService.editMessage(
                                EditMessageDto(editedMessage!.id, editedMessage!.chatRoomId, messageRaw!),
                              );
                              textEditController.clear();
                            } else {
                              chatService.sendMessage(
                                  CreateMessageDto(0, widget.roomId, messageRaw!, widget.messageType, null, null),
                                  userService.userInfo!.userName!);
                              textEditController.clear();
                            }
                            cancelReplyAndEdit();
                          },
                          icon: const Icon(Icons.send, color: Color.fromRGBO(99, 163, 253, 1)),
                        ),
                        hintStyle: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: const Color.fromRGBO(135, 135, 135, 1), fontStyle: FontStyle.italic),
                      ),
                    );
                  }),
                ))
            : const SizedBox()
      ],
    );
  }
}

class TextController extends TextEditingController {
  TextController({String? text}) {
    this.text = text!;
  }

  @override
  set text(String newText) {
    value = value.copyWith(
        text: newText, selection: TextSelection.collapsed(offset: newText.length), composing: TextRange.empty);
  }
}
