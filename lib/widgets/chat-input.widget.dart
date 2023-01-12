import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/models/chat/chat-dtos.dart';
import 'package:Talkaboat/models/chat/create-message-dto.dart';
import 'package:Talkaboat/models/chat/edit-message-dto.dart';
import 'package:Talkaboat/services/hubs/chat/chat.service.dart';
import 'package:Talkaboat/services/user/user.service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChatInput extends StatefulWidget {
  const ChatInput(
      {Key? key,
      required this.roomId,
      this.focusNode,
      this.replyMessage,
      this.editedMessage,
      required this.messageType,
      this.cancelReplyAndEdit,
      this.width,
      this.positionSelf = true})
      : super(key: key);

  final FocusNode? focusNode;
  final ChatMessageDto? replyMessage;
  final ChatMessageDto? editedMessage;
  final int messageType;
  final int roomId;
  final Function? cancelReplyAndEdit;
  final double? width;
  final bool positionSelf;

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final userService = getIt<UserService>();
  final chatService = getIt<ChatService>();
  String? messageRaw;

  @override
  Widget build(BuildContext contsext) {
    return userService.isConnected
        ? widget.positionSelf
            ? Positioned(bottom: 10, child: buildContainer(context))
            : buildContainer(context)
        : const SizedBox();
  }

  Widget buildContainer(BuildContext context) {
    final isReplying = widget.replyMessage != null;
    final isEdit = widget.editedMessage != null;
    final textEditController = TextController(text: widget.editedMessage != null ? widget.editedMessage!.content : "");

    return Container(
      width: widget.width ?? 350,
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
          focusNode: widget.focusNode,
          controller: textEditController,
          onSubmitted: (content) {
            messageRaw = content;
            if (isReplying) {
              chatService.sendMessage(
                  CreateMessageDto(0, widget.roomId, content, widget.messageType, 2, widget.replyMessage!.id),
                  userService.userInfo!.userName!);
              textEditController.clear();
            } else if (isEdit) {
              chatService.editMessage(
                EditMessageDto(widget.editedMessage!.id, widget.editedMessage!.chatRoomId, content),
              );
              textEditController.clear();
            } else {
              chatService.sendMessage(CreateMessageDto(0, widget.roomId, content, widget.messageType, null, null),
                  userService.userInfo!.userName!);
              textEditController.clear();
            }
            if (widget.cancelReplyAndEdit != null) {
              widget.cancelReplyAndEdit!();
            }
          },
          onChanged: (text) {
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
            hintText: AppLocalizations.of(context)!.message,
            prefixText: isReplying
                ? "${AppLocalizations.of(context)!.answer}: "
                : isEdit
                    ? "${AppLocalizations.of(context)!.edit}: "
                    : "",
            prefixStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color.fromRGBO(99, 163, 253, 1),
                ),
            suffixIcon: IconButton(
              onPressed: () async {
                if (isReplying) {
                  chatService.sendMessage(
                      CreateMessageDto(0, widget.roomId, messageRaw!, widget.messageType, 2, widget.replyMessage!.id),
                      userService.userInfo!.userName!);
                  textEditController.clear();
                } else if (isEdit) {
                  chatService.editMessage(
                    EditMessageDto(widget.editedMessage!.id, widget.editedMessage!.chatRoomId, messageRaw!),
                  );
                  textEditController.clear();
                } else {
                  chatService.sendMessage(CreateMessageDto(0, widget.roomId, messageRaw!, widget.messageType, null, null),
                      userService.userInfo!.userName!);
                  textEditController.clear();
                }
                if (widget.cancelReplyAndEdit != null) {
                  widget.cancelReplyAndEdit!();
                }
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
