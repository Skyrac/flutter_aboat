import 'dart:async';
import 'package:Talkaboat/services/hubs/hub-service.dart';
import 'package:flutter/foundation.dart';

class LiveHubService extends HubService {
  @override
  String get hubName => "live";

  LiveHubService() : super() {
    connection.on("RemovedAsHost", receivedRemovedAsHost);
    connection.on("AddedAsHost", receivedAddedAsHost);
    connection.on("HostRequest", receivedHostRequest);
    connection.on("LiveSessionEnded", receivedLiveSessionEnded);
    connection.on("UserJoined", (event) {
      debugPrint("UserJoined $event");
    });
    connection.on("UserLeft", (event) {
      debugPrint("UserLeft $event");
    });
  }

  final StreamController<String> onRemovedAsHostController = StreamController.broadcast();
  final StreamController<String> onAddedAsHostController = StreamController.broadcast();
  final StreamController<String> onHostRequestController = StreamController.broadcast();
  final StreamController<String> onLiveSessionEndedController = StreamController.broadcast();

  Stream<String> get onRemovedAsHost => onRemovedAsHostController.stream;
  Stream<String> get onAddedAsHost => onAddedAsHostController.stream;
  Stream<String> get onHostRequest => onHostRequestController.stream;
  Stream<String> get onLiveSessionEnded => onLiveSessionEndedController.stream;

  void receivedRemovedAsHost(List<Object?>? data) {
    if (data != null && data[0] != null) {
      onRemovedAsHostController.add(data[0] as String);
    }
  }

  void receivedAddedAsHost(List<Object?>? data) {
    if (data != null && data[0] != null) {
      onAddedAsHostController.add(data[0] as String);
    }
  }

  void receivedHostRequest(List<Object?>? data) {
    if (data != null && data[0] != null) {
      onHostRequestController.add(data[0] as String);
    }
  }

  void receivedLiveSessionEnded(List<Object?>? data) {
    debugPrint("onLiveSessionEnded $data");
    if (data != null) {
      onLiveSessionEndedController.add("ended");
    }
  }

  Future<void> RequestHost(String roomId) async {
    if (!await checkConnection()) {
      return;
    }
    try {
      final result = await connection.invoke("RequestHostAccess", args: <Object>[roomId]);
      debugPrint("$result");
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future<void> AddHost(String roomId, String username) async {
    if (!await checkConnection()) {
      return;
    }
    try {
      final result = await connection.invoke("AddHost", args: <Object>[roomId, username]);
      debugPrint("$result");
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future<void> RemoveHostAccess(String roomId, String username) async {
    if (!await checkConnection()) {
      return;
    }
    try {
      debugPrint("RemoveHostAccess $roomId $username");
      final result = await connection.invoke("RemoveHostAccess", args: <Object>[roomId, username]);
      debugPrint("RemoveHostAccess $result");
    } catch (e) {
      debugPrint("RemoveHostAccess $e");
    }
  }

  Future<void> Join(String roomId) async {
    if (!await checkConnection()) {
      return;
    }
    try {
      final result = await connection.invoke("Join", args: <Object>[roomId]);
      debugPrint("$result");
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future<void> Leave(String roomId) async {
    if (!await checkConnection()) {
      return;
    }
    try {
      final result = await connection.invoke("Leave", args: <Object>[roomId]);
      debugPrint("$result");
    } catch (e) {
      debugPrint("$e");
    }
  }
}
