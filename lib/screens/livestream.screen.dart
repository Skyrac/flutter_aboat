import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/models/live/live-session.model.dart';
import 'package:Talkaboat/services/live/live-session.service.dart';
import 'package:Talkaboat/widgets/live-chat.widget.dart';
import 'package:Talkaboat/widgets/livecontrolls.widget.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';

class LivestreamScreen extends StatefulWidget {
  const LivestreamScreen({Key? key, required this.session, required this.isHost}) : super(key: key);

  final LiveSession session;
  final bool isHost;

  @override
  State<LivestreamScreen> createState() => _LivestreamScreenState();
}

class _LivestreamScreenState extends State<LivestreamScreen> {
  final LiveSessionService _liveService = getIt<LiveSessionService>();

  @override
  void initState() {
    super.initState();
    //if (widget.isHost) {
    //  _liveService.joinAsHost(widget.session.guid, widget.session.configuration!.roomName);
    //} else {
    //  _liveService.joinAsViewer(widget.session.guid, widget.session.configuration!.roomName);
    //}
  }

  @override
  void dispose() {
    //_liveService.leave();
    super.dispose();
  }

  // Create UI with local view and remote view
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Container(
      color: const Color.fromRGBO(15, 23, 41, 1),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.session.configuration!.roomName),
        ),
        bottomNavigationBar: null,
        body: Stack(children: [
          /*SizedBox(
            child: AnimatedBuilder(
              animation: _liveService,
              builder: (context, child) {
                return _liveService.isHost
                    ? _liveService.isJoined
                        ? AgoraVideoView(
                            controller: VideoViewController(
                              rtcEngine: _liveService.agoraEngine,
                              canvas: const VideoCanvas(uid: 0),
                            ),
                          )
                        : const CircularProgressIndicator()
                    : _remoteVideo();
              },
            ),
          ),*/
          Positioned(
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                verticalDirection: VerticalDirection.up,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LiveControlls(roomId: widget.session.chat!.id),
                  LiveChat(
                    roomId: widget.session.chat!.id,
                  )
                ],
              ),
            ),
          )
        ]),
      ),
    ));
  }

  // Display remote user's video
  Widget _remoteVideo() {
    if (_liveService.remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _liveService.agoraEngine,
          canvas: VideoCanvas(uid: _liveService.remoteUid),
          connection: RtcConnection(channelId: widget.session.configuration!.roomName),
        ),
      );
    } else {
      return const Text(
        'Please wait for remote user to join',
        textAlign: TextAlign.center,
      );
    }
  }
}
