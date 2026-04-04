import '../../../../core/network/api_client.dart';
import '../../../../shared/models/waste_listing_model.dart';
import '../../../../shared/services/offline_sync_repository.dart';

class CollectionRepository {
  final ApiClient _apiClient;
  final OfflineSyncRepository _offlineSync;
  
  CollectionRepository({
    ApiClient? apiClient,
    OfflineSyncRepository? offlineSync,
  }) : _apiClient = apiClient ?? ApiClient(),
       _offlineSync = offlineSync ?? OfflineSyncRepository();
  
  // Get assigned collections for driver
  Future<List<WasteListingModel>> getAssignedCollections({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      String url = '/driver/collections?page=$page&limit=$limit';
      if (status != null) {
        url += '&status=$status';
      }
      
      final response = await _apiClient.get(url);
      final List<dynamic> data = response['data'];
      return data.map((json) => WasteListingModel.fromJson(json)).toList();
    } catch (e) {
      // Return cached collections if offline
      if (e is ApiException && e.statusCode == 0) {
        return await _offlineSync.getLocalListings();
      }
      return [];
    }
  }
  
  // Get single collection details
  Future<WasteListingModel?> getCollectionDetails(String collectionId) async {
    try {
      final response = await _apiClient.get('/driver/collections/$collectionId');
      return WasteListingModel.fromJson(response['data']);
    } catch (e) {
      return null;
    }
  }
  
  // Mark arrival at farm
  Future<bool> markArrival(String collectionId, {String? notes}) async {
    try {
      await _apiClient.post('/driver/collections/$collectionId/arrive', {
        'notes': notes,
        'arrived_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      // Queue for offline sync
      if (e is ApiException && e.statusCode == 0) {
        await _offlineSync.queueOperation(
          operationType: 'POST',
          endpoint: '/driver/collections/$collectionId/arrive',
          data: {'notes': notes},
        );
      }
      return false;
    }
  }
  
  // Weigh waste (FINAL weight - determines payout)
  Future<bool> recordWeight({
    required String collectionId,
    required double actualWeight,
    String? notes,
  }) async {
    try {
      await _apiClient.post('/driver/collections/$collectionId/weigh', {
        'actual_weight': actualWeight,
        'notes': notes,
        'weighed_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      if (e is ApiException && e.statusCode == 0) {
        await _offlineSync.queueOperation(
          operationType: 'POST',
          endpoint: '/driver/collections/$collectionId/weigh',
          data: {'actual_weight': actualWeight, 'notes': notes},
        );
      }
      return false;
    }
  }
  
  // Quality check and rating
  Future<bool> submitQualityCheck({
    required String collectionId,
    required int rating, // 1-5 stars
    required String qualityNotes,
    List<String>? photoUrls,
  }) async {
    try {
      await _apiClient.post('/driver/collections/$collectionId/quality', {
        'rating': rating,
        'quality_notes': qualityNotes,
        'photos': photoUrls,
        'checked_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      if (e is ApiException && e.statusCode == 0) {
        await _offlineSync.queueOperation(
          operationType: 'POST',
          endpoint: '/driver/collections/$collectionId/quality',
          data: {'rating': rating, 'quality_notes': qualityNotes},
        );
      }
      return false;
    }
  }
  
  // Confirm payment completion
  Future<bool> confirmPayment(String collectionId) async {
    try {
      await _apiClient.post('/driver/collections/$collectionId/payment-confirm', {
        'confirmed_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Complete collection
  Future<bool> completeCollection(String collectionId) async {
    try {
      await _apiClient.post('/driver/collections/$collectionId/complete', {
        'completed_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      if (e is ApiException && e.statusCode == 0) {
        await _offlineSync.queueOperation(
          operationType: 'POST',
          endpoint: '/driver/collections/$collectionId/complete',
          data: {},
        );
      }
      return false;
    }
  }
  
  // Routine evaluation (for routine pickups)
  Future<RoutineEvaluationResult> evaluateRoutine({
    required String collectionId,
    required int qualityRating,
    required bool shouldContinue,
    String? notes,
  }) async {
    try {
      final response = await _apiClient.post('/driver/collections/$collectionId/routine-evaluate', {
        'quality_rating': qualityRating,
        'should_continue': shouldContinue,
        'notes': notes,
        'evaluated_at': DateTime.now().toIso8601String(),
      });
      
      return RoutineEvaluationResult.fromJson(response['data']);
    } catch (e) {
      return RoutineEvaluationResult.failure('Failed to submit evaluation');
    }
  }
  
  // Get driver dashboard stats
  Future<DriverDashboardStats> getDashboardStats() async {
    try {
      final response = await _apiClient.get('/driver/dashboard');
      return DriverDashboardStats.fromJson(response['data']);
    } catch (e) {
      return DriverDashboardStats.empty();
    }
  }
  
  // Update driver availability
  Future<bool> updateAvailability(bool isAvailable) async {
    try {
      await _apiClient.put('/driver/availability', {
        'is_available': isAvailable,
        'updated_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Get today's schedule
  Future<List<WasteListingModel>> getTodaySchedule() async {
    try {
      final response = await _apiClient.get('/driver/schedule/today');
      final List<dynamic> data = response['data'];
      return data.map((json) => WasteListingModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
  
  // Upload collection photo
  Future<String?> uploadCollectionPhoto(String collectionId, String photoPath) async {
    // Implementation would use multipart upload
    // This is a placeholder for the actual implementation
    try {
      // Would use _apiClient.postMultipart()
      return 'uploaded_photo_url';
    } catch (e) {
      return null;
    }
  }
  
  // Sync offline collections when back online
  Future<void> syncOfflineCollections() async {
    await _offlineSync.syncWithServer();
  }
}

// Driver Dashboard Stats Model
class DriverDashboardStats {
  final int assignedCollections;
  final int completedToday;
  final int totalCompleted;
  final double totalWasteCollected;
  final double averageRating;
  final int pendingEvaluations;
  
  DriverDashboardStats({
    required this.assignedCollections,
    required this.completedToday,
    required this.totalCompleted,
    required this.totalWasteCollected,
    required this.averageRating,
    required this.pendingEvaluations,
  });
  
  factory DriverDashboardStats.fromJson(Map<String, dynamic> json) {
    return DriverDashboardStats(
      assignedCollections: json['assigned_collections'] ?? 0,
      completedToday: json['completed_today'] ?? 0,
      totalCompleted: json['total_completed'] ?? 0,
      totalWasteCollected: (json['total_waste_collected'] ?? 0).toDouble(),
      averageRating: (json['average_rating'] ?? 0).toDouble(),
      pendingEvaluations: json['pending_evaluations'] ?? 0,
    );
  }
  
  factory DriverDashboardStats.empty() {
    return DriverDashboardStats(
      assignedCollections: 0,
      completedToday: 0,
      totalCompleted: 0,
      totalWasteCollected: 0,
      averageRating: 0,
      pendingEvaluations: 0,
    );
  }
}

// Routine Evaluation Result Model
class RoutineEvaluationResult {
  final bool success;
  final String? message;
  final bool? shouldContinue;
  final double? updatedConsistencyScore;
  
  RoutineEvaluationResult({
    required this.success,
    this.message,
    this.shouldContinue,
    this.updatedConsistencyScore,
  });
  
  factory RoutineEvaluationResult.fromJson(Map<String, dynamic> json) {
    return RoutineEvaluationResult(
      success: true,
      message: json['message'],
      shouldContinue: json['should_continue'],
      updatedConsistencyScore: (json['updated_consistency_score'] ?? 0).toDouble(),
    );
  }
  
  factory RoutineEvaluationResult.failure(String message) {
    return RoutineEvaluationResult(
      success: false,
      message: message,
    );
  }
}
