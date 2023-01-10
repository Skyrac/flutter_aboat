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
      if (event == userService.userInfo!.userName) {
        updateHosts(userService.userInfo!.userName, false);
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

  Stream<String> get onAddedAsHost => _hub.onAddedAsHost;
  Stream<String> get onRemovedAsHost => _hub.onRemovedAsHost;
  Stream<String> get onLiveSessionEnded => _hub.onLiveSessionEnded;

  Future<void> updateAllUsers() async {
    final sess = await LiveSessionRepository.getRoom(_currentSess!.guid);
    if (sess != null) {
      _currentSess!.hosts = sess.hosts;
      _currentSess!.users = sess.users;
    }
  }

  Future<void> updateHosts(String? username, bool? demoted) async {
    assert((username == null && demoted == null) || (username != null && demoted != null));
    if (_currentSess != null) {
      if (username == null) {
        await updateAllUsers();
      } else {
        if (demoted!) {
          final host = _currentSess!.hosts.where((x) => x.userName == username).toList();
          if (host.isNotEmpty) {
            _currentSess!.hosts.remove(host.first);
          } else {
            debugPrint("did not find $username in hosts");
            await updateAllUsers();
          }
        } else {
          final user = _currentSess!.users.where((x) => x.userName == username).toList();
          if (user.isNotEmpty) {
            _currentSess!.hosts.add(user.first);
            debugPrint("made ${user.first} a host");
          } else {
            debugPrint("did not find $username in users");
            await updateAllUsers();
          }
        }
      }
    }
  }

  Future<void> updateHostsById(int? userid, bool? demoted) async {
    assert((userid == null && demoted == null) || (userid != null && demoted != null));
    if (_currentSess != null) {
      if (userid == null) {
        await updateAllUsers();
      } else {
        if (demoted!) {
          final host = _currentSess!.hosts.where((x) => x.userId == userid).toList();
          if (host.isNotEmpty) {
            _currentSess!.hosts.remove(host.first);
          } else {
            debugPrint("did not find $userid in hosts");
            await updateAllUsers();
          }
        } else {
          final user = _currentSess!.users.where((x) => x.userId == userid).toList();
          if (user.isNotEmpty) {
            _currentSess!.hosts.add(user.first);
          } else {
            debugPrint("did not find $userid in users");
            await updateAllUsers();
          }
        }
      }
    }
  }

  final LiveHubService _hub = LiveHubService();
  final List<String> hostRequest = List.empty(growable: true);

  acceptHostRequest(String username) async {
    hostRequest.removeWhere((x) => x == username);
    await addHost(username, _currentSess!.guid);
    notifyListeners();
  }

  rejectHostRequest(String username) async {
    hostRequest.removeWhere((x) => x == username);
    //await _hub.RemoveHostAccess(_roomGuid, username);
    notifyListeners();
  }

  static const String appId = "c0ad2b8f2be149788fabb9d916f0fbef";
  final _remoteUsers = <int>[];
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

  bool get isJoined => _isJoined;
  String get roomGuid => _roomGuid;
  String get roomName => _roomName;
  List<int> get users => _remoteUsers;
  Map<int, bool> get userVideoOn => _userVideoOn;
  RtcEngine get agoraEngine => _agoraEngine;
  Camera get camera => _camera;
  bool get chatVisible => _chatVisible;
  bool get videoOn => _videoOn;
  bool get localAudio => _localAudio;
  bool get audioMuted => _audioMuted;

  LiveSession? _currentSess;
  LiveSession? get currentSession => _currentSess;
  bool get isHost =>
      _remoteUsers.contains(userService.userInfo?.userId) ||
      (currentSession?.hosts.map((x) => x.userName).contains(userService.userInfo?.userName) ?? false);

  final userService = getIt<UserService>();

  Future<String> getToken(String roomId) async {
    var response = await LiveSessionRepository.getToken(roomId);
    debugPrint(response.data);
    return response.data!;
  }

  Future<void> setupVideoSdkEngine() async {
    await [Permission.microphone, Permission.camera].request();
    _agoraEngine = createAgoraRtcEngine();
    await _agoraEngine.initialize(const RtcEngineContext(appId: appId));
    await _agoraEngine.enableAudioVolumeIndication(interval: 200, smooth: 3, reportVad: true);

    agoraEngine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          _isJoined = true;
          debugPrint("onJoinChannelSuccess ${connection.channelId} ${connection.localUid}");
          notifyListeners();
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) async {
          debugPrint("onUserJoined ${connection.channelId} ${connection.localUid} $remoteUid");
          _remoteUsers.add(remoteUid);
          _userVideoOn[remoteUid] = true;
          await updateHostsById(remoteUid, false);

          notifyListeners();
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) async {
          debugPrint("onUserOffline $remoteUid $reason");
          _remoteUsers.remove(remoteUid);
          _userVideoOn[remoteUid] = false;
          if (_currentSess != null) {
            _currentSess!.hosts.removeWhere((x) => x.userId == remoteUid);
          }
          notifyListeners();
        },
        onError: (err, msg) {
          debugPrint("onError $err $msg");
        },
        onLeaveChannel: (con, stats) {
          debugPrint("onLeaveChannel");
          _remoteUsers.clear();
          _userVideoOn.clear();
          notifyListeners();
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
    await agoraEngine.enableAudio();
    await agoraEngine.enableVideo();

    agoraEngine.enableDualStreamMode(enabled: true);
    agoraEngine.setAudioProfile(
        profile: AudioProfileType.audioProfileMusicHighQualityStereo, scenario: AudioScenarioType.audioScenarioMeeting);

    // Set the video configuration
    VideoEncoderConfiguration videoConfig = const VideoEncoderConfiguration(
        mirrorMode: VideoMirrorModeType.videoMirrorModeAuto,
        frameRate: 7,
        bitrate: 90,
        dimensions: VideoDimensions(width: 160, height: 90),
        orientationMode: OrientationMode.orientationModeAdaptive,
        degradationPreference: DegradationPreference.maintainBalanced);

// Apply the configuration
    agoraEngine.setVideoEncoderConfiguration(videoConfig);
  }

  Future<LiveSession?> openRoom(String roomName) async {
    LiveSessionConfiguration data = LiveSessionConfiguration(
        roomName: roomName, onlyClubhouse: false, onlySuperhostCanAddHost: false, onlySuperhostCanRemoveHost: false);
    return await LiveSessionRepository.openRoom(data);
  }

  Future<void> joinAsViewer(String roomId, String roomName) async {
    await setupVideoSdkEngine();
    ChannelMediaOptions options = const ChannelMediaOptions(
      audienceLatencyLevel: AudienceLatencyLevelType.audienceLatencyLevelLowLatency,
      clientRoleType: ClientRoleType.clientRoleAudience,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    );
    await agoraEngine.setClientRole(role: ClientRoleType.clientRoleAudience);
    final token = await getToken(roomId);

    await join(roomId, roomName, options, token, false);
  }

  Future<void> joinAsHost(String roomId, String roomName) async {
    notifyListeners();
    await setupVideoSdkEngine();
    ChannelMediaOptions options = const ChannelMediaOptions(
      audienceLatencyLevel: AudienceLatencyLevelType.audienceLatencyLevelLowLatency,
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    );
    await agoraEngine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await agoraEngine.startPreview();
    final token = await getToken(roomId);

    await join(roomId, roomName, options, token, true);
  }

  Future<void> join(String roomGuid, String roomName, ChannelMediaOptions options, String token, bool asHost) async {
    _roomGuid = roomGuid;
    _roomName = roomName;
    await setupHub(roomGuid, asHost);
    await agoraEngine.joinChannel(
      token: token,
      channelId: roomGuid,
      options: options,
      uid: userService.userInfo?.userId ?? 0,
    );
    notifyListeners();
  }

  promoteToHost() async {
    try {
      //await agoraEngine.leaveChannel();
      //ChannelMediaOptions options = const ChannelMediaOptions(
      //  clientRoleType: ClientRoleType.clientRoleBroadcaster,
      //  channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      //);
      await agoraEngine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
      await agoraEngine.muteLocalAudioStream(false);
      await agoraEngine.muteLocalVideoStream(false);
      await agoraEngine.startPreview();
      debugPrint("myErr became broadcaster");
      notifyListeners();
      //final token = await getToken(_roomGuid);
//
      //await agoraEngine.joinChannel(
      //  token: token,
      //  channelId: roomGuid,
      //  options: options,
      //  uid: userService.userInfo?.userId ?? 0,
      //);
      //debugPrint("joined as host as ${options.clientRoleType}");
    } catch (e) {
      debugPrint("myErr $e");
    }
  }

  demoteToViewer() async {
    try {
      _isJoined = false;
      notifyListeners();

      await agoraEngine.leaveChannel();
      await agoraEngine.stopPreview();
      ChannelMediaOptions options = const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleAudience,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      );
      await agoraEngine.setClientRole(role: ClientRoleType.clientRoleAudience);
      final token = await getToken(_roomGuid);

      await agoraEngine.joinChannel(
        token: token,
        channelId: roomGuid,
        options: options,
        uid: userService.userInfo?.userId ?? 0,
      );
      _isJoined = true;
      notifyListeners();
    } catch (e) {
      debugPrint("$e");
    }
  }

  // TODO: isChangingState sollte obsolet sein da immer false
  Future<void> leave(bool isChangingState) async {
    await cleanupHub();
    await agoraEngine.stopPreview();
    await agoraEngine.leaveChannel();
    await agoraEngine.disableVideo();
    await agoraEngine.disableAudio();
    await agoraEngine.release();
    _isJoined = false;

    if (!isChangingState) {
      await LiveSessionRepository.closeRoom(_roomGuid);
      _roomName = "";
      _currentSess = null;
      _roomGuid = "";
    }
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
    await leave(false);
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

    for (var user in _remoteUsers) {
      agoraEngine.muteRemoteAudioStream(uid: user, mute: _audioMuted);
    }
    notifyListeners();
  }

  removeHost(String username, String roomId) async {
    await LiveSessionRepository.removeHost(roomId, username);
    return await _hub.RemoveHostAccess(roomId, username);
  }

  addHost(String username, String roomId) async {
    await LiveSessionRepository.addHost(roomId, username);
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
