import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

const appId = "c0ad2b8f2be149788fabb9d916f0fbef";
const token =
    "006c0ad2b8f2be149788fabb9d916f0fbefIAArwYBSMbJr5TX5I6/Yxw4hL1Yvj01kkRlLUtbxutVsSikV+3O4bbbIEABy68VqZZ13YwEAAQD1WXZj";
const channel = "test2";

class AgoraExample extends StatefulWidget {
  const AgoraExample({Key? key}) : super(key: key);

  @override
  State<AgoraExample> createState() => _AgoraExampleState();
}

class _AgoraExampleState extends State<AgoraExample> {
  int? _remoteUid;
  bool _localUserJoined = false;
  late RtcEngine _engine;

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> initAgora() async {
    // retrieve permissions
    await [Permission.microphone, Permission.camera].request();

    //create the engine
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
      appId: appId,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));

    _engine.registerEventHandler(
      RtcEngineEventHandler(onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
        print("local user ${connection.localUid} joined");
        setState(() {
          _localUserJoined = true;
        });
      }, onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
        print("remote user $remoteUid joined");
        setState(() {
          _remoteUid = remoteUid;
        });
      }, onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
        print("remote user $remoteUid left channel");
        setState(() {
          _remoteUid = null;
        });
      }, onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
        print('[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
      }, onError: ((err, msg) {
        print("$err $msg");
      })),
    );

    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine.enableVideo();
    await _engine.startPreview();

    await _engine.joinChannel(
      token: token,
      channelId: channel,
      uid: 0,
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ),
    );
  }

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
                child: _localUserJoined
                    ? AgoraVideoView(
                        controller: VideoViewController(
                          rtcEngine: _engine,
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
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: const RtcConnection(channelId: channel),
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
