import 'package:Talkaboat/models/chat/chat-dtos.dart';
import 'package:Talkaboat/widgets/chat-input.widget.dart';
import 'package:Talkaboat/widgets/live-users.bottom-sheet.dart';
import 'package:flutter/material.dart';

class LiveControlls extends StatelessWidget {
  const LiveControlls(
      {super.key,
      required this.chatId,
      required this.focusNode,
      this.replyMessage,
      this.editedMessage,
      required this.cancelReplyAndEdit,
      required this.toggleChat,
      required this.chatVisible,
      required this.isHost,
      required this.videoOn,
      required this.localAudio,
      required this.audioMuted,
      required this.switchCamera,
      required this.switchVideo,
      required this.switchLocalAudio,
      required this.switchAudio});

  final int chatId;
  final FocusNode focusNode;
  final ChatMessageDto? replyMessage;
  final ChatMessageDto? editedMessage;
  final void Function() cancelReplyAndEdit;
  final bool chatVisible;
  final bool isHost;
  final bool videoOn;
  final bool localAudio;
  final bool audioMuted;
  final void Function() toggleChat;
  final void Function() switchCamera;
  final void Function() switchVideo;
  final void Function() switchLocalAudio;
  final void Function() switchAudio;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    debugPrint("size: ${size.width} ${size.width - (5 * 2) - (10 * 2) - 100}");
    return Column(
      children: [
        SizedBox(
          width: size.width,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                SizedBox(
                    height: 50,
                    width: 50,
                    child: MaterialButton(
                      onPressed: () {
                        toggleChat();
                      },
                      color: const Color.fromRGBO(29, 40, 58, 0.97),
                      child: chatVisible
                          ? Image.asset("assets/icons/icon-chat-on.png")
                          : Image.asset("assets/icons/icon-chat-off.png"),
                    )),
                chatVisible
                    ? ChatInput(
                        roomId: chatId,
                        messageType: 0,
                        width: size.width - (5 * 2) - (10 * 2) - 100,
                        positionSelf: false,
                        focusNode: focusNode,
                        cancelReplyAndEdit: cancelReplyAndEdit,
                        replyMessage: replyMessage,
                        editedMessage: editedMessage,
                      )
                    : const SizedBox(),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        SizedBox(
          width: size.width,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: isHost
                  ? [
                      _changeCameraButton(),
                      _changeVideoButton(),
                      _callEndButton(context),
                      _changeAudioStreamButton(),
                      _peopleButton(context),
                    ]
                  : [
                      _changeAudioMuteButton(),
                      _callEndButton(context),
                      _peopleButton(context),
                    ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _changeCameraButton() => SizedBox(
      height: 50,
      width: 50,
      child: MaterialButton(
          shape: const CircleBorder(),
          onPressed: () {
            switchCamera();
          },
          color: const Color.fromRGBO(48, 73, 123, 0.6),
          child: Image.asset("assets/icons/icon-camera-switch.png")));

  Widget _changeVideoButton() => SizedBox(
      height: 50,
      width: 50,
      child: MaterialButton(
        shape: const CircleBorder(),
        onPressed: () {
          switchVideo();
        },
        color: const Color.fromRGBO(48, 73, 123, 0.6),
        child: videoOn ? Image.asset("assets/icons/icon-video-on.png") : Image.asset("assets/icons/icon-video-off.png"),
      ));

  Widget _changeAudioStreamButton() => SizedBox(
      height: 50,
      width: 50,
      child: MaterialButton(
        shape: const CircleBorder(),
        onPressed: () {
          switchLocalAudio();
        },
        color: const Color.fromRGBO(48, 73, 123, 0.6),
        child: localAudio ? Image.asset("assets/icons/icon-audio-on.png") : Image.asset("assets/icons/icon-audio-off.png"),
      ));

  Widget _peopleButton(context) => SizedBox(
      height: 50,
      width: 50,
      child: MaterialButton(
          shape: const CircleBorder(),
          onPressed: () {
            showModalBottomSheet(
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
              context: context,
              builder: (context) => Container(
                color: const Color.fromRGBO(15, 23, 41, 1),
                child: const FractionallySizedBox(
                  heightFactor: 0.9,
                  child: LiveUsersBottomSheet(),
                ),
              ),
            );
          },
          color: const Color.fromRGBO(48, 73, 123, 0.6),
          child: Image.asset("assets/icons/icon-people.png")));

  Widget _callEndButton(context) => SizedBox(
      height: 60,
      width: 60,
      child: MaterialButton(
          shape: const CircleBorder(),
          onPressed: () {
            Navigator.of(context).pop();
          },
          color: const Color.fromRGBO(232, 63, 63, 0.6),
          child: Image.asset("assets/icons/icon-call-end.png")));

  Widget _changeAudioMuteButton() => SizedBox(
      height: 50,
      width: 50,
      child: MaterialButton(
        shape: const CircleBorder(),
        onPressed: () {
          switchAudio();
        },
        color: const Color.fromRGBO(48, 73, 123, 0.6),
        child: audioMuted ? Image.asset("assets/icons/icon-mute-on.png") : Image.asset("assets/icons/icon-mute-off.png"),
      ));
}
