import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
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
  }
}
