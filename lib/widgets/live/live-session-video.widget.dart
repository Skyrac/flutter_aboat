import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/services/live/live-session.service.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/cupertino.dart';

class LiveSessionVideoPanel extends StatefulWidget {
  const LiveSessionVideoPanel({Key? key}) : super(key: key);

  @override
  State<LiveSessionVideoPanel> createState() => _LiveSessionVideoPanelState();
}

class _LiveSessionVideoPanelState extends State<LiveSessionVideoPanel> {
  final liveSession = getIt<LiveSessionService>();
  @override
  Widget build(BuildContext context) {
    if (!liveSession.isJoined) {
      return const Text(
        'Join a channel',
        textAlign: TextAlign.center,
      );
    } else if (liveSession.isHost) {
      // Local user joined as a host
      return SizedBox();
      /*return AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: liveSession.agoraEngine,
          canvas: VideoCanvas(uid: liveSession.uid),
        ),
      );*/
    } else {
      // Local user joined as audience
      if (liveSession.remoteUid != null) {
        return AgoraVideoView(
          controller: VideoViewController.remote(
            rtcEngine: liveSession.agoraEngine,
            canvas: VideoCanvas(uid: liveSession.remoteUid),
            connection: RtcConnection(channelId: liveSession.roomGuid),
          ),
        );
      } else {
        return const Text(
          'Waiting for a host to join',
          textAlign: TextAlign.center,
        );
      }
    }
  }
}
