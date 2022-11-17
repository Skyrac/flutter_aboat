import 'dart:async';
import 'package:Talkaboat/models/live/live-session-configuration.model.dart';
import 'package:Talkaboat/models/live/live-session.model.dart';
import 'package:Talkaboat/services/repositories/live-session.repository.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class LiveSessionService {
  static const String appId = "c0ad2b8f2be149788fabb9d916f0fbef";
  int? _remoteUid;
  bool _isJoined = false;
  bool _isHost = false;
  String _roomGuid = "";
  late RtcEngine _agoraEngine;

  bool get isJoined => _isJoined;
  bool get isHost => _isHost;
  String get roomGuid => _roomGuid;
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
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          _remoteUid = remoteUid;
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          _remoteUid = null;
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

  Future<void> joinAsViewer(String roomId) async {
    ChannelMediaOptions options = const ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleAudience,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    );
    await join(roomId, options);
  }

  Future<void> joinAsHost(String roomId) async {
    ChannelMediaOptions options = const ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    );

    await join(roomId, options);
    await agoraEngine.startPreview();
  }

  Future<void> join(String roomGuid, ChannelMediaOptions options) async {
    await setupVideoSdkEngine();
    _roomGuid = roomGuid;
    await agoraEngine.joinChannel(
      token: await getToken(roomGuid),
      channelId: roomGuid,
      options: options,
      uid: 0,
    );
  }

  Future<void> leave() async {
    _isJoined = false;
    _remoteUid = null;
    await agoraEngine.leaveChannel();
  }

  Future<void> dispose() async {
    await agoraEngine.leaveChannel();
  }
}
