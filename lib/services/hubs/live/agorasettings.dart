import 'package:Talkaboat/injection/injector.dart';
import 'package:Talkaboat/services/hubs/live/live-session.service.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/foundation.dart';

enum Camera { front, back }

class AgoraSettings extends ChangeNotifier {
  static const String appId = "c0ad2b8f2be149788fabb9d916f0fbef";

  Camera _camera = Camera.front;
  bool _chatVisible = true;
  bool _videoOn = true;
  bool _localAudio = true;
  bool _audioMuted = false;
  Camera get camera => _camera;
  bool get chatVisible => _chatVisible;
  bool get videoOn => _videoOn;
  bool get localAudio => _localAudio;
  bool get audioMuted => _audioMuted;

  late RtcEngine _agoraEngine;
  RtcEngine get agoraEngine => _agoraEngine;

  AgoraSettings({RtcEngine? engine}) {
    if (engine != null) {
      _agoraEngine = engine;
    }
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

  final LiveSessionService live = getIt<LiveSessionService>();

  switchAudio() async {
    _audioMuted = !_audioMuted;

    for (var user in live.remoteUsers) {
      agoraEngine.muteRemoteAudioStream(uid: user, mute: _audioMuted);
    }
    notifyListeners();
  }
}
