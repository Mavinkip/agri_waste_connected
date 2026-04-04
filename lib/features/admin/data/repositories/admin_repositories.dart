import '../../../../core/network/api_client.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/models/waste_listing_model.dart';

class AdminRepository {
  final ApiClient _apiClient;
  
  AdminRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();
  
  // ==================== DASHBOARD STATS ====================
  
  Future<AdminDashboardStats> getDashboardStats() async {
    try {
      final response = await _apiClient.get('/admin/dashboard/stats');
      return AdminDashboardStats.fromJson(response['data']);
    } catch (e) {
      return AdminDashboardStats.empty();
    }
  }
  
  Future<RevenueStats> getRevenueStats({String? period = 'month'}) async {
    try {
      final response = await _apiClient.get('/admin/dashboard/revenue?period=$period');
      return RevenueStats.fromJson(response['data']);
    } catch (e) {
      return RevenueStats.empty();
    }
  }
  
  // ==================== FLEET MANAGEMENT ====================
  
  Future<List<DriverModel>> getAllDrivers({bool? isAvailable}) async {
    try {
      String url = '/admin/drivers';
      if (isAvailable != null) {
        url += '?is_available=$isAvailable';
      }
      final response = await _apiClient.get(url);
      final List<dynamic> data = response['data'];
      return data.map((json) => DriverModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
  
  Future<DriverModel?> getDriverDetails(String driverId) async {
    try {
      final response = await _apiClient.get('/admin/drivers/$driverId');
      return DriverModel.fromJson(response['data']);
    } catch (e) {
      return null;
    }
  }
  
  Future<bool> updateDriverStatus(String driverId, {required bool isActive}) async {
    try {
      await _apiClient.patch('/admin/drivers/$driverId', {
        'is_active': isActive,
      });
      return true;
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> assignCollection(String driverId, String collectionId) async {
    try {
      await _apiClient.post('/admin/drivers/$driverId/assign', {
        'collection_id': collectionId,
      });
      return true;
    } catch (e) {
      return false;
    }
  }
  
  Future<List<VehicleModel>> getAllVehicles() async {
    try {
      final response = await _apiClient.get('/admin/vehicles');
      final List<dynamic> data = response['data'];
      return data.map((json) => VehicleModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
  
  Future<bool> addVehicle(Map<String, dynamic> vehicleData) async {
    try {
      await _apiClient.post('/admin/vehicles', vehicleData);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // ==================== PRICING MANAGEMENT ====================
  
  Future<PricingConfig> getPricingConfig() async {
    try {
      final response = await _apiClient.get('/admin/pricing');
      return PricingConfig.fromJson(response['data']);
    } catch (e) {
      return PricingConfig.empty();
    }
  }
  
  Future<bool> updatePricingConfig(PricingConfig config) async {
    try {
      await _apiClient.put('/admin/pricing', config.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> updateWasteTypePrice(String wasteType, double basePrice, double premiumPrice) async {
    try {
      await _apiClient.put('/admin/pricing/waste-type', {
        'waste_type': wasteType,
        'base_price': basePrice,
        'premium_price': premiumPrice,
      });
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // ==================== INVENTORY MANAGEMENT ====================
  
  Future<InventoryStats> getInventoryStats() async {
    try {
      final response = await _apiClient.get('/admin/inventory/stats');
      return InventoryStats.fromJson(response['data']);
    } catch (e) {
      return InventoryStats.empty();
    }
  }
  
  Future<List<InventoryItem>> getInventoryItems({String? wasteType, int page = 1}) async {
    try {
      String url = '/admin/inventory?page=$page';
      if (wasteType != null) {
        url += '&waste_type=$wasteType';
      }
      final response = await _apiClient.get(url);
      final List<dynamic> data = response['data'];
      return data.map((json) => InventoryItem.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
  
  Future<InventoryItem?> getInventoryItemDetails(String itemId) async {
    try {
      final response = await _apiClient.get('/admin/inventory/$itemId');
      return InventoryItem.fromJson(response['data']);
    } catch (e) {
      return null;
    }
  }
  
  // ==================== ROUTINE MANAGEMENT ====================
  
  Future<List<RoutineRoute>> getAllRoutines() async {
    try {
      final response = await _apiClient.get('/admin/routines');
      final List<dynamic> data = response['data'];
      return data.map((json) => RoutineRoute.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
  
  Future<RoutineRoute?> getRoutineDetails(String routineId) async {
    try {
      final response = await _apiClient.get('/admin/routines/$routineId');
      return RoutineRoute.fromJson(response['data']);
    } catch (e) {
      return null;
    }
  }
  
  Future<bool> createRoutine(RoutineRoute routine) async {
    try {
      await _apiClient.post('/admin/routines', routine.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> updateRoutine(String routineId, RoutineRoute routine) async {
    try {
      await _apiClient.put('/admin/routines/$routineId', routine.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> deleteRoutine(String routineId) async {
    try {
      await _apiClient.delete('/admin/routines/$routineId');
      return true;
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> optimizeRoutine(String routineId) async {
    try {
      final response = await _apiClient.post('/admin/routines/$routineId/optimize', {});
      return response['success'] == true;
    } catch (e) {
      return false;
    }
  }
  
  // ==================== FARMER MANAGEMENT ====================
  
  Future<List<UserModel>> getAllFarmers({int page = 1, String? search}) async {
    try {
      String url = '/admin/farmers?page=$page';
      if (search != null && search.isNotEmpty) {
        url += '&search=$search';
      }
      final response = await _apiClient.get(url);
      final List<dynamic> data = response['data'];
      return data.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
  
  Future<UserModel?> getFarmerDetails(String farmerId) async {
    try {
      final response = await _apiClient.get('/admin/farmers/$farmerId');
      return UserModel.fromJson(response['data']);
    } catch (e) {
      return null;
    }
  }
  
  Future<FarmerAnalytics> getFarmerAnalytics(String farmerId) async {
    try {
      final response = await _apiClient.get('/admin/farmers/$farmerId/analytics');
      return FarmerAnalytics.fromJson(response['data']);
    } catch (e) {
      return FarmerAnalytics.empty();
    }
  }
  
  Future<bool> updateFarmerStatus(String farmerId, {required bool isActive}) async {
    try {
      await _apiClient.patch('/admin/farmers/$farmerId', {
        'is_active': isActive,
      });
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // ==================== REPORTS ====================
  
  Future<ReportData> generateReport({
    required String reportType,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _apiClient.post('/admin/reports/generate', {
        'report_type': reportType,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
      });
      return ReportData.fromJson(response['data']);
    } catch (e) {
      return ReportData.empty();
    }
  }
}

// ==================== MODEL CLASSES ====================

class AdminDashboardStats {
  final int totalFarmers;
  final int activeDrivers;
  final int todayCollections;
  final int pendingCollections;
  final double totalWasteCollected;
  final double totalRevenue;
  final double averageRating;
  
  AdminDashboardStats({
    required this.totalFarmers,
    required this.activeDrivers,
    required this.todayCollections,
    required this.pendingCollections,
    required this.totalWasteCollected,
    required this.totalRevenue,
    required this.averageRating,
  });
  
  factory AdminDashboardStats.fromJson(Map<String, dynamic> json) {
    return AdminDashboardStats(
      totalFarmers: json['total_farmers'] ?? 0,
      activeDrivers: json['active_drivers'] ?? 0,
      todayCollections: json['today_collections'] ?? 0,
      pendingCollections: json['pending_collections'] ?? 0,
      totalWasteCollected: (json['total_waste_collected'] ?? 0).toDouble(),
      totalRevenue: (json['total_revenue'] ?? 0).toDouble(),
      averageRating: (json['average_rating'] ?? 0).toDouble(),
    );
  }
  
  factory AdminDashboardStats.empty() {
    return AdminDashboardStats(
      totalFarmers: 0,
      activeDrivers: 0,
      todayCollections: 0,
      pendingCollections: 0,
      totalWasteCollected: 0,
      totalRevenue: 0,
      averageRating: 0,
    );
  }
}

class RevenueStats {
  final double today;
  final double thisWeek;
  final double thisMonth;
  final double thisYear;
  final Map<String, double> byWasteType;
  
  RevenueStats({
    required this.today,
    required this.thisWeek,
    required this.thisMonth,
    required this.thisYear,
    required this.byWasteType,
  });
  
  factory RevenueStats.fromJson(Map<String, dynamic> json) {
    return RevenueStats(
      today: (json['today'] ?? 0).toDouble(),
      thisWeek: (json['this_week'] ?? 0).toDouble(),
      thisMonth: (json['this_month'] ?? 0).toDouble(),
      thisYear: (json['this_year'] ?? 0).toDouble(),
      byWasteType: Map<String, double>.from(json['by_waste_type'] ?? {}),
    );
  }
  
  factory RevenueStats.empty() {
    return RevenueStats(
      today: 0,
      thisWeek: 0,
      thisMonth: 0,
      thisYear: 0,
      byWasteType: {},
    );
  }
}

class DriverModel {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String vehicleNumber;
  final String vehicleType;
  final bool isAvailable;
  final bool isActive;
  final int completedDeliveries;
  final double averageRating;
  
  DriverModel({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.vehicleNumber,
    required this.vehicleType,
    required this.isAvailable,
    required this.isActive,
    required this.completedDeliveries,
    required this.averageRating,
  });
  
  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['id'],
      fullName: json['full_name'],
      phoneNumber: json['phone_number'],
      vehicleNumber: json['vehicle_number'],
      vehicleType: json['vehicle_type'],
      isAvailable: json['is_available'] ?? false,
      isActive: json['is_active'] ?? true,
      completedDeliveries: json['completed_deliveries'] ?? 0,
      averageRating: (json['average_rating'] ?? 0).toDouble(),
    );
  }
}

class VehicleModel {
  final String id;
  final String vehicleNumber;
  final String vehicleType;
  final String driverId;
  final String driverName;
  final bool isActive;
  
  VehicleModel({
    required this.id,
    required this.vehicleNumber,
    required this.vehicleType,
    required this.driverId,
    required this.driverName,
    required this.isActive,
  });
  
  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'],
      vehicleNumber: json['vehicle_number'],
      vehicleType: json['vehicle_type'],
      driverId: json['driver_id'],
      driverName: json['driver_name'],
      isActive: json['is_active'] ?? true,
    );
  }
}

class PricingConfig {
  final double premiumThreshold;
  final Map<String, double> basePrices;
  final Map<String, double> premiumPrices;
  
  PricingConfig({
    required this.premiumThreshold,
    required this.basePrices,
    required this.premiumPrices,
  });
  
  factory PricingConfig.fromJson(Map<String, dynamic> json) {
    return PricingConfig(
      premiumThreshold: (json['premium_threshold'] ?? 70).toDouble(),
      basePrices: Map<String, double>.from(json['base_prices'] ?? {}),
      premiumPrices: Map<String, double>.from(json['premium_prices'] ?? {}),
    );
  }
  
  factory PricingConfig.empty() {
    return PricingConfig(
      premiumThreshold: 70,
      basePrices: {},
      premiumPrices: {},
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'premium_threshold': premiumThreshold,
      'base_prices': basePrices,
      'premium_prices': premiumPrices,
    };
  }
}

class InventoryStats {
  final int totalItems;
  final double totalWeight;
  final Map<String, double> byWasteType;
  final List<InventoryAlert> alerts;
  
  InventoryStats({
    required this.totalItems,
    required this.totalWeight,
    required this.byWasteType,
    required this.alerts,
  });
  
  factory InventoryStats.fromJson(Map<String, dynamic> json) {
    final alertsList = json['alerts'] as List? ?? [];
    return InventoryStats(
      totalItems: json['total_items'] ?? 0,
      totalWeight: (json['total_weight'] ?? 0).toDouble(),
      byWasteType: Map<String, double>.from(json['by_waste_type'] ?? {}),
      alerts: alertsList.map((a) => InventoryAlert.fromJson(a)).toList(),
    );
  }
  
  factory InventoryStats.empty() {
    return InventoryStats(
      totalItems: 0,
      totalWeight: 0,
      byWasteType: {},
      alerts: [],
    );
  }
}

class InventoryAlert {
  final String wasteType;
  final String message;
  final String severity;
  
  InventoryAlert({
    required this.wasteType,
    required this.message,
    required this.severity,
  });
  
  factory InventoryAlert.fromJson(Map<String, dynamic> json) {
    return InventoryAlert(
      wasteType: json['waste_type'],
      message: json['message'],
      severity: json['severity'],
    );
  }
}

class InventoryItem {
  final String id;
  final String wasteType;
  final double weight;
  final String farmerName;
  final DateTime collectedAt;
  final String status;
  
  InventoryItem({
    required this.id,
    required this.wasteType,
    required this.weight,
    required this.farmerName,
    required this.collectedAt,
    required this.status,
  });
  
  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'],
      wasteType: json['waste_type'],
      weight: (json['weight']).toDouble(),
      farmerName: json['farmer_name'],
      collectedAt: DateTime.parse(json['collected_at']),
      status: json['status'],
    );
  }
}

class RoutineRoute {
  final String id;
  final String name;
  final String dayOfWeek;
  final List<String> farmerIds;
  final List<String> farmerNames;
  final String driverId;
  final String driverName;
  final bool isActive;
  
  RoutineRoute({
    required this.id,
    required this.name,
    required this.dayOfWeek,
    required this.farmerIds,
    required this.farmerNames,
    required this.driverId,
    required this.driverName,
    required this.isActive,
  });
  
  factory RoutineRoute.fromJson(Map<String, dynamic> json) {
    return RoutineRoute(
      id: json['id'],
      name: json['name'],
      dayOfWeek: json['day_of_week'],
      farmerIds: List<String>.from(json['farmer_ids'] ?? []),
      farmerNames: List<String>.from(json['farmer_names'] ?? []),
      driverId: json['driver_id'],
      driverName: json['driver_name'],
      isActive: json['is_active'] ?? true,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'day_of_week': dayOfWeek,
      'farmer_ids': farmerIds,
      'driver_id': driverId,
      'is_active': isActive,
    };
  }
}

class FarmerAnalytics {
  final double consistencyScore;
  final int totalPickups;
  final int completedPickups;
  final double totalEarnings;
  final double averageWeight;
  final List<MonthlyData> monthlyData;
  
  FarmerAnalytics({
    required this.consistencyScore,
    required this.totalPickups,
    required this.completedPickups,
    required this.totalEarnings,
    required this.averageWeight,
    required this.monthlyData,
  });
  
  factory FarmerAnalytics.fromJson(Map<String, dynamic> json) {
    final monthlyList = json['monthly_data'] as List? ?? [];
    return FarmerAnalytics(
      consistencyScore: (json['consistency_score'] ?? 0).toDouble(),
      totalPickups: json['total_pickups'] ?? 0,
      completedPickups: json['completed_pickups'] ?? 0,
      totalEarnings: (json['total_earnings'] ?? 0).toDouble(),
      averageWeight: (json['average_weight'] ?? 0).toDouble(),
      monthlyData: monthlyList.map((m) => MonthlyData.fromJson(m)).toList(),
    );
  }
  
  factory FarmerAnalytics.empty() {
    return FarmerAnalytics(
      consistencyScore: 0,
      totalPickups: 0,
      completedPickups: 0,
      totalEarnings: 0,
      averageWeight: 0,
      monthlyData: [],
    );
  }
}

class MonthlyData {
  final String month;
  final int pickups;
  final double earnings;
  
  MonthlyData({
    required this.month,
    required this.pickups,
    required this.earnings,
  });
  
  factory MonthlyData.fromJson(Map<String, dynamic> json) {
    return MonthlyData(
      month: json['month'],
      pickups: json['pickups'] ?? 0,
      earnings: (json['earnings'] ?? 0).toDouble(),
    );
  }
}

class ReportData {
  final String reportUrl;
  final Map<String, dynamic> summary;
  
  ReportData({
    required this.reportUrl,
    required this.summary,
  });
  
  factory ReportData.fromJson(Map<String, dynamic> json) {
    return ReportData(
      reportUrl: json['report_url'],
      summary: json['summary'] ?? {},
    );
  }
  
  factory ReportData.empty() {
    return ReportData(
      reportUrl: '',
      summary: {},
    );
  }
}
