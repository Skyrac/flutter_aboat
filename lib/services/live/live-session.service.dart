import 'dart:async';
import 'package:Talkaboat/services/repositories/live-session.repository.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
class LiveSessionService {
  static const String appId = "c0ad2b8f2be149788fabb9d916f0fbef";
  int _uid = 0;
  int? _remoteUid;
  bool _isJoined = false;
  bool _isHost = false;
  String _connectedRoom = "";
  String _roomGuid = "";
  late RtcEngine _agoraEngine;


  bool get isJoined => _isJoined;
  bool get isHost => _isHost;
  String get connectedRoom => _connectedRoom;
  String get roomGuid => _roomGuid;
  int? get remoteUid => _remoteUid;
  int get uid => _uid;
  RtcEngine get agoraEngine => _agoraEngine;

  Future<String> getToken() async {
    var response = await LiveSessionRepository.getToken(_roomGuid);
    print(response.data);
    return response.data!;
  }

  Future<void> setupVideoSdkEngine() async {
    await [Permission.microphone, Permission.camera].request();
    _agoraEngine = createAgoraRtcEngine();
    await agoraEngine.initialize(const RtcEngineContext(
        appId: appId
    ));

    await agoraEngine.enableVideo();
    agoraEngine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            _isJoined = true;
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {

            _remoteUid = remoteUid;
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
            _remoteUid = null;
        },
      ),
    );
  }

  Future<void> openRoom(String roomName) async {
    var data = { "RoomName": roomName };
    var response = await LiveSessionRepository.openRoom(data);
    await joinAsHost(response.configuration.roomName, response.guid);
  }

  Future<void> joinAsViewer(String roomName, String roomId) async {
    ChannelMediaOptions options = const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleAudience,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      );
    await join(roomName, roomId, options);
  }

  Future<void> joinAsHost(String roomName, String roomId) async {
    ChannelMediaOptions options = const ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    );

    await join(roomName, roomId, options);
    await agoraEngine.startPreview();
  }

  Future<void> join(String roomName, String roomGuid, ChannelMediaOptions options) async {
    await setupVideoSdkEngine();
    _connectedRoom = roomName;
    _roomGuid = roomGuid;
    await agoraEngine.joinChannel(
      token: await getToken(),
      channelId: roomGuid,
      options: options,
      uid: uid,
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