import 'live-session-configuration.model.dart';

class LiveSession {
  late String guid;
  late List<int> hosts;
  late int superHost;
  late String started;
  late LiveSessionConfiguration configuration;

  LiveSession(
      {
        required this.guid,
        required this.hosts,
        required this.superHost,
        required this.started,
        required this.configuration});

  LiveSession.fromJson(Map<String, dynamic> json) {
    guid = json['guid'];
    hosts = json['hosts'].cast<int>();
    superHost = json['superHost'];
    started = json['started'];
    configuration = (json['configuration'] != null
        ? LiveSessionConfiguration.fromJson(json['configuration'])
        : null)!;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['guid'] = this.guid;
    data['hosts'] = this.hosts;
    data['superHost'] = this.superHost;
    data['started'] = this.started;
    if (this.configuration != null) {
      data['configuration'] = this.configuration.toJson();
    }
    return data;
  }
}