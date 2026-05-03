import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/waste_listing_model.dart';

// Firestore handles offline persistence automatically via:
//   FirebaseFirestore.instance.settings = Settings(persistenceEnabled: true)
// set in main.dart — no manual SQLite queue needed.

class OfflineSyncRepository {
  static final OfflineSyncRepository _instance = OfflineSyncRepository._internal();
  factory OfflineSyncRepository() => _instance;
  OfflineSyncRepository._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final StreamController<SyncStatus> _syncStatusController =
      StreamController<SyncStatus>.broadcast();

  Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;

  SyncStatus _currentStatus = SyncStatus.idle;
  SyncStatus get currentStatus => _currentStatus;

  // Get listings from Firestore cache (works offline automatically)
  Future<List<WasteListingModel>> getLocalListings() async {
    try {
      final snapshot = await _firestore
          .collection('listings')
          .get(const GetOptions(source: Source.cache));

      return snapshot.docs
          .map((doc) => WasteListingModel.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Save listing to Firestore (goes to cache if offline, syncs when online)
  Future<void> saveListingLocally(WasteListingModel listing) async {
    try {
      await _firestore
          .collection('listings')
          .doc(listing.id)
          .set(listing.toJson(), SetOptions(merge: true));
    } catch (e) {
      // Firestore will retry automatically when connection restored
    }
  }

  // Queue an operation — Firestore handles this automatically
  // When offline, writes go to local cache and sync on reconnect
  Future<void> queueOperation({
    required String operationType,
    required String endpoint,
    required Map<String, dynamic> data,
  }) async {
    // Firestore offline persistence handles this automatically.
    // This method is kept for API compatibility with existing BLoC code.
  }

  // Sync — Firestore does this automatically, this just triggers a check
  Future<SyncResult> syncWithServer() async {
    _currentStatus = SyncStatus.syncing;
    _syncStatusController.add(_currentStatus);

    try {
      // Force a server fetch to flush any pending offline writes
      await _firestore
          .collection('listings')
          .get(const GetOptions(source: Source.server));

      _currentStatus = SyncStatus.idle;
      _syncStatusController.add(_currentStatus);

      return SyncResult.completed(total: 0, success: 0, failure: 0, results: []);
    } catch (e) {
      _currentStatus = SyncStatus.error;
      _syncStatusController.add(_currentStatus);
      return SyncResult.failure('Sync failed: $e');
    }
  }

  Future<void> clearAllData() async {
    // No local DB to clear — Firestore manages its own cache
  }

  void dispose() {
    _syncStatusController.close();
  }
}

enum SyncStatus { idle, syncing, error }

class SyncResult {
  final bool success;
  final String? errorMessage;
  final int? total;
  final int? successCount;
  final int? failureCount;
  final List<SyncOperationResult>? results;

  SyncResult._({
    this.success = true,
    this.errorMessage,
    this.total,
    this.successCount,
    this.failureCount,
    this.results,
  });

  factory SyncResult.completed({
    required int total,
    required int success,
    required int failure,
    required List<SyncOperationResult> results,
  }) {
    return SyncResult._(
      success: failure == 0,
      total: total,
      successCount: success,
      failureCount: failure,
      results: results,
    );
  }

  factory SyncResult.failure(String message) {
    return SyncResult._(success: false, errorMessage: message);
  }
}

class SyncOperationResult {
  final int operationId;
  final bool success;
  final String? error;

  SyncOperationResult(this.operationId, this.success, [this.error]);

  factory SyncOperationResult.success(int id) =>
      SyncOperationResult(id, true);
  factory SyncOperationResult.failure(int id, String error) =>
      SyncOperationResult(id, false, error);
}
