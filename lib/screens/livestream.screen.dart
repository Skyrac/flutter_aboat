import 'dart:async';

import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/models/chat/chat-dtos.dart';
import 'package:Talkaboat/services/hubs/live/live-session.service.dart';
import 'package:Talkaboat/services/user/user.service.dart';
import 'package:Talkaboat/widgets/live-chat.widget.dart';
import 'package:Talkaboat/widgets/livecontrolls.widget.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';

class LivestreamScreen extends StatefulWidget {
  const LivestreamScreen({Key? key, required this.escapeWithNav}) : super(key: key);

  final Function escapeWithNav;

  @override
  State<LivestreamScreen> createState() => _LivestreamScreenState();
}

class ViewContainer {
  final Widget view;
  final int userId;
  final bool wrap;

  const ViewContainer({required this.view, required this.userId, required this.wrap});
}

class _LivestreamScreenState extends State<LivestreamScreen> {
  final LiveSessionService _liveService = getIt<LiveSessionService>();
  final UserService userService = getIt<UserService>();

  final focusNode = FocusNode();
  ChatMessageDto? replyMessage;
  ChatMessageDto? editedMessage;

  late StreamSubscription<String> onAddedHostSub;
  bool isChangingState = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (_liveService.currentSession != null) {
        if (_liveService.isHost) {
          _liveService.joinAsHost(_liveService.currentSession!.guid, _liveService.currentSession!.configuration!.roomName);
        } else {
          _liveService.joinAsViewer(_liveService.currentSession!.guid, _liveService.currentSession!.configuration!.roomName);
        }
      }
    });

    _liveService.onAddedAsHost.listen((event) async {
      /*if (event == userService.userInfo!.userName) {
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
      }*/
    });
  }

  @override
  void dispose() {
    Future.microtask(() => _liveService.leave(isChangingState));
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
            title: Text(_liveService.currentSession?.configuration!.roomName ?? ""),
          ),
          bottomNavigationBar: null,
          body: AnimatedBuilder(
            animation: _liveService,
            builder: (context, child) => Stack(children: [
              _liveService.isJoined ? _viewRows() : const Center(child: CircularProgressIndicator()),
              Positioned(
                bottom: 0,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    verticalDirection: VerticalDirection.up,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LiveControlls(
                        liveSession: _liveService.currentSession!,
                        focusNode: focusNode,
                        replyMessage: replyMessage,
                        editedMessage: editedMessage,
                        cancelReplyAndEdit: () {
                          setState(() {
                            replyMessage = null;
                            editedMessage = null;
                          });
                        },
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
              )
            ]),
          ),
        ),
      ),
    );
  }

  /// Helper function to get list of native views
  List<ViewContainer> _getRenderViews() {
    final List<ViewContainer> list = [];
    debugPrint("isHost ${_liveService.isHost}");
    if (_liveService.isHost) {
      list.add(
        ViewContainer(
          wrap: true,
          userId: 0,
          view: AgoraVideoView(
            controller: VideoViewController(
              rtcEngine: _liveService.agoraEngine,
              canvas: const VideoCanvas(uid: 0),
            ),
          ),
        ),
      );
    }
    debugPrint("${_liveService.isHost} ${_liveService.users}");
    for (var uid in _liveService.users) {
      if (_liveService.userVideoOn[uid] ?? false) {
        debugPrint("view for $uid ${_liveService.currentSession!.guid}");
        list.add(
          ViewContainer(
            wrap: true,
            userId: uid,
            view: AgoraVideoView(
              controller: VideoViewController.remote(
                rtcEngine: _liveService.agoraEngine,
                canvas: VideoCanvas(uid: uid),
                connection: RtcConnection(channelId: _liveService.currentSession!.guid),
              ),
            ),
          ),
        );
      }
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
      final user = _liveService.currentSession!.hosts.where((x) => x.userId == view.userId);
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
