import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectionStateService {
  final Connectivity _connectivity = Connectivity();
  bool isConnected = false;
  final _connectionStateController = StreamController<bool>.broadcast();

  ConnectionStateService() {
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      _checkConnection(result);
    });
  }

  Stream<bool> get connectionStateStream => _connectionStateController.stream;

  Future<void> checkInitialConnection() async {
    final initialResult = await _connectivity.checkConnectivity();
    _checkConnection(initialResult);
  }

  void _checkConnection(ConnectivityResult result) {
    if (result == ConnectivityResult.none) {
      if(!isConnected) {
        return;
      }
      isConnected = false;
      _connectionStateController.add(false);
    } else {
      if(isConnected) {
        return;
      }
      isConnected = true;
      _connectionStateController.add(true);
    }
  }

  void dispose() {
    _connectionStateController.close();
  }
}