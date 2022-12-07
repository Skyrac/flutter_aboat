import 'dart:async';

import 'package:Talkaboat/models/live/live-session-configuration.model.dart';
import 'package:Talkaboat/models/live/live-session.model.dart';
import 'package:Talkaboat/services/repositories/live-session.repository.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

enum Camera { front, back }

class LiveSessionService extends ChangeNotifier {
  static const String appId = "c0ad2b8f2be149788fabb9d916f0fbef";
  final _users = <int>[];
  final Map<int, bool> _userVideoOn = {};
  bool _isJoined = false;
  bool _isHost = false;
  String _roomGuid = "";
  String _roomName = "";
  late RtcEngine _agoraEngine;
  Camera _camera = Camera.front;
  bool _chatVisible = true;
  bool _videoOn = true;
  bool _localAudio = true;
  bool _audioMuted = false;
  bool _initialized = false;

  bool get isJoined => _isJoined;
  bool get isHost => _isHost;
  String get roomGuid => _roomGuid;
  String get roomName => _roomName;
  List<int> get users => _users;
  Map<int, bool> get userVideoOn => _userVideoOn;
  RtcEngine get agoraEngine => _agoraEngine;
  Camera get camera => _camera;
  bool get chatVisible => _chatVisible;
  bool get videoOn => _videoOn;
  bool get localAudio => _localAudio;
  bool get audioMuted => _audioMuted;

  Future<String> getToken(String roomId) async {
    var response = await LiveSessionRepository.getToken(roomId);
    debugPrint(response.data);
    return response.data!;
  }

  Future<void> setupVideoSdkEngine() async {
    if (_initialized) {
      debugPrint("already initalized");
      return;
    }
    _initialized = true;
    await [Permission.microphone, Permission.camera].request();
    _agoraEngine = createAgoraRtcEngine();
    await _agoraEngine.initialize(const RtcEngineContext(appId: appId));
    await _agoraEngine.enableAudioVolumeIndication(interval: 200, smooth: 3, reportVad: true);

    agoraEngine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          _isJoined = true;
          debugPrint("joined channel ${connection.channelId} ${connection.localUid}");
          notifyListeners();
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("onUserJoined ${connection.channelId} ${connection.localUid} $remoteUid");
          _users.add(remoteUid);
          _userVideoOn[remoteUid] = false;
          notifyListeners();
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          _users.remove(remoteUid);
          _userVideoOn[remoteUid] = false;
          notifyListeners();
        },
        onError: (err, msg) {
          debugPrint("error $err $msg");
        },
        onLeaveChannel: (con, stats) {
          _users.clear();
          _userVideoOn.clear();
        },
        onRemoteVideoStateChanged: (connection, remoteUid, state, reason, elapsed) {
          debugPrint("onRemoteVideoStateChanged $remoteUid $state $reason");
        },
        onUserEnableVideo: (connection, remoteUid, enabled) {
          debugPrint("onUserEnableVideo $remoteUid $enabled");
          _userVideoOn[remoteUid] = enabled;
          notifyListeners();
        },
      ),
    );
  }

  Future<LiveSession?> openRoom(String roomName) async {
    LiveSessionConfiguration data = LiveSessionConfiguration(
        roomName: roomName, onlyClubhouse: false, onlySuperhostCanAddHost: false, onlySuperhostCanRemoveHost: false);
    return await LiveSessionRepository.openRoom(data);
  }

  Future<void> joinAsViewer(String roomId, String roomName) async {
    _isHost = false;
    await setupVideoSdkEngine();
    ChannelMediaOptions options = const ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleAudience,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    );
    await agoraEngine.setClientRole(role: ClientRoleType.clientRoleAudience);
    await agoraEngine.enableAudio();
    await agoraEngine.enableVideo();
    final token = await getToken(roomId);

    await join(roomId, roomName, options, token, 0);
  }

  Future<void> joinAsHost(String roomId, String roomName) async {
    _isHost = true;
    notifyListeners();
    await setupVideoSdkEngine();
    ChannelMediaOptions options = const ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    );
    await agoraEngine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await agoraEngine.enableAudio();
    await agoraEngine.enableVideo();
    await agoraEngine.startPreview();
    final token = await getToken(roomId);

    await join(roomId, roomName, options, token, 0);
  }

  Future<void> join(String roomGuid, String roomName, ChannelMediaOptions options, String token, int uid) async {
    _roomGuid = roomGuid;
    _roomName = roomName;
    await agoraEngine.joinChannel(
      token: token,
      channelId: roomGuid,
      options: options,
      uid: uid,
    );
    notifyListeners();
  }

  Future<void> leave() async {
    if (_isHost) {
      await agoraEngine.stopPreview();
    }
    _isHost = false;
    await agoraEngine.leaveChannel();
    await agoraEngine.disableVideo();
    await agoraEngine.disableAudio();
    await LiveSessionRepository.closeRoom(_roomGuid);
    _isJoined = false;
    _users.clear();
    _userVideoOn.clear();
    _roomName = "";
    _roomGuid = "";
    notifyListeners();
  }

  @override
  Future<void> dispose() async {
    await leave();
    super.dispose();
  }

  Future<void> switchCamera() async {
    await agoraEngine.switchCamera();
    if (_camera == Camera.front) {
      _camera = Camera.back;
    } else {
      _camera = Camera.front;
    }

    notifyListeners();
  }

  switchChat() {
    _chatVisible = !_chatVisible;
    notifyListeners();
  }

  switchVideo() async {
    _videoOn = !_videoOn;
    await agoraEngine.enableLocalVideo(_videoOn);
    notifyListeners();
  }

  switchLocalAudio() async {
    _localAudio = !_localAudio;
    await agoraEngine.muteLocalAudioStream(_localAudio);
    notifyListeners();
  }

  switchAudio() async {
    _audioMuted = !_audioMuted;

    for (var user in _users) {
      await agoraEngine.muteRemoteAudioStream(uid: user, mute: _audioMuted);
    }
    notifyListeners();
  }

  removeHost(int userId) async {
    return await LiveSessionRepository.removeHost(_roomGuid, userId);
  }

  addHost(int userId) async {
    return await LiveSessionRepository.addHost(_roomGuid, userId);
  }
}
