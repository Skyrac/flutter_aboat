import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/models/live/live-session.model.dart';
import 'package:Talkaboat/services/live/live-session.service.dart';
import 'package:Talkaboat/widgets/chat-input.widget.dart';
import 'package:Talkaboat/widgets/live-users.bottom-sheet.dart';
import 'package:flutter/material.dart';

class LiveControlls extends StatefulWidget {
  const LiveControlls({super.key, required this.liveSession});

  final LiveSession liveSession;

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
                          liveSessionService.switchChat();
                        },
                        color: const Color.fromRGBO(29, 40, 58, 0.97),
                        child: liveSessionService.chatVisible
                            ? Image.asset("assets/icons/icon-chat-on.png")
                            : Image.asset("assets/icons/icon-chat-off.png"),
                      )),
                  liveSessionService.chatVisible
                      ? ChatInput(
                          roomId: widget.liveSession.chat!.id,
                          messageType: 0,
                          width: size.width - (5 * 2) - (10 * 2) - 100,
                          positionSelf: false,
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
                children: liveSessionService.isHost
                    ? [
                        _changeCameraButton(),
                        _changeVideoButton(),
                        _callEndButton(),
                        _changeAudioStreamButton(),
                        _peopleButton(),
                      ]
                    : [
                        _changeAudioMuteButton(),
                        _callEndButton(),
                        _peopleButton(),
                      ],
              ),
            ),
          ),
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
            showModalBottomSheet(
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
              context: context,
              builder: (context) => Container(
                color: const Color.fromRGBO(15, 23, 41, 1),
                child: FractionallySizedBox(
                  heightFactor: 0.9,
                  child: LiveUsersBottomSheet(
                    liveSession: widget.liveSession,
                    myUid: 1,
                  ),
                ),
              ),
            );
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
