import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

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
    await _checkConnection(initialResult);
  }

  Future<void> _checkConnection(ConnectivityResult result) async {
    if (result == ConnectivityResult.none) {
      if(!isConnected) {
        return;
      }
      isConnected = false;
    } else {
      if(!await _isLatencyAcceptable()) {
        if(!isConnected) {
          return;
        }
        isConnected = false;
      } else {
        if (isConnected) {
          return;
        }
        isConnected = true;
      }
    }

    _connectionStateController.add(isConnected);
  }

  Future<bool> _isLatencyAcceptable() async {
    return true;
    final String ipAddress = '8.8.8.8'; // Google Public DNS server
    final ping = null;//Ping(ipAddress, count: 3);

    try {
      final List<double> latencies = [];
      await for (dynamic pingData in ping.stream) {
        if (pingData.response != null) {
          latencies.add(pingData.response!.time?.inMilliseconds.toDouble() ?? 500);
        }
      }

      if (latencies.isNotEmpty) {
        final double averageLatency = latencies.reduce((a, b) => a + b) / latencies.length;
        // Set a threshold for the latency (e.g., 200ms)
        if (averageLatency < 200) {
          return true;
        }
      }
    } catch (e) {
      // Error during the latency test
    }

    return false;
  }

  void dispose() {
    _connectionStateController.close();
  }
}