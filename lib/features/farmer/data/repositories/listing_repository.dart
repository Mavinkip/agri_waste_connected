import '../../../../core/network/api_client.dart';
import '../../../../shared/models/waste_listing_model.dart';
import '../../../../shared/services/offline_sync_repository.dart';
class ListingRepository {
  final ApiClient _apiClient;
  final OfflineSyncRepository _offlineSync;
  
  ListingRepository({
    ApiClient? apiClient,
    OfflineSyncRepository? offlineSync,
  }) : _apiClient = apiClient ?? ApiClient(),
       _offlineSync = offlineSync ?? OfflineSyncRepository();
  
  // Create new waste listing
  Future<WasteListingModel> createListing({
    required WasteType wasteType,
    required double estimatedQuantity,
    required String pickupLat,
    required String pickupLng,
    required String pickupAddress,
    required PickupType pickupType,
    String? photos,
    String? notes,
    bool isPhotoRequired = true,
  }) async {
    try {
      final response = await _apiClient.post('/listings', {
        'waste_type': wasteType.toString().split('.').last,
        'estimated_quantity': estimatedQuantity,
        'pickup_lat': pickupLat,
        'pickup_lng': pickupLng,
        'pickup_address': pickupAddress,
        'pickup_type': pickupType.toString().split('.').last,
        'photos': photos,
        'notes': notes,
        'is_photo_required': isPhotoRequired,
      });
      
      final listing = WasteListingModel.fromJson(response['data']);
      
      // Save locally for offline access
      await _offlineSync.saveListingLocally(listing);
      
      return listing;
    } catch (e) {
      // Queue for offline sync if network error
      if (e is ApiException && e.statusCode == 0) {
        await _offlineSync.queueOperation(
          operationType: 'POST',
          endpoint: '/listings',
          data: {
            'waste_type': wasteType.toString(),
            'estimated_quantity': estimatedQuantity,
            'pickup_lat': pickupLat,
            'pickup_lng': pickupLng,
            'pickup_address': pickupAddress,
            'pickup_type': pickupType.toString(),
            'photos': photos,
            'notes': notes,
          },
        );
      }
      rethrow;
    }
  }
  
  // Get farmer's listings
  Future<List<WasteListingModel>> getFarmerListings({
    ListingStatus? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      String url = '/farmer/listings?page=$page&limit=$limit';
      if (status != null) {
        url += '&status=${status.toString().split('.').last}';
      }
      
      final response = await _apiClient.get(url);
      final List<dynamic> data = response['data'];
      return data.map((json) => WasteListingModel.fromJson(json)).toList();
    } catch (e) {
      // Return local cached listings if offline
      if (e is ApiException && e.statusCode == 0) {
        return await _offlineSync.getLocalListings();
      }
      return [];
    }
  }
  
  // Get single listing details
  Future<WasteListingModel?> getListing(String listingId) async {
    try {
      final response = await _apiClient.get('/listings/$listingId');
      return WasteListingModel.fromJson(response['data']);
    } catch (e) {
      return null;
    }
  }
  
  // Update listing (only allowed for pending status)
  Future<WasteListingModel?> updateListing(
    String listingId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await _apiClient.patch('/listings/$listingId', updates);
      return WasteListingModel.fromJson(response['data']);
    } catch (e) {
      return null;
    }
  }
  
  // Cancel listing
  Future<bool> cancelListing(String listingId) async {
    try {
      await _apiClient.post('/listings/$listingId/cancel', {});
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Get active listings count
  Future<int> getActiveListingsCount() async {
    try {
      final response = await _apiClient.get('/farmer/listings/active/count');
      return response['count'] ?? 0;
    } catch (e) {
      return 0;
    }
  }
  
  // Get listing statistics
  Future<ListingStatistics> getListingStatistics() async {
    try {
      final response = await _apiClient.get('/farmer/listings/statistics');
      return ListingStatistics.fromJson(response['data']);
    } catch (e) {
      return ListingStatistics.empty();
    }
  }
  
  // Upload listing photos
  Future<List<String>> uploadPhotos(List<String> photoPaths) async {
    // This would use multipart upload
    // Implementation depends on your image picker solution
    return [];
  }
}

// Listing Statistics Model
class ListingStatistics {
  final int totalListings;
  final int completedListings;
  final int pendingListings;
  final int cancelledListings;
  final double averageCompletionTime;
  final double totalWasteCollected;
  
  ListingStatistics({
    required this.totalListings,
    required this.completedListings,
    required this.pendingListings,
    required this.cancelledListings,
    required this.averageCompletionTime,
    required this.totalWasteCollected,
  });
  
  factory ListingStatistics.fromJson(Map<String, dynamic> json) {
    return ListingStatistics(
      totalListings: json['total_listings'] ?? 0,
      completedListings: json['completed_listings'] ?? 0,
      pendingListings: json['pending_listings'] ?? 0,
      cancelledListings: json['cancelled_listings'] ?? 0,
      averageCompletionTime: (json['average_completion_time'] ?? 0).toDouble(),
      totalWasteCollected: (json['total_waste_collected'] ?? 0).toDouble(),
    );
  }
  
  factory ListingStatistics.empty() {
    return ListingStatistics(
      totalListings: 0,
      completedListings: 0,
      pendingListings: 0,
      cancelledListings: 0,
      averageCompletionTime: 0,
      totalWasteCollected: 0,
    );
  }
}
