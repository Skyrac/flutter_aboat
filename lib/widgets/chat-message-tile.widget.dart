import 'package:Talkaboat/models/chat/chat-dtos.dart';
import 'package:Talkaboat/services/hubs/chat/chat.service.dart';
import 'package:Talkaboat/services/user/user.service.dart';
import 'package:flutter/material.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChatMessageTile extends StatelessWidget {
  const ChatMessageTile({
    super.key,
    required this.message,
    required this.onSwipedMessage,
    required this.onEditMessage,
    required this.onDeleteMessage,
    required this.cancelReplyAndEdit,
    required this.selectMessage,
    required this.index,
    required this.selectedMessage,
    required this.userService,
    required this.scrollToMessage,
  });

  final ChatMessageDto message;
  final UserService userService;
  final void Function(ChatMessageDto) onSwipedMessage;
  final void Function(ChatMessageDto) onEditMessage;
  final void Function(ChatMessageDto) onDeleteMessage;
  final void Function() cancelReplyAndEdit;
  final void Function(int?) selectMessage;
  final void Function() scrollToMessage;
  final int index;
  final int? selectedMessage;

  _showPopupMenu(BuildContext context, Offset offset, ChatMessageDto entry) async {
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
        PopupMenuItem<String>(value: 'Answer', child: Text(AppLocalizations.of(context)!.answer)),
      ],
      elevation: 8.0,
    );
    switch (result) {
      case 'Answer':
        onSwipedMessage(entry);
        break;
    }
  }

  _showPopupMenuOwner(BuildContext context, Offset offset, ChatMessageDto entry) async {
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
        PopupMenuItem<String>(value: 'Answer', child: Text(AppLocalizations.of(context)!.answer)),
        PopupMenuItem<String>(value: 'Edit', child: Text(AppLocalizations.of(context)!.edit)),
        PopupMenuItem<String>(value: 'Delete', child: Text(AppLocalizations.of(context)!.delete)),
      ],
      elevation: 8.0,
    );
    switch (result) {
      case 'Answer':
        onSwipedMessage(entry);
        break;
      case 'Edit':
        onEditMessage(entry);
        break;
      case 'Delete':
        onDeleteMessage(message);
        selectMessage(null);
        cancelReplyAndEdit();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 7.5, 20, 7.5),
      child: SwipeTo(
        onLeftSwipe: () {
          onSwipedMessage(message);
          selectMessage(message.id);
        },
        child: GestureDetector(
          onLongPressStart: (LongPressStartDetails details) {
            selectMessage(message.id);
            if (userService.isConnected) {
              if (userService.userInfo!.userName! == message.senderName) {
                _showPopupMenuOwner(context, details.globalPosition, message);
              } else {
                _showPopupMenu(context, details.globalPosition, message);
              }
            }
          },
          child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: selectedMessage == message.id
                    ? const Color.fromRGBO(99, 163, 253, 1)
                    : const Color.fromRGBO(29, 40, 58, 0.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    message.answeredMessage != null
                        ? RawMaterialButton(
                            onPressed: () {
                              scrollToMessage();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              margin: const EdgeInsets.only(bottom: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: const Color.fromRGBO(48, 73, 123, 1),
                              ),
                              child: Row(children: [
                                Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 5),
                                    child: Text(
                                      message.answeredMessage!.senderName.toString(),
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                                    )),
                                Center(
                                    child: Text(
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  message.answeredMessage!.content,
                                ))
                              ]),
                            ),
                          )
                        : const SizedBox(),
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text(
                          message.senderName.toString(),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        selectedMessage == message.id
                            ? Row(
                                children: [
                                  IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed: () {
                                        selectMessage(null);
                                        cancelReplyAndEdit();
                                      },
                                      icon: const Icon(
                                        Icons.cancel,
                                        color: Color.fromRGBO(154, 0, 0, 1),
                                        size: 28,
                                      )),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  userService.userInfo!.userName! == message.senderName
                                      ? IconButton(
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          onPressed: () {
                                            onDeleteMessage(message);
                                            selectMessage(null);
                                            cancelReplyAndEdit();
                                          },
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Color.fromRGBO(154, 0, 0, 1),
                                            size: 28,
                                          ))
                                      : const SizedBox(),
                                ],
                              )
                            : Text(
                                "${ChatService.messageType[message.messageType]}${message.messageType == 2 ? " ${message.messageType}" : ""}",
                                style: const TextStyle(color: Color.fromRGBO(99, 163, 253, 1))),
                      ]),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 25),
                      child: Align(alignment: Alignment.centerLeft, child: Text(message.content.toString())),
                    ),
                  ],
                ),
              )),
        ),
      ),
    );
  }
}
