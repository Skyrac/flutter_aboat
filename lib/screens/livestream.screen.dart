import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/models/live/live-session.model.dart';
import 'package:Talkaboat/services/live/live-session.service.dart';
import 'package:Talkaboat/widgets/live-chat.widget.dart';
import 'package:Talkaboat/widgets/livecontrolls.widget.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';

class LivestreamScreen extends StatefulWidget {
  const LivestreamScreen({Key? key, required this.session, required this.isHost}) : super(key: key);

  final LiveSession session;
  final bool isHost;

  @override
  State<LivestreamScreen> createState() => _LivestreamScreenState();
}

class _LivestreamScreenState extends State<LivestreamScreen> {
  final LiveSessionService _liveService = getIt<LiveSessionService>();

  @override
  void initState() {
    super.initState();
    if (widget.isHost) {
      _liveService.joinAsHost(widget.session.guid, widget.session.configuration!.roomName);
    } else {
      _liveService.joinAsViewer(widget.session.guid, widget.session.configuration!.roomName);
    }
  }

  @override
  void dispose() {
    _liveService.leave();
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
                title: Text(widget.session.configuration!.roomName),
              ),
              bottomNavigationBar: null,
              body: Center(
                child: AnimatedBuilder(
                  animation: _liveService,
                  builder: (context, child) => Stack(children: [
                    _liveService.isJoined ? _viewRows() : const Center(child: CircularProgressIndicator()),
                    Positioned(
                      bottom: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          verticalDirection: VerticalDirection.up,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LiveControlls(roomId: 139), //widget.session.chat!.id),
                            LiveChat(
                              roomId: 139,
                              visible: _liveService.chatVisible,
                            )
                          ],
                        ),
                      ),
                    )
                  ]),
                ),
              ),
            )));
  }

  /// Helper function to get list of native views
  List<Widget> _getRenderViews() {
    final List<StatefulWidget> list = [];
    if (_liveService.isHost) {
      list.add(AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: _liveService.agoraEngine,
          canvas: const VideoCanvas(uid: 0),
        ),
      ));
    }
    for (var uid in _liveService.users) {
      if (_liveService.userVideoOn[uid] ?? false) {
        list.add(AgoraVideoView(
          controller: VideoViewController.remote(
            rtcEngine: _liveService.agoraEngine,
            canvas: VideoCanvas(uid: uid),
            connection: RtcConnection(channelId: widget.session.guid),
          ),
        ));
      }
    }
    return list;
  }

  /// Video view wrapper
  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
  }

  /// Video view row wrapper
  Widget _expandedVideoRow(List<Widget> views) {
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
