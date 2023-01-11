import 'dart:async';

import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/models/live/live-session-configuration.model.dart';
import 'package:Talkaboat/models/live/live-session.model.dart';
import 'package:Talkaboat/services/hubs/live/agorasettings.dart';
import 'package:Talkaboat/services/hubs/live/live-hub.service.dart';
import 'package:Talkaboat/services/repositories/live-session.repository.dart';
import 'package:Talkaboat/services/user/user.service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

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
        debugPrint("onRemovedAsHost $event");
        if (event == userService.userInfo!.userName) {
          await demoteToViewer();
          _currentSess!.hosts.removeWhere((x) => x.userName == event);
          notifyListeners();
        }
      }
    });
    _hub.onHostRequest.listen((event) {
      if (!hostRequest.contains(event)) {
        hostRequest.add(event);
        notifyListeners();
      }
    });
  }

  @override
  Future<void> dispose() async {
    await leave();
    super.dispose();
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

  bool _isJoined = false;
  String _roomGuid = "";
  String _roomName = "";

  bool get isJoined => _isJoined;
  String get roomGuid => _roomGuid;
  String get roomName => _roomName;
  AgoraSettings _agoraSettings = AgoraSettings();
  AgoraSettings get agoraSettings => _agoraSettings;

  final _remoteUsers = <int>[];
  List<int> get remoteUsers => _remoteUsers;

  final Map<int, bool> _userVideoOn = {};
  Map<int, bool> get userVideoOn => _userVideoOn;

  LiveSession? _currentSess;
  LiveSession? get currentSession => _currentSess;
  bool get isHost =>
      remoteUsers.contains(userService.userInfo?.userId) ||
      (currentSession?.hosts.map((x) => x.userName).contains(userService.userInfo?.userName) ?? false);

  setSession(LiveSession sess) {
    _currentSess = sess;
    notifyListeners();
  }

  final userService = getIt<UserService>();

  Future<String> getToken(String roomId, bool isGuest) async {
    var response = await (isGuest ? LiveSessionRepository.getTokenGuest(roomId) : LiveSessionRepository.getToken(roomId));
    debugPrint(response.data);
    return response.data!;
  }

  Future<void> setupVideoSdkEngine() async {
    await [Permission.microphone, Permission.camera].request();
    _agoraSettings = AgoraSettings(engine: createAgoraRtcEngine());
    await _agoraSettings.agoraEngine.initialize(const RtcEngineContext(appId: AgoraSettings.appId));
    await _agoraSettings.agoraEngine.enableAudioVolumeIndication(interval: 200, smooth: 3, reportVad: true);

    _agoraSettings.agoraEngine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          _isJoined = true;
          debugPrint("joined channel ${connection.channelId} ${connection.localUid}");
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
          debugPrint("error $remoteUid $reason");
          _remoteUsers.remove(remoteUid);
          _userVideoOn[remoteUid] = false;
          if (_currentSess != null) {
            _currentSess!.hosts.removeWhere((x) => x.userId == remoteUid);
          }
          notifyListeners();
        },
        onError: (err, msg) {
          debugPrint("error $err $msg");
        },
        onLeaveChannel: (con, stats) {
          debugPrint("onLeaveChannel");
          _remoteUsers.clear();
          _userVideoOn.clear();
          notifyListeners();
        },
        onRemoteVideoStateChanged: (connection, remoteUid, state, reason, elapsed) {
          debugPrint("onRemoteVideoStateChanged $remoteUid $state $reason");
          if (state == RemoteVideoState.remoteVideoStateStopped) {
            _userVideoOn[remoteUid] = false;
            notifyListeners();
          } else if (state == RemoteVideoState.remoteVideoStateStarting) {
            _userVideoOn[remoteUid] = true;
            notifyListeners();
          }
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
    await setupVideoSdkEngine();
    ChannelMediaOptions options = const ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleAudience,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    );
    await _agoraSettings.agoraEngine.setClientRole(role: ClientRoleType.clientRoleAudience);
    await _agoraSettings.agoraEngine.enableAudio();
    await _agoraSettings.agoraEngine.enableVideo();
    final token = await getToken(roomId, userService.guest);

    await join(roomId, roomName, options, token, false);
  }

  Future<void> joinAsHost(String roomId, String roomName) async {
    notifyListeners();
    await setupVideoSdkEngine();
    ChannelMediaOptions options = const ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    );
    await _agoraSettings.agoraEngine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _agoraSettings.agoraEngine.enableAudio();
    await _agoraSettings.agoraEngine.enableVideo();
    await _agoraSettings.agoraEngine.startPreview();
    await _agoraSettings.agoraEngine.muteLocalAudioStream(false);
    final token = await getToken(roomId, userService.guest);

    await join(roomId, roomName, options, token, true);
  }

  Future<void> join(String roomGuid, String roomName, ChannelMediaOptions options, String token, bool asHost) async {
    _roomGuid = roomGuid;
    _roomName = roomName;
    await setupHub(roomGuid, asHost);
    await _agoraSettings.agoraEngine.joinChannel(
      token: token,
      channelId: roomGuid,
      options: options,
      uid: userService.userInfo?.userId ?? 0,
    );
    notifyListeners();
  }

  promoteToHost() async {
    try {
      await _agoraSettings.agoraEngine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
      await _agoraSettings.agoraEngine.startPreview();
      await _agoraSettings.agoraEngine.muteLocalAudioStream(false);
      final token = await getToken(_roomGuid, userService.guest);
      _agoraSettings.agoraEngine.renewToken(token);
      debugPrint("joined as host as ${ClientRoleType.clientRoleBroadcaster}");
      notifyListeners();
    } catch (e) {
      debugPrint("$e");
    }
  }

  demoteToViewer() async {
    try {
      debugPrint("demoting");
      await _agoraSettings.agoraEngine.muteLocalAudioStream(true);
      await _agoraSettings.agoraEngine.setClientRole(role: ClientRoleType.clientRoleAudience);
      await _agoraSettings.agoraEngine.stopPreview();
      final token = await getToken(_roomGuid, userService.guest);
      _agoraSettings.agoraEngine.renewToken(token);
      debugPrint("joined as viewer as ${ClientRoleType.clientRoleAudience}");
      notifyListeners();
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future<void> leave() async {
    await cleanupHub();
    await _agoraSettings.agoraEngine.stopPreview();
    await _agoraSettings.agoraEngine.leaveChannel();
    await _agoraSettings.agoraEngine.disableVideo();
    await _agoraSettings.agoraEngine.disableAudio();
    await _agoraSettings.agoraEngine.release();
    _isJoined = false;

    await LiveSessionRepository.leaveRoom(_roomGuid);
    _roomName = "";
    _currentSess = null;
    _roomGuid = "";
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

  acceptHostRequest(String username) async {
    hostRequest.removeWhere((x) => x == username);
    await _hub.AddHost(_roomGuid, username);
    notifyListeners();
  }

  rejectHostRequest(String username) async {
    hostRequest.removeWhere((x) => x == username);
    notifyListeners();
  }
}
