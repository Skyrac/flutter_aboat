import 'package:Talkaboat/models/live/live-session-chat.model.dart';

import 'live-session-configuration.model.dart';

class LiveSession {
  late String guid;
  late List<int> hosts;
  late int superHost;
  late String started;
  late LiveSessionConfiguration? configuration;
  late LiveSessionChat? chat;

  LiveSession(
      {required this.guid,
      required this.hosts,
      required this.superHost,
      required this.started,
      required this.configuration,
      this.chat});

  LiveSession.fromJson(Map<String, dynamic> json) {
    guid = json['guid'];
    hosts = json['hosts'].cast<int>();
    superHost = json['superHost'];
    started = json['started'];
    configuration = (json['configuration'] != null ? LiveSessionConfiguration.fromJson(json['configuration']) : null)!;
    chat = (json['chat'] != null ? LiveSessionChat.fromJson(json['chat']) : null)!;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['guid'] = guid;
    data['hosts'] = hosts;
    data['superHost'] = superHost;
    data['started'] = started;
    if (configuration != null) {
      data['configuration'] = configuration!.toJson();
    }
    if (chat != null) {
      data['chat'] = chat!.toJson();
    }
    return data;
  }
}
