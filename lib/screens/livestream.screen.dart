import 'dart:async';
import 'dart:convert';

import 'package:Talkaboat/models/live/live-user.model.dart';
import 'package:Talkaboat/services/repositories/live-session.repository.dart';
import 'package:http/http.dart' as http;

import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/models/chat/chat-dtos.dart';
import 'package:Talkaboat/models/live/live-session.model.dart';
import 'package:Talkaboat/services/hubs/live/live-session.service.dart';
import 'package:Talkaboat/services/user/user.service.dart';
import 'package:Talkaboat/widgets/live-chat.widget.dart';
import 'package:Talkaboat/widgets/livecontrolls.widget.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

const int tokenExpireTime = 3600; // Expire time in Seconds.
const bool isTokenExpiring = false; // Set to true when the token is about to expire

class LivestreamScreen extends StatefulWidget {
  const LivestreamScreen({Key? key, required this.escapeWithNav, required this.session, required this.isHost})
      : super(key: key);

  final Function escapeWithNav;
  final LiveSession session;
  final bool isHost;

  @override
  State<LivestreamScreen> createState() => _LivestreamScreenState();
}

class ViewContainer {
  final Widget view;
  final int userId;
  final bool wrap;

  const ViewContainer({required this.view, required this.userId, required this.wrap});
}

const String appId = "c0ad2b8f2be149788fabb9d916f0fbef";

class _LivestreamScreenState extends State<LivestreamScreen> {
  final LiveSessionService _liveService = getIt<LiveSessionService>();
  final UserService userService = getIt<UserService>();

  final focusNode = FocusNode();
  ChatMessageDto? replyMessage;
  ChatMessageDto? editedMessage;

  late StreamSubscription<String> onAddedHostSub;
  bool isChangingState = false;

  late RtcEngine _engine;
  bool _localUserJoined = false;
  final List<int> _remoteUsers = List.empty(growable: true);

  Future<String> getToken(String roomId) async {
    var response = await LiveSessionRepository.getToken(roomId);
    debugPrint(response.data);
    return response.data!;
  }

  Future<void> initAgora() async {
    await [Permission.microphone, Permission.camera].request();
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
      appId: appId,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));
    await _engine.enableAudioVolumeIndication(interval: 200, smooth: 3, reportVad: true);

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          setState(() {
            _localUserJoined = true;
          });
          debugPrint("onJoinChannelSuccess ${connection.channelId} ${connection.localUid}");
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) async {
          debugPrint("onUserJoined ${connection.channelId} ${connection.localUid} $remoteUid");
          setState(() {
            _remoteUsers.add(remoteUid);
          });
          //_userVideoOn[remoteUid] = true;
          //await updateHostsById(remoteUid, false);
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) async {
          debugPrint("onUserOffline $remoteUid $reason");
          setState(() {
            _remoteUsers.remove(remoteUid);
          });
          //_userVideoOn[remoteUid] = false;
          //if (_currentSess != null) {
          //  _currentSess!.hosts.removeWhere((x) => x.userId == remoteUid);
          //}
          //notifyListeners();
        },
        onError: (err, msg) {
          debugPrint("onError $err $msg");
        },
        onLeaveChannel: (con, stats) {
          debugPrint("onLeaveChannel");
          setState(() {
            _remoteUsers.clear();
          });
          //_userVideoOn.clear();
          //notifyListeners();
        },
        onRemoteVideoStateChanged: (connection, remoteUid, state, reason, elapsed) {
          debugPrint("onRemoteVideoStateChanged $remoteUid $state $reason");
        },
        onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
          debugPrint('[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
        },
        onUserEnableVideo: (connection, remoteUid, enabled) {
          debugPrint("onUserEnableVideo $remoteUid $enabled");
          //_userVideoOn[remoteUid] = enabled;
          //notifyListeners();
        },
      ),
    );

    if (_isHost) {
      await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
      await _engine.enableVideo();
      await _engine.startPreview();
      final token = await getToken(widget.session.guid);

      await _engine.joinChannel(
        token: token,
        channelId: widget.session.guid,
        uid: userService.userInfo?.userId ?? 0,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        ),
      );
    } else {
      await _engine.setClientRole(role: ClientRoleType.clientRoleAudience);
      await _engine.enableVideo();
      final token = await getToken(widget.session.guid);

      await _engine.joinChannel(
        token: token,
        channelId: widget.session.guid,
        uid: userService.userInfo?.userId ?? 0,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleAudience,
          channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        ),
      );
    }
  }

  late bool _isHost;

  void promote() async {
    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine.startPreview();
    setState(() {
      _isHost = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _isHost = widget.isHost;
    initAgora();

    /*_liveService.onAddedAsHost.listen((event) async {
      if (event == userService.userInfo!.userName) {
        await _liveService.updateHosts(userService.userInfo!.userName, false);
        isChangingState = true;
        Navigator.of(context).pop();
        widget.escapeWithNav(PageTransition(
          alignment: Alignment.bottomCenter,
          curve: Curves.bounceOut,
          type: PageTransitionType.fade,
          duration: const Duration(milliseconds: 300),
          reverseDuration: const Duration(milliseconds: 200),
          child: LivestreamScreen(
            escapeWithNav: widget.escapeWithNav,
          ),
        ));
      } else {
        await _liveService.updateHosts(null, null);
      }
    });*/
  }

  @override
  void dispose() {
    //Future.microtask(() => _liveService.leave(isChangingState));
    Future.microtask(() async {
      await _engine.leaveChannel();
      _engine.release();
    });
    super.dispose();
  }

  // Create UI with local view and remote view
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: const Color.fromRGBO(15, 23, 41, 1),
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.session.configuration?.roomName ?? ""),
          ),
          bottomNavigationBar: null,
          body: Stack(children: [
            _localUserJoined ? _viewRows() : const Center(child: CircularProgressIndicator()),
            MaterialButton(
              onPressed: () {
                Future.microtask(() => promote());
              },
              child: Text("promote"),
            )
            /*Positioned(
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  verticalDirection: VerticalDirection.up,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LiveControlls(
                      chatId: _liveService.currentSession!.chat!.id,
                      focusNode: focusNode,
                      replyMessage: replyMessage,
                      editedMessage: editedMessage,
                      cancelReplyAndEdit: () {
                        setState(() {
                          replyMessage = null;
                          editedMessage = null;
                        });
                      },
                      audioMuted: false,
                      chatVisible: false,
                      isHost: true,
                      localAudio: false,
                      switchAudio: () {},
                      switchCamera: () {},
                      switchLocalAudio: () {},
                      switchVideo: () {},
                      toggleChat: () {},
                      videoOn: false,
                    ),
                    LiveChat(
                      roomId: _liveService.currentSession!.chat!.id,
                      visible: _liveService.chatVisible,
                      focusNode: focusNode,
                      replyToMessage: (message) {
                        setState(() {
                          editedMessage = null;
                          replyMessage = message;
                        });
                      },
                      editMessage: (message) {
                        setState(() {
                          replyMessage = null;
                          editedMessage = message;
                        });
                      },
                      cancelReplyAndEdit: () {
                        setState(() {
                          replyMessage = null;
                          editedMessage = null;
                        });
                      },
                    )
                  ],
                ),
              ),
            )*/
          ]),
        ),
      ),
    );
  }

  /// Helper function to get list of native views
  List<ViewContainer> _getRenderViews() {
    final List<ViewContainer> list = [];
    debugPrint("isHost ${_isHost}");
    if (_isHost) {
      list.add(
        ViewContainer(
          wrap: true,
          userId: 0,
          view: AgoraVideoView(
            controller: VideoViewController(
              rtcEngine: _engine,
              canvas: const VideoCanvas(uid: 0),
            ),
          ),
        ),
      );
    }
    debugPrint("${_isHost} ${_remoteUsers}");
    for (var uid in _remoteUsers) {
      //if (_liveService.userVideoOn[uid] ?? false) {
      debugPrint("view for $uid ${widget.session.guid}");
      list.add(
        ViewContainer(
          wrap: true,
          userId: uid,
          view: AgoraVideoView(
            controller: VideoViewController.remote(
              rtcEngine: _engine,
              canvas: VideoCanvas(uid: uid),
              connection: RtcConnection(channelId: widget.session.guid),
            ),
          ),
        ),
      );
      //}
    }
    return list;
  }

  /// Video view wrapper
  Widget _videoView(ViewContainer view) {
    if (view.userId == 0) {
      return Expanded(
        child: Container(child: view.view),
      );
    } else if (view.wrap) {
      final user = _liveService.currentSession?.hosts.where((x) => x.userId == view.userId) ??
          [LiveUser(userId: 1, userName: "test")];
      return Expanded(
        child: Stack(
          children: [
            view.view,
            Positioned(
              top: 20,
              left: 20,
              child: Container(
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(10), color: const Color.fromRGBO(29, 40, 58, 0.2)),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Center(
                    child: Text(
                      user.isNotEmpty ? user.first.userName : "",
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Expanded(
        child: Container(
          child: view.view,
        ),
      );
    }
  }

  /// Video view row wrapper
  Widget _expandedVideoRow(List<ViewContainer> views) {
    final wrappedViews = views.map<Widget>(_videoView).toList();
    return Expanded(
      child: Row(
        children: wrappedViews,
      ),
    );
  }

  Widget _viewRows() {
    final views = _getRenderViews();
    switch (views.length) {
      case 1:
        return Column(
          children: <Widget>[_videoView(views[0])],
        );
      case 2:
        return Column(
          children: <Widget>[
            _expandedVideoRow([views[0]]),
            _expandedVideoRow([views[1]])
          ],
        );
      case 3:
        return Column(
          children: <Widget>[_expandedVideoRow(views.sublist(0, 2)), _expandedVideoRow(views.sublist(2, 3))],
        );
      case 4:
        return Column(
          children: <Widget>[_expandedVideoRow(views.sublist(0, 2)), _expandedVideoRow(views.sublist(2, 4))],
        );
      default:
    }
    return Container();
  }
}
