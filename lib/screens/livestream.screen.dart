import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/services/live/live-session.service.dart';
import 'package:Talkaboat/utils/scaffold_wave.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';

class LivestreamScreen extends StatefulWidget {
  const LivestreamScreen({Key? key, required this.roomId, required this.isHost}) : super(key: key);

  final String roomId;
  final bool isHost;

  @override
  State<LivestreamScreen> createState() => _LivestreamScreenState();
}

class _LivestreamScreenState extends State<LivestreamScreen> {
  final LiveSessionService _liveService = getIt<LiveSessionService>();

  int? _remoteUid;

  @override
  void initState() {
    super.initState();
    if (widget.isHost) {
      _liveService.joinAsHost(widget.roomId);
    }
  }

  // Create UI with local view and remote view
  @override
  Widget build(BuildContext context) {
    return ScaffoldWave(
      appBar: AppBar(
        title: const Text('Agora Video Call'),
      ),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 100,
              height: 150,
              child: Center(
                child: _liveService.isJoined
                    ? AgoraVideoView(
                        controller: VideoViewController(
                          rtcEngine: _liveService.agoraEngine,
                          canvas: const VideoCanvas(uid: 0),
                        ),
                      )
                    : const CircularProgressIndicator(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Display remote user's video
  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _liveService.agoraEngine,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: const RtcConnection(channelId: "test"),
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
