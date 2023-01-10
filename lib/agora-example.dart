import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

const appId = "e3054f4262824f6d95aceacc878f8f64";

class AgoraExample extends StatefulWidget {
  const AgoraExample({Key? key, required this.isHost, required this.id}) : super(key: key);

  final bool isHost;
  final int id;

  @override
  State<AgoraExample> createState() => _AgoraExampleState();
}

const int tokenRoleHost = 1; // use 1 for Host/Broadcaster, 2 for Subscriber/Audience
const int tokenRoleViewer = 2; // use 1 for Host/Broadcaster, 2 for Subscriber/Audience
const String serverUrl =
    "https://touted-slave-production.up.railway.app"; // The base URL to your token server, for example "https://agora-token-service-production-92ff.up.railway.app"
const int tokenExpireTime = 3600; // Expire time in Seconds.
const bool isTokenExpiring = false; // Set to true when the token is about to expire
const channelName = "f";

Future<String> getHostToken(int id) async {
  String url =
      '$serverUrl/rtc/$channelName/${tokenRoleHost.toString()}/uid/${id.toString()}?expiry=${tokenExpireTime.toString()}';

  // Send the request
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    // If the server returns an OK response, then parse the JSON.
    Map<String, dynamic> json = jsonDecode(response.body);
    String newToken = json['rtcToken'];
    debugPrint('Token Received: $newToken');
    // Use the token to join a channel or renew an expiring token
    return newToken;
  } else {
    // If the server did not return an OK response,
    // then throw an exception.
    throw Exception('Failed to fetch a token. Make sure that your server URL is valid');
  }
}

Future<String> getViewerToken(int id) async {
  String url =
      '$serverUrl/rtc/$channelName/${tokenRoleViewer.toString()}/uid/${id.toString()}?expiry=${tokenExpireTime.toString()}';

  // Send the request
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    // If the server returns an OK response, then parse the JSON.
    Map<String, dynamic> json = jsonDecode(response.body);
    String newToken = json['rtcToken'];
    debugPrint('Token Received: $newToken');
    // Use the token to join a channel or renew an expiring token
    return newToken;
  } else {
    // If the server did not return an OK response,
    // then throw an exception.
    throw Exception('Failed to fetch a token. Make sure that your server URL is valid');
  }
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
        print("myErr $err $msg");
      })),
    );

    if (widget.isHost) {
      await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
      await _engine.enableVideo();
      await _engine.startPreview();
      final token = await getHostToken(widget.id);

      await _engine.joinChannel(
        token: token,
        channelId: channelName,
        uid: widget.id,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        ),
      );
    } else {
      await _engine.setClientRole(role: ClientRoleType.clientRoleAudience);
      await _engine.enableVideo();
      final token = await getViewerToken(widget.id);

      await _engine.joinChannel(
        token: token,
        channelId: channelName,
        uid: widget.id,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleAudience,
          channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        ),
      );
    }
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
          connection: const RtcConnection(channelId: channelName),
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
