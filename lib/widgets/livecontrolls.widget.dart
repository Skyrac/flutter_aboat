import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/services/live/live-session.service.dart';
import 'package:Talkaboat/widgets/chat-input.widget.dart';
import 'package:flutter/material.dart';

class LiveControlls extends StatefulWidget {
  const LiveControlls({super.key, required this.roomId});

  final int roomId;

  @override
  State<LiveControlls> createState() => _LiveControllsState();
}

class _LiveControllsState extends State<LiveControlls> {
  final liveSessionService = getIt<LiveSessionService>();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    debugPrint("size: ${size.width} ${size.width - (5 * 2) - (10 * 2) - 100}");
    return AnimatedBuilder(
      animation: liveSessionService,
      builder: (context, child) => Column(
        children: [
          Row(
            children: [
              SizedBox(
                  height: 50,
                  width: 50,
                  child: MaterialButton(
                    onPressed: () {
                      liveSessionService.switchChat();
                    },
                    color: const Color.fromRGBO(29, 40, 58, 0.97),
                    child: liveSessionService.chatVisible
                        ? Image.asset("assets/icons/icon-chat-on.png")
                        : Image.asset("assets/icons/icon-chat-off.png"),
                  )),
              liveSessionService.chatVisible
                  ? ChatInput(
                      roomId: widget.roomId,
                      messageType: 0,
                      width: size.width - (5 * 2) - (10 * 2) - 100,
                      positionSelf: false,
                    )
                  : const SizedBox()
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            width: size.width,
            child: Row(
              children: liveSessionService.isHost
                  ? [
                      const Spacer(),
                      _changeCameraButton(),
                      const SizedBox(
                        width: 20,
                      ),
                      _changeVideoButton(),
                      const SizedBox(
                        width: 20,
                      ),
                      _callEndButton(),
                      const SizedBox(
                        width: 20,
                      ),
                      _changeAudioStreamButton(),
                      const SizedBox(
                        width: 20,
                      ),
                      _peopleButton(),
                      const Spacer(),
                    ]
                  : [
                      const Spacer(),
                      _changeAudioMuteButton(),
                      const SizedBox(
                        width: 20,
                      ),
                      _callEndButton(),
                      const SizedBox(
                        width: 20,
                      ),
                      _peopleButton(),
                      const Spacer(),
                    ],
            ),
          )
        ],
      ),
    );
  }

  Widget _changeCameraButton() => SizedBox(
      height: 50,
      width: 50,
      child: MaterialButton(
          shape: const CircleBorder(),
          onPressed: () {
            liveSessionService.switchCamera();
          },
          color: const Color.fromRGBO(48, 73, 123, 0.6),
          child: Image.asset("assets/icons/icon-camera-switch.png")));

  Widget _changeVideoButton() => SizedBox(
      height: 50,
      width: 50,
      child: MaterialButton(
          shape: const CircleBorder(),
          onPressed: () {
            liveSessionService.switchVideo();
          },
          color: const Color.fromRGBO(48, 73, 123, 0.6),
          child: AnimatedBuilder(
            animation: liveSessionService,
            builder: (context, child) => liveSessionService.videoOn
                ? Image.asset("assets/icons/icon-video-on.png")
                : Image.asset("assets/icons/icon-video-off.png"),
          )));

  Widget _changeAudioStreamButton() => SizedBox(
      height: 50,
      width: 50,
      child: MaterialButton(
          shape: const CircleBorder(),
          onPressed: () {
            liveSessionService.switchLocalAudio();
          },
          color: const Color.fromRGBO(48, 73, 123, 0.6),
          child: AnimatedBuilder(
            animation: liveSessionService,
            builder: (context, child) => liveSessionService.localAudio
                ? Image.asset("assets/icons/icon-audio-on.png")
                : Image.asset("assets/icons/icon-audio-off.png"),
          )));

  Widget _peopleButton() => SizedBox(
      height: 50,
      width: 50,
      child: MaterialButton(
          shape: const CircleBorder(),
          onPressed: () {
            liveSessionService.switchLocalAudio();
          },
          color: const Color.fromRGBO(48, 73, 123, 0.6),
          child: Image.asset("assets/icons/icon-people.png")));

  Widget _callEndButton() => SizedBox(
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
            liveSessionService.switchAudio();
          },
          color: const Color.fromRGBO(48, 73, 123, 0.6),
          child: AnimatedBuilder(
            animation: liveSessionService,
            builder: (context, child) => liveSessionService.audioMuted
                ? Image.asset("assets/icons/icon-mute-on.png")
                : Image.asset("assets/icons/icon-mute-off.png"),
          )));
}
