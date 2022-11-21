import 'dart:async';
import 'package:Talkaboat/models/live/live-session-configuration.model.dart';
import 'package:Talkaboat/models/live/live-session.model.dart';
import 'package:Talkaboat/services/repositories/live-session.repository.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class LiveSessionService extends ChangeNotifier {
  static const String appId = "c0ad2b8f2be149788fabb9d916f0fbef";
  int? _remoteUid;
  bool _isJoined = false;
  bool _isHost = false;
  String _roomGuid = "";
  String _roomName = "";
  late RtcEngine _agoraEngine;

  bool get isJoined => _isJoined;
  bool get isHost => _isHost;
  String get roomGuid => _roomGuid;
  String get roomName => _roomName;
  int? get remoteUid => _remoteUid;
  RtcEngine get agoraEngine => _agoraEngine;

  Future<String> getToken(String roomId) async {
    var response = await LiveSessionRepository.getToken(roomId);
    print(response.data);
    return response.data!;
  }

  Future<void> setupVideoSdkEngine() async {
    await [Permission.microphone, Permission.camera].request();
    _agoraEngine = createAgoraRtcEngine();
    await _agoraEngine.initialize(const RtcEngineContext(appId: appId));
    await _agoraEngine.setLogLevel(LogLevel.logLevelError);

    agoraEngine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          _isJoined = true;
          print("joined channel ${connection.channelId} ${connection.localUid}");
          notifyListeners();
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          print("onUserJoined ${connection.channelId} ${connection.localUid} $remoteUid");
          _remoteUid = remoteUid;
          notifyListeners();
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          _remoteUid = null;
          notifyListeners();
        },
        onError: (err, msg) {
          print("error $err $msg");
        },
      ),
    );
    await agoraEngine.enableVideo();
  }

  Future<LiveSession?> openRoom(String roomName) async {
    LiveSessionConfiguration data = LiveSessionConfiguration(
        roomName: roomName, onlyClubhouse: false, onlySuperhostCanAddHost: false, onlySuperhostCanRemoveHost: false);
    return await LiveSessionRepository.openRoom(data);

    //await joinAsHost(response!.configuration!.roomName, response.guid);
  }

  Future<void> joinAsViewer(String roomId, String roomName) async {
    await setupVideoSdkEngine();
    ChannelMediaOptions options = const ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleAudience,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    );
    _isHost = false;
    await agoraEngine.setClientRole(role: ClientRoleType.clientRoleAudience);
    await join(roomId, roomName, options);
  }

  Future<void> joinAsHost(String roomId, String roomName) async {
    await setupVideoSdkEngine();
    ChannelMediaOptions options = const ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    );
    _isHost = true;
    await agoraEngine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await agoraEngine.startPreview();
    await join(roomId, roomName, options);
  }

  Future<void> join(String roomGuid, String roomName, ChannelMediaOptions options) async {
    _roomGuid = roomGuid;
    _roomName = roomName;
    final token = await getToken(roomGuid);

    await agoraEngine.joinChannel(
      token: token,
      channelId: roomGuid,
      options: options,
      uid: 0,
    );
    notifyListeners();
  }

  Future<void> leave() async {
    _isJoined = false;
    _remoteUid = null;
    _roomName = "";
    _roomGuid = "";
    if (_isHost) {
      await agoraEngine.stopPreview();
    }
    _isHost = false;
    await agoraEngine.leaveChannel();
    notifyListeners();
  }

  @override
  Future<void> dispose() async {
    await leave();
    super.dispose();
  }
}
