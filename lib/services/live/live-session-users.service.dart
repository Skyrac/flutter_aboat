import 'dart:convert';

import 'package:Talkaboat/models/live/user-join-request.model.dart';
import 'package:flutter/foundation.dart';

class LiveSessionUserService extends ChangeNotifier {
  LiveSessionUserService() : super();

  final List<UserJoinRequest> joinRequests = List.empty(growable: true);
  final decoder = const Utf8Decoder(allowMalformed: true);

  void onUserJoinRequest(int remoteUid, Uint8List data, int length) {
    var username = decoder.convert(data);
  }

  void AcceptUserJoinRequest() {}

  void RejectUserJoinRequest() {}
}
