// lib/shared/services/offline_sync_repository.dart
import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../core/network/api_client.dart';
import '../models/waste_listing_model.dart';

class OfflineSyncRepository {
  static final OfflineSyncRepository _instance = OfflineSyncRepository._internal();
  factory OfflineSyncRepository() => _instance;
  OfflineSyncRepository._internal();
  
  Database? _database;
  final ApiClient _apiClient = ApiClient();
  final StreamController<SyncStatus> _syncStatusController = StreamController.broadcast();
  Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;
  
  SyncStatus _currentStatus = SyncStatus.idle;
  SyncStatus get currentStatus => _currentStatus;
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'agri_waste.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }
  
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE pending_operations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        operation_type TEXT NOT NULL,
        endpoint TEXT NOT NULL,
        data TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        retry_count INTEGER DEFAULT 0,
        last_retry INTEGER
      )
    ''');
    
    await db.execute('''
      CREATE TABLE local_listings (
        id TEXT PRIMARY KEY,
        farmer_id TEXT NOT NULL,
        waste_type TEXT NOT NULL,
        estimated_quantity REAL NOT NULL,
        pickup_lat TEXT NOT NULL,
        pickup_lng TEXT NOT NULL,
        pickup_address TEXT NOT NULL,
        pickup_type TEXT NOT NULL,
        status TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        synced INTEGER DEFAULT 0,
        last_updated INTEGER NOT NULL
      )
    ''');
    
    await db.execute('''
      CREATE TABLE user_profile (
        id TEXT PRIMARY KEY,
        phone_number TEXT NOT NULL,
        full_name TEXT NOT NULL,
        role TEXT NOT NULL,
        data TEXT NOT NULL,
        last_sync INTEGER NOT NULL
      )
    ''');
    
    await db.execute('''
      CREATE TABLE sync_metadata (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
    
    await db.execute('CREATE INDEX idx_pending_created ON pending_operations(created_at)');
    await db.execute('CREATE INDEX idx_listings_synced ON local_listings(synced)');
  }
  
  Future<void> queueOperation({
    required String operationType,
    required String endpoint,
    required Map<String, dynamic> data,
  }) async {
    final db = await database;
    await db.insert('pending_operations', {
      'operation_type': operationType,
      'endpoint': endpoint,
      'data': data.toString(),
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
  }
  
  Future<List<Map<String, dynamic>>> getPendingOperations() async {
    final db = await database;
    return await db.query(
      'pending_operations',
      orderBy: 'created_at ASC',
    );
  }
  
  Future<void> removeOperation(int id) async {
    final db = await database;
    await db.delete('pending_operations', where: 'id = ?', whereArgs: [id]);
  }
  
  Future<void> updateRetryCount(int id) async {
    final db = await database;
    await db.update(
      'pending_operations',
      {
        'retry_count': db.rawUpdate('retry_count + 1'),
        'last_retry': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  Future<void> saveListingLocally(WasteListingModel listing) async {
    final db = await database;
    await db.insert(
      'local_listings',
      {
        'id': listing.id,
        'farmer_id': listing.farmerId,
        'waste_type': listing.wasteType.toString(),
        'estimated_quantity': listing.estimatedQuantity,
        'pickup_lat': listing.pickupLat,
        'pickup_lng': listing.pickupLng,
        'pickup_address': listing.pickupAddress,
        'pickup_type': listing.pickupType.toString(),
        'status': listing.status.toString(),
        'created_at': listing.createdAt.millisecondsSinceEpoch,
        'synced': 1,
        'last_updated': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  Future<List<WasteListingModel>> getLocalListings({bool? synced}) async {
    final db = await database;
    String where = '';
    List<dynamic> whereArgs = [];
    
    if (synced != null) {
      where = 'synced = ?';
      whereArgs = [synced ? 1 : 0];
    }
    
    final results = await db.query(
      'local_listings',
      where: where,
      whereArgs: whereArgs,
    );
    
    return results.map((result) {
      return WasteListingModel(
        id: result['id'] as String,
        farmerId: result['farmer_id'] as String,
        farmerName: '',
        wasteType: _parseWasteType(result['waste_type'] as String),
        estimatedQuantity: result['estimated_quantity'] as double,
        pickupLat: result['pickup_lat'] as String,
        pickupLng: result['pickup_lng'] as String,
        pickupAddress: result['pickup_address'] as String,
        pickupType: _parsePickupType(result['pickup_type'] as String),
        status: _parseListingStatus(result['status'] as String),
        createdAt: DateTime.fromMillisecondsSinceEpoch(result['created_at'] as int),
        isPhotoRequired: true,
      );
    }).toList();
  }
  
  Future<SyncResult> syncWithServer() async {
    if (_currentStatus == SyncStatus.syncing) {
      return SyncResult.failure('Sync already in progress');
    }
    
    _currentStatus = SyncStatus.syncing;
    _syncStatusController.add(_currentStatus);
    
    final results = <SyncOperationResult>[];
    final operations = await getPendingOperations();
    
    for (var operation in operations) {
      try {
        final id = operation['id'] as int;
        final endpoint = operation['endpoint'] as String;
        final data = operation['data'] as String;
        final Map<String, dynamic> jsonData = {};
        
        await _executeOperation(operation['operation_type'] as String, endpoint, jsonData);
        
        await removeOperation(id);
        results.add(SyncOperationResult.success(id));
      } catch (e) {
        await updateRetryCount(operation['id'] as int);
        results.add(SyncOperationResult.failure(operation['id'] as int, e.toString()));
        
        final retryCount = operation['retry_count'] as int;
        if (retryCount >= 5) {
          await removeOperation(operation['id'] as int);
          results.add(SyncOperationResult.failure(operation['id'] as int, 'Max retries exceeded'));
        }
      }
    }
    
    _currentStatus = SyncStatus.idle;
    _syncStatusController.add(_currentStatus);
    
    final successCount = results.where((r) => r.success).length;
    final failureCount = results.where((r) => !r.success).length;
    
    return SyncResult.completed(
      total: operations.length,
      success: successCount,
      failure: failureCount,
      results: results,
    );
  }
  
  Future<void> _executeOperation(String type, String endpoint, Map<String, dynamic> data) async {
    switch (type.toLowerCase()) {
      case 'post':
        await _apiClient.post(endpoint, data);
        break;
      case 'put':
        await _apiClient.put(endpoint, data);
        break;
      case 'patch':
        await _apiClient.patch(endpoint, data);
        break;
      case 'delete':
        await _apiClient.delete(endpoint);
        break;
      default:
        throw Exception('Unknown operation type: $type');
    }
  }
  
  WasteType _parseWasteType(String type) {
    if (type.contains('cropResidue')) return WasteType.cropResidue;
    if (type.contains('fruitWaste')) return WasteType.fruitWaste;
    if (type.contains('vegetableWaste')) return WasteType.vegetableWaste;
    if (type.contains('livestockManure')) return WasteType.livestockManure;
    if (type.contains('coffeeHusks')) return WasteType.coffeeHusks;
    if (type.contains('riceHulls')) return WasteType.riceHulls;
    if (type.contains('cornStover')) return WasteType.cornStover;
    return WasteType.other;
  }
  
  PickupType _parsePickupType(String type) {
    return type.contains('routine') ? PickupType.routine : PickupType.manual;
  }
  
  ListingStatus _parseListingStatus(String status) {
    if (status.contains('pending')) return ListingStatus.pending;
    if (status.contains('assigned')) return ListingStatus.assigned;
    if (status.contains('inTransit')) return ListingStatus.inTransit;
    if (status.contains('completed')) return ListingStatus.completed;
    return ListingStatus.pending;
  }
  
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('pending_operations');
    await db.delete('local_listings');
    await db.delete('user_profile');
    await db.delete('sync_metadata');
  }
  
  void dispose() {
    _syncStatusController.close();
    _database?.close();
  }
}

enum SyncStatus {
  idle,
  syncing,
  error,
}

class SyncResult {
  final bool success;
  final String? errorMessage;
  final int? total;
  final int? successCount;
  final int? failureCount;
  final List<SyncOperationResult>? results;
  
  SyncResult._({this.success = true, this.errorMessage, this.total, this.successCount, this.failureCount, this.results});
  
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
  
  factory SyncOperationResult.success(int id) => SyncOperationResult(id, true);
  factory SyncOperationResult.failure(int id, String error) => SyncOperationResult(id, false, error);
}
