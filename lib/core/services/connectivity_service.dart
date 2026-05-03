import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService extends ChangeNotifier {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal() {
    _init();
  }

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionStatusController =
      StreamController<bool>.broadcast();

  bool _isConnected = true;
  bool get isConnected => _isConnected;

  Stream<bool> get connectionStream => _connectionStatusController.stream;

  void _init() {
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      _updateConnectionStatus(result);
    });
    _checkInitialConnection();
  }

  Future<void> _checkInitialConnection() async {
    final ConnectivityResult result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    final wasConnected = _isConnected;
    _isConnected = result != ConnectivityResult.none;

    if (wasConnected != _isConnected) {
      _connectionStatusController.add(_isConnected);
      notifyListeners();

      if (kDebugMode) {
        print('Connectivity changed: ${_isConnected ? "Online" : "Offline"}');
      }
    }
  }

  Future<bool> checkConnection() async {
    final ConnectivityResult result = await _connectivity.checkConnectivity();
    _isConnected = result != ConnectivityResult.none;
    return _isConnected;
  }

  @override
  void dispose() {
    _connectionStatusController.close();
    super.dispose();
  }
}
