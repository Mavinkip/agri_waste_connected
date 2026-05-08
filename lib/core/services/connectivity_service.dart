import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'local_storage_service.dart';

class ConnectivityService extends ChangeNotifier {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal() {
    _init();
  }

  final Connectivity _connectivity = Connectivity();
  StreamSubscription? _subscription;
  final StreamController<bool> _connectionStatusController = StreamController<bool>.broadcast();

  bool _isConnected = true;
  bool get isConnected => _isConnected;

  Stream<bool> get connectionStream => _connectionStatusController.stream;

  Future<void> _init() async {
    // Check initial connection
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);

    // Save initial status to local storage
    await LocalStorageService.setOnlineStatus(_isConnected);

    // Listen for changes
    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      _updateConnectionStatus(result);
    });
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    final wasConnected = _isConnected;
    _isConnected = result != ConnectivityResult.none;

    if (wasConnected != _isConnected) {
      // Update stream
      _connectionStatusController.add(_isConnected);

      // Notify listeners (for Provider pattern)
      notifyListeners();

      // Save to local storage
      await LocalStorageService.setOnlineStatus(_isConnected);

      // Debug logging
      if (kDebugMode) {
        print('Connectivity changed: ${_isConnected ? "Online" : "Offline"}');
      }

      // Auto-sync pending data when coming back online
      if (_isConnected) {
        await syncPendingData();
      }
    }
  }

  Future<void> checkInitialConnection() async {
    final ConnectivityResult result = await _connectivity.checkConnectivity();
    _isConnected = result != ConnectivityResult.none;
    _connectionStatusController.add(_isConnected);
    notifyListeners();
  }

  Future<bool> checkConnection() async {
    final ConnectivityResult result = await _connectivity.checkConnectivity();
    _isConnected = result != ConnectivityResult.none;
    _connectionStatusController.add(_isConnected);
    notifyListeners();
    return _isConnected;
  }

  Future<void> syncPendingData() async {
    final pending = LocalStorageService.getPendingListings();
    if (pending.isNotEmpty) {
      if (kDebugMode) {
        print('Syncing ${pending.length} pending items...');
      }
      // TODO: Upload to Firebase when online
      // This would typically call a repository method to sync
    }
  }

  void dispose() {
    _subscription?.cancel();
    _connectionStatusController.close();
    super.dispose();
  }
}