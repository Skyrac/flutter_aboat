import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/services/live/live-session.service.dart';
import 'package:Talkaboat/utils/scaffold_wave.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';

class LivestreamScreen extends StatefulWidget {
  const LivestreamScreen({Key? key, required this.roomId, required this.roomName, required this.isHost}) : super(key: key);

  final String roomId;
  final String roomName;
  final bool isHost;

  @override
  State<LivestreamScreen> createState() => _LivestreamScreenState();
}

class _LivestreamScreenState extends State<LivestreamScreen> {
  final LiveSessionService _liveService = getIt<LiveSessionService>();

  @override
  void initState() {
    super.initState();
    if (widget.isHost) {
      _liveService.joinAsHost(widget.roomId, widget.roomName);
    } else {
      _liveService.joinAsViewer(widget.roomId, widget.roomName);
    }
  }

  @override
  void dispose() {
    _liveService.leave();
    super.dispose();
  }

  // Create UI with local view and remote view
  @override
  Widget build(BuildContext context) {
    return ScaffoldWave(
      appBar: AppBar(
        title: const Text('Agora Video Call'),
      ),
      body: AnimatedBuilder(
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
    );
  }

  // Display remote user's video
  Widget _remoteVideo() {
    if (_liveService.remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _liveService.agoraEngine,
          canvas: VideoCanvas(uid: _liveService.remoteUid),
          connection: RtcConnection(channelId: widget.roomName),
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
