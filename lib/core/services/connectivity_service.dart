import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
<<<<<<< HEAD
import 'local_storage_service.dart';

class ConnectivityService {
  static final Connectivity _connectivity = Connectivity();
  static StreamSubscription? _subscription;
  static bool _isOnline = true;

  static bool get isOnline => _isOnline;

  static Future<void> init() async {
    final result = await _connectivity.checkConnectivity();
    _isOnline = (result != ConnectivityResult.none);
    await LocalStorageService.setOnlineStatus(_isOnline);

    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      _isOnline = (result != ConnectivityResult.none);
      LocalStorageService.setOnlineStatus(_isOnline);
      if (_isOnline) {
        syncPendingData();
      }
    });
  }

  static Future<void> syncPendingData() async {
    final pending = LocalStorageService.getPendingListings();
    if (pending.isNotEmpty) {
      // Upload to Firebase when online
    }
  }

  static void dispose() {
    _subscription?.cancel();
=======
import 'package:flutter/foundation.dart';

class ConnectivityService extends ChangeNotifier {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal() {
    _init();
  }

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionStatusController = StreamController<bool>.broadcast();
  
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
  
  void dispose() {
    _connectionStatusController.close();
    super.dispose();
>>>>>>> upstream/master
  }
}
