import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_client.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/models/waste_listing_model.dart';

class FarmerRepository {
  final ApiClient _apiClient;
  
  FarmerRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();
  
  // Get farmer profile
  Future<UserModel?> getFarmerProfile() async {
    try {
      final response = await _apiClient.get('/farmer/profile');
      return UserModel.fromJson(response['data']);
    } catch (e) {
      return null;
    }
  }
  
  // Update farmer profile
  Future<UserModel?> updateFarmerProfile(Map<String, dynamic> updates) async {
    try {
      final response = await _apiClient.put('/farmer/profile', updates);
      return UserModel.fromJson(response['data']);
    } catch (e) {
      rethrow;
    }
  }
  
  // Get farmer dashboard stats
  Future<FarmerDashboardStats> getDashboardStats() async {
    try {
      final response = await _apiClient.get('/farmer/dashboard');
      return FarmerDashboardStats.fromJson(response['data']);
    } catch (e) {
      return FarmerDashboardStats.empty();
    }
  }
  
  // Get farmer's consistency score
  Future<double> getConsistencyScore() async {
    try {
      final response = await _apiClient.get('/farmer/consistency-score');
      return response['score']?.toDouble() ?? 0.0;
    } catch (e) {
      return 0.0;
    }
  }
  
  // Update farm location
  Future<bool> updateFarmLocation({
    required String latitude,
    required String longitude,
    required String address,
  }) async {
    try {
      await _apiClient.put('/farmer/location', {
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
      });
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Get farmer's earnings summary
  Future<EarningsSummary> getEarningsSummary() async {
    try {
      final response = await _apiClient.get('/farmer/earnings/summary');
      return EarningsSummary.fromJson(response['data']);
    } catch (e) {
      return EarningsSummary.empty();
    }
  }
  
  // Get earnings history
  Future<List<EarningTransaction>> getEarningsHistory({int page = 1, int limit = 20}) async {
    try {
      final response = await _apiClient.get('/farmer/earnings/history?page=$page&limit=$limit');
      final List<dynamic> data = response['data'];
      return data.map((json) => EarningTransaction.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
  
  // Get farmer's schedule (routine pickups)
  Future<List<RoutineSchedule>> getRoutineSchedule() async {
    try {
      final response = await _apiClient.get('/farmer/schedule');
      final List<dynamic> data = response['data'];
      return data.map((json) => RoutineSchedule.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
  
  // Update routine schedule preferences
  Future<bool> updateRoutineSchedule({
    required bool isActive,
    String? preferredDay,
    String? preferredTimeSlot,
  }) async {
    try {
      await _apiClient.put('/farmer/schedule', {
        'is_active': isActive,
        'preferred_day': preferredDay,
        'preferred_time_slot': preferredTimeSlot,
      });
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Get pricing information for waste types
  Future<PricingInfo> getPricingInfo() async {
    try {
      final response = await _apiClient.get('/farmer/pricing');
      return PricingInfo.fromJson(response['data']);
    } catch (e) {
      return PricingInfo.empty();
    }
  }
  
  // Get notifications for farmer
  Future<List<FarmerNotification>> getNotifications({bool unreadOnly = false}) async {
    try {
      final response = await _apiClient.get('/farmer/notifications?unread=$unreadOnly');
      final List<dynamic> data = response['data'];
      return data.map((json) => FarmerNotification.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
  
  // Mark notification as read
  Future<bool> markNotificationRead(String notificationId) async {
    try {
      await _apiClient.post('/farmer/notifications/$notificationId/read', {});
      return true;
    } catch (e) {
      return false;
    }
  }
}

// Dashboard Stats Model
class FarmerDashboardStats {
  final double totalEarnings;
  final int completedSales;
  final int activeListings;
  final double consistencyScore;
  final int totalPickups;
  final double averageRating;
  
  FarmerDashboardStats({
    required this.totalEarnings,
    required this.completedSales,
    required this.activeListings,
    required this.consistencyScore,
    required this.totalPickups,
    required this.averageRating,
  });
  
  factory FarmerDashboardStats.fromJson(Map<String, dynamic> json) {
    return FarmerDashboardStats(
      totalEarnings: (json['total_earnings'] ?? 0).toDouble(),
      completedSales: json['completed_sales'] ?? 0,
      activeListings: json['active_listings'] ?? 0,
      consistencyScore: (json['consistency_score'] ?? 0).toDouble(),
      totalPickups: json['total_pickups'] ?? 0,
      averageRating: (json['average_rating'] ?? 0).toDouble(),
    );
  }
  
  factory FarmerDashboardStats.empty() {
    return FarmerDashboardStats(
      totalEarnings: 0,
      completedSales: 0,
      activeListings: 0,
      consistencyScore: 0,
      totalPickups: 0,
      averageRating: 0,
    );
  }
}

// Earnings Summary Model
class EarningsSummary {
  final double totalEarned;
  final double pendingPayment;
  final double thisMonth;
  final double lastMonth;
  final double lifetimeEarnings;
  
  EarningsSummary({
    required this.totalEarned,
    required this.pendingPayment,
    required this.thisMonth,
    required this.lastMonth,
    required this.lifetimeEarnings,
  });
  
  factory EarningsSummary.fromJson(Map<String, dynamic> json) {
    return EarningsSummary(
      totalEarned: (json['total_earned'] ?? 0).toDouble(),
      pendingPayment: (json['pending_payment'] ?? 0).toDouble(),
      thisMonth: (json['this_month'] ?? 0).toDouble(),
      lastMonth: (json['last_month'] ?? 0).toDouble(),
      lifetimeEarnings: (json['lifetime_earnings'] ?? 0).toDouble(),
    );
  }
  
  factory EarningsSummary.empty() {
    return EarningsSummary(
      totalEarned: 0,
      pendingPayment: 0,
      thisMonth: 0,
      lastMonth: 0,
      lifetimeEarnings: 0,
    );
  }
}

// Earning Transaction Model
class EarningTransaction {
  final String id;
  final String listingId;
  final double amount;
  final String wasteType;
  final double quantity;
  final String status;
  final DateTime date;
  final String? transactionId;
  
  EarningTransaction({
    required this.id,
    required this.listingId,
    required this.amount,
    required this.wasteType,
    required this.quantity,
    required this.status,
    required this.date,
    this.transactionId,
  });
  
  factory EarningTransaction.fromJson(Map<String, dynamic> json) {
    return EarningTransaction(
      id: json['id'],
      listingId: json['listing_id'],
      amount: (json['amount']).toDouble(),
      wasteType: json['waste_type'],
      quantity: (json['quantity']).toDouble(),
      status: json['status'],
      date: DateTime.parse(json['date']),
      transactionId: json['transaction_id'],
    );
  }
}

// Routine Schedule Model
class RoutineSchedule {
  final String id;
  final String dayOfWeek;
  final String timeSlot;
  final bool isActive;
  final DateTime? nextPickupDate;
  
  RoutineSchedule({
    required this.id,
    required this.dayOfWeek,
    required this.timeSlot,
    required this.isActive,
    this.nextPickupDate,
  });
  
  factory RoutineSchedule.fromJson(Map<String, dynamic> json) {
    return RoutineSchedule(
      id: json['id'],
      dayOfWeek: json['day_of_week'],
      timeSlot: json['time_slot'],
      isActive: json['is_active'],
      nextPickupDate: json['next_pickup_date'] != null 
          ? DateTime.parse(json['next_pickup_date']) 
          : null,
    );
  }
}

// Pricing Info Model
class PricingInfo {
  final Map<String, double> basePrices;
  final Map<String, double> premiumPrices;
  final double premiumThreshold;
  
  PricingInfo({
    required this.basePrices,
    required this.premiumPrices,
    required this.premiumThreshold,
  });
  
  factory PricingInfo.fromJson(Map<String, dynamic> json) {
    return PricingInfo(
      basePrices: Map<String, double>.from(json['base_prices']),
      premiumPrices: Map<String, double>.from(json['premium_prices']),
      premiumThreshold: (json['premium_threshold'] ?? 70).toDouble(),
    );
  }
  
  factory PricingInfo.empty() {
    return PricingInfo(
      basePrices: {},
      premiumPrices: {},
      premiumThreshold: 70,
    );
  }
  
  double getPriceForWasteType(String wasteType, double consistencyScore) {
    final basePrice = basePrices[wasteType] ?? 0;
    if (consistencyScore >= premiumThreshold) {
      return premiumPrices[wasteType] ?? basePrice;
    }
    return basePrice;
  }
}

// Farmer Notification Model
class FarmerNotification {
  final String id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? data;
  
  FarmerNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.data,
  });
  
  factory FarmerNotification.fromJson(Map<String, dynamic> json) {
    return FarmerNotification(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      type: json['type'],
      isRead: json['is_read'],
      createdAt: DateTime.parse(json['created_at']),
      data: json['data'],
    );
  }
}
