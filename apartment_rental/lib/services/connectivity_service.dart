import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  final StreamController<bool> _controller = StreamController<bool>.broadcast();

  Stream<bool> get isConnected => _controller.stream;

  bool _connected = false;
  bool get connected => _connected;

  Future<void> init() async {
    // Check initial connectivity
    final results = await _connectivity.checkConnectivity();
    _connected = _isConnected(results);
    _controller.add(_connected);

    // Listen for connectivity changes
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      final wasConnected = _connected;
      _connected = _isConnected(results);
      
      if (wasConnected != _connected) {
        debugPrint('Connectivity changed: ${_connected ? "ONLINE" : "OFFLINE"}');
        _controller.add(_connected);
      }
    });
  }

  bool _isConnected(List<ConnectivityResult> results) {
    // Connected if we have any connectivity except none
    return results.isNotEmpty && 
           !results.every((result) => result == ConnectivityResult.none);
  }

  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}


