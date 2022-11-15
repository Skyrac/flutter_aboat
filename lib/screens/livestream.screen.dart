import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/services/live/live-session.service.dart';
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
      _liveService.joinAsHost("roomName", widget.roomId);
    }
  }

  /*Future<void> initAgora() async {
    // retrieve permissions
    await [Permission.microphone, Permission.camera].request();

    //create the engine
    _engine = createAgoraRtcEngine();
    await _engine.setLogLevel(LogLevel.logLevelWarn);
    await _engine.initialize(const RtcEngineContext(
      appId: "c0ad2b8f2be149788fabb9d916f0fbef",
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("local user ${connection.localUid} joined");
          setState(() {
            _localUserJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("remote user $remoteUid joined");
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          debugPrint("remote user $remoteUid left channel");
          setState(() {
            _remoteUid = null;
          });
        },
        onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
          debugPrint('[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
        },
      ),
    );

    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine.enableVideo();
    await _engine.startPreview();

    var data = {
      "roomName": "test",
      "password": "test",
      "onlyClubhouse": true,
      "onlySuperhostCanRemoveHost": true,
      "onlySuperhostCanAddHost": true
    };
    var roomResponse = await LiveSessionRepository.openRoom(data);
    var response = await LiveSessionRepository.getToken(roomResponse!.guid);

    /*await _engine.joinChannel(
      token: response.data!,
      channelId: roomResponse.guid,
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ),
      uid: 0,
    );*/
  }*/

  // Create UI with local view and remote view
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agora Video Call'),
      ),
      body: Stack(
        children: [
          Center(
            child: _remoteVideo(),
          ),
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
