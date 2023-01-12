import 'package:Talkaboat/models/live/live-session-chat.model.dart';
import 'package:Talkaboat/models/live/live-user.model.dart';

import 'live-session-configuration.model.dart';

class LiveSession {
  late String guid;
  late List<LiveUser> hosts;
  late int superHost;
  late String started;
  late LiveSessionConfiguration? configuration;
  late LiveSessionChat? chat;
  late List<LiveUser> users;

  LiveSession(
      {required this.guid,
      required this.hosts,
      required this.superHost,
      required this.started,
      required this.configuration,
      required this.users,
      this.chat});

  LiveSession.fromJson(Map<String, dynamic> json) {
    guid = json['guid'];
    hosts = List<LiveUser>.from(json["hosts"].map((x) => LiveUser.fromJson(x)));
    superHost = json['superHost'];
    started = json['started'];
    configuration = (json['configuration'] != null ? LiveSessionConfiguration.fromJson(json['configuration']) : null)!;
    chat = (json['chat'] != null ? LiveSessionChat.fromJson(json['chat']) : null)!;
    users = List<LiveUser>.from(json["users"].map((x) => LiveUser.fromJson(x)));
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['guid'] = guid;
    data['hosts'] = hosts.map((x) => x.toJson()).toList();
    data['superHost'] = superHost;
    data['started'] = started;
    if (configuration != null) {
      data['configuration'] = configuration!.toJson();
    }
    if (chat != null) {
      data['chat'] = chat!.toJson();
    }
    data['users'] = users.map((x) => x.toJson()).toList();
    return data;
  }
}
