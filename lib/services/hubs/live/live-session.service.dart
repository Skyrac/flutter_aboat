import 'dart:async';

import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/models/live/live-session-configuration.model.dart';
import 'package:Talkaboat/models/live/live-session.model.dart';
import 'package:Talkaboat/services/hubs/live/live-hub.service.dart';
import 'package:Talkaboat/services/repositories/live-session.repository.dart';
import 'package:Talkaboat/services/user/user.service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

enum Camera { front, back }

class LiveSessionService extends ChangeNotifier {
  LiveSessionService() : super() {
    _hub.onAddedAsHost.listen((event) async {
      updateHosts();
      if (event == userService.userInfo!.userName) {
        await promoteToHost();
      }
      notifyListeners();
    });
    _hub.onRemovedAsHost.listen((event) async {
      if (_currentSess != null) {
        _currentSess!.hosts.removeWhere((x) => x.userName == event);
        if (event == userService.userInfo!.userName) {
          await demoteToViewer();
        }
        notifyListeners();
      }
    });
    _hub.onHostRequest.listen((event) {
      hostRequest.add(event);
      notifyListeners();
    });
  }

  updateHosts() async {
    if (_currentSess != null) {
      final sess = await LiveSessionRepository.getRoom(_currentSess!.guid);
      _currentSess!.hosts = sess!.hosts;
    }
  }

  final StreamController<String> onAddedAsHostController = StreamController.broadcast();
  final StreamController<String> onRemovedAsHostController = StreamController.broadcast();

  Stream<String> get onLiveSessionEnded => _hub.onLiveSessionEnded;
  Stream<String> get onAddedAsHost => onAddedAsHostController.stream;
  Stream<String> get onRemovedAsHost => onAddedAsHostController.stream;

  final LiveHubService _hub = LiveHubService();
  final List<String> hostRequest = List.empty(growable: true);

  acceptHostRequest(String username) async {
    hostRequest.removeWhere((x) => x == username);
    await _hub.AddHost(_roomGuid, username);
    notifyListeners();
  }

  rejectHostRequest(String username) async {
    hostRequest.removeWhere((x) => x == username);
    await _hub.RemoveHostAccess(_roomGuid, username);
    notifyListeners();
  }

  static const String appId = "c0ad2b8f2be149788fabb9d916f0fbef";
  final _users = <int>[];
  final Map<int, bool> _userVideoOn = {};
  bool _isJoined = false;
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

  LiveSession? _currentSess;
  LiveSession? get currentSession => _currentSess;
  bool get isHost => currentSession?.hosts.map((x) => x.userName).contains(userService.userInfo?.userName) ?? false;

  final userService = getIt<UserService>();

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
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) async {
          debugPrint("onUserJoined ${connection.channelId} ${connection.localUid} $remoteUid");
          _users.add(remoteUid);
          _userVideoOn[remoteUid] = true;
          await updateHosts();

          notifyListeners();
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) async {
          _users.remove(remoteUid);
          _userVideoOn[remoteUid] = false;
          if (_currentSess != null) {
            _currentSess!.hosts.removeWhere((x) => x.userId == remoteUid);
            notifyListeners();
          }
          notifyListeners();
        },
        onError: (err, msg) {
          debugPrint("error $err $msg");
        },
        onLeaveChannel: (con, stats) {
          _users.clear();
          _userVideoOn.clear();
          notifyListeners();
        },
        onRemoteVideoStateChanged: (connection, remoteUid, state, reason, elapsed) {
          debugPrint("onRemoteVideoStateChanged $remoteUid $state $reason");
        },
        onUserEnableVideo: (connection, remoteUid, enabled) {
          debugPrint("onUserEnableVideo $remoteUid $enabled");
          if (_userVideoOn[remoteUid] != enabled) {
            _userVideoOn[remoteUid] = enabled;
            notifyListeners();
          }
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
    await setupVideoSdkEngine();
    ChannelMediaOptions options = const ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleAudience,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    );
    await agoraEngine.setClientRole(role: ClientRoleType.clientRoleAudience);
    await agoraEngine.enableAudio();
    await agoraEngine.enableVideo();
    final token = await getToken(roomId);

    await join(roomId, roomName, options, token, false);
  }

  Future<void> joinAsHost(String roomId, String roomName) async {
    notifyListeners();
    //await setupVideoSdkEngine();
    ChannelMediaOptions options = const ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    );
    //await agoraEngine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    //await agoraEngine.enableAudio();
    //await agoraEngine.enableVideo();
    //await agoraEngine.startPreview();
    final token = await getToken(roomId);

    await join(roomId, roomName, options, token, true);
  }

  Future<void> join(String roomGuid, String roomName, ChannelMediaOptions options, String token, bool asHost) async {
    _roomGuid = roomGuid;
    _roomName = roomName;
    await setupHub(roomGuid, asHost);
    //await agoraEngine.joinChannel(
    //  token: token,
    //  channelId: roomGuid,
    //  options: options,
    //  uid: userService.userInfo?.userId ?? 0,
    //);
    notifyListeners();
  }

  promoteToHost() async {
    await agoraEngine.leaveChannel();
    //await setupVideoSdkEngine();
    ChannelMediaOptions options = const ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    );
    await agoraEngine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await agoraEngine.enableAudio();
    await agoraEngine.enableVideo();
    await agoraEngine.startPreview();
    final token = await getToken(_roomGuid);

    await join(_roomGuid, roomName, options, token, true);
  }

  demoteToViewer() async {
    await agoraEngine.leaveChannel();
    await agoraEngine.stopPreview();
    await setupVideoSdkEngine();
    ChannelMediaOptions options = const ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleAudience,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    );
    await agoraEngine.setClientRole(role: ClientRoleType.clientRoleAudience);
    await agoraEngine.enableAudio();
    await agoraEngine.enableVideo();
    final token = await getToken(_roomGuid);

    await join(_roomGuid, roomName, options, token, false);
  }

  Future<void> leave() async {
    await cleanupHub();
    await agoraEngine.stopPreview();
    await agoraEngine.leaveChannel();
    await agoraEngine.disableVideo();
    await agoraEngine.disableAudio();
    await LiveSessionRepository.closeRoom(_roomGuid);
    _isJoined = false;
    _users.clear();
    _userVideoOn.clear();
    _roomName = "";
    _roomGuid = "";
    _currentSess = null;
    notifyListeners();
  }

  setupHub(String roomId, bool asHost) async {
    await _hub.connect();
    await _hub.Join(roomGuid);
    if (asHost && !currentSession!.hosts.map((x) => x.userName).contains(userService.userInfo!.userName)) {
      final sess = await LiveSessionRepository.getRoom(_currentSess!.guid);
      _currentSess!.hosts = sess!.hosts;
    }
  }

  cleanupHub() async {
    await _hub.Leave(_roomGuid);
    await _hub.disconnect();
    hostRequest.clear();
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

  removeHost(String username, String roomId) async {
    return await _hub.RemoveHostAccess(roomId, username);
  }

  addHost(String username, String roomId) async {
    return await _hub.AddHost(roomId, username);
  }

  requestToJoin() async {
    if (_currentSess != null) {
      return await _hub.RequestHost(_currentSess!.guid);
    }
  }

  setSession(LiveSession sess) {
    _currentSess = sess;
    notifyListeners();
  }
}
