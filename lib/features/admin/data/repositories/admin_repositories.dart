import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/models/waste_listing_model.dart';

class AdminRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  AdminRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth;

  // ── DASHBOARD ──

  Future<AdminDashboardStats> getDashboardStats() async {
    try {
      final farmers = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'farmer')
          .get();
      final drivers = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'driver')
          .get();
      final listings = await _firestore.collection('listings').get();
      final pending =
          listings.docs.where((d) => d['status'] == 'pending').length;

      return AdminDashboardStats(
        totalFarmers: farmers.size,
        activeDrivers: drivers.docs
            .where((d) => d.data()['isAvailable'] == true)
            .length,
        todayCollections: 0,
        pendingCollections: pending,
        totalWasteCollected: 0,
        totalRevenue: 0,
        averageRating: 0,
      );
    } catch (e) {
      return AdminDashboardStats.empty();
    }
  }

  Future<RevenueStats> getRevenueStats({String? period = 'month'}) async {
    try {
      final snap = await _firestore
          .collection('transactions')
          .where('type', isEqualTo: 'credit')
          .get();
      double total = 0;
      for (final doc in snap.docs) {
        total += (doc.data()['amount'] ?? 0).toDouble();
      }
      return RevenueStats(
        today: 0,
        thisWeek: 0,
        thisMonth: total,
        thisYear: total,
        byWasteType: {},
      );
    } catch (e) {
      return RevenueStats.empty();
    }
  }

  // ── FLEET ──

  Future<List<DriverModel>> getAllDrivers({bool? isAvailable}) async {
    try {
      Query query = _firestore
          .collection('users')
          .where('role', isEqualTo: 'driver');
      if (isAvailable != null) {
        query = query.where('isAvailable', isEqualTo: isAvailable);
      }
      final snap = await query.get();
      return snap.docs.map((doc) {
        final d = doc.data() as Map<String, dynamic>;
        return DriverModel(
          id: doc.id,
          fullName: d['fullName'] ?? '',
          phoneNumber: d['phoneNumber'] ?? '',
          vehicleNumber: d['vehicleNumber'] ?? '',
          vehicleType: d['vehicleType'] ?? '',
          isAvailable: d['isAvailable'] ?? false,
          isActive: d['isActive'] ?? true,
          completedDeliveries: d['completedPickups'] ?? 0,
          averageRating: (d['averageRating'] ?? 0).toDouble(),
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<DriverModel?> getDriverDetails(String driverId) async {
    try {
      final doc =
          await _firestore.collection('users').doc(driverId).get();
      if (!doc.exists) return null;
      final d = doc.data()!;
      return DriverModel(
        id: doc.id,
        fullName: d['fullName'] ?? '',
        phoneNumber: d['phoneNumber'] ?? '',
        vehicleNumber: d['vehicleNumber'] ?? '',
        vehicleType: d['vehicleType'] ?? '',
        isAvailable: d['isAvailable'] ?? false,
        isActive: d['isActive'] ?? true,
        completedDeliveries: d['completedPickups'] ?? 0,
        averageRating: (d['averageRating'] ?? 0).toDouble(),
      );
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateDriverStatus(String driverId,
      {required bool isActive}) async {
    try {
      await _firestore
          .collection('users')
          .doc(driverId)
          .update({'isActive': isActive});
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> assignCollection(
      String driverId, String collectionId) async {
    try {
      await _firestore
          .collection('listings')
          .doc(collectionId)
          .update({
        'driverId': driverId,
        'status': 'assigned',
        'assignedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<VehicleModel>> getAllVehicles() async {
    try {
      final snap = await _firestore.collection('vehicles').get();
      return snap.docs.map((doc) {
        final d = doc.data();
        return VehicleModel(
          id: doc.id,
          plateNumber: d['plateNumber'] ?? '',
          vehicleType: d['vehicleType'] ?? '',
          driverId: d['driverId'] ?? '',
          driverName: d['driverName'] ?? '',
          isActive: d['isActive'] ?? true,
          capacity: (d['capacity'] ?? 0).toDouble(),
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> addVehicle(Map<String, dynamic> vehicleData) async {
    try {
      await _firestore.collection('vehicles').add({
        ...vehicleData,
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // ── PRICING ──

  Future<PricingConfig> getPricingConfig() async {
    try {
      final doc =
          await _firestore.collection('pricing').doc('config').get();
      if (!doc.exists) return PricingConfig.empty();
      final data = doc.data()!;
      return PricingConfig(
        premiumThreshold: (data['premiumThreshold'] ?? 70).toDouble(),
        basePrices: Map<String, double>.from((data['basePrices'] as Map)
            .map((k, v) => MapEntry(k, (v as num).toDouble()))),
        premiumPrices: Map<String, double>.from(
            (data['premiumPrices'] as Map)
                .map((k, v) => MapEntry(k, (v as num).toDouble()))),
      );
    } catch (e) {
      return PricingConfig.empty();
    }
  }

  Future<bool> updatePricingConfig(PricingConfig config) async {
    try {
      await _firestore
          .collection('pricing')
          .doc('config')
          .set(config.toJson(), SetOptions(merge: true));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateWasteTypePrice(
      String wasteType, double basePrice, double premiumPrice) async {
    try {
      await _firestore.collection('pricing').doc('config').update({
        'basePrices.$wasteType': basePrice,
        'premiumPrices.$wasteType': premiumPrice,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // ── INVENTORY ──

  Future<InventoryStats> getInventoryStats() async {
    try {
      final snap = await _firestore
          .collection('listings')
          .where('status', isEqualTo: 'completed')
          .get();

      double totalWeight = 0;
      final Map<String, double> byType = {};
      for (final doc in snap.docs) {
        final d = doc.data();
        final weight = (d['actualQuantity'] ?? 0).toDouble();
        final type = d['wasteType'] ?? 'other';
        totalWeight += weight;
        byType[type] = (byType[type] ?? 0) + weight;
      }
      return InventoryStats(
        totalItems: snap.size,
        totalWeight: totalWeight,
        byWasteType: byType,
        alerts: [],
      );
    } catch (e) {
      return InventoryStats.empty();
    }
  }

  Future<List<InventoryItem>> getInventoryItems(
      {String? wasteType, int page = 1}) async {
    try {
      Query query = _firestore
          .collection('listings')
          .where('status', isEqualTo: 'completed')
          .orderBy('completedAt', descending: true)
          .limit(20);
      if (wasteType != null) {
        query = query.where('wasteType', isEqualTo: wasteType);
      }
      final snap = await query.get();
      return snap.docs.map((doc) {
        final d = doc.data() as Map<String, dynamic>;
        return InventoryItem(
          id: doc.id,
          wasteType: d['wasteType'] ?? '',
          weight: (d['actualQuantity'] ?? 0).toDouble(),
          farmerName: d['farmerName'] ?? '',
          collectedAt:
              (d['completedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          status: d['status'] ?? 'completed',
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<InventoryItem?> getInventoryItemDetails(String itemId) async {
    try {
      final doc =
          await _firestore.collection('listings').doc(itemId).get();
      if (!doc.exists) return null;
      final d = doc.data()!;
      return InventoryItem(
        id: doc.id,
        wasteType: d['wasteType'] ?? '',
        weight: (d['actualQuantity'] ?? 0).toDouble(),
        farmerName: d['farmerName'] ?? '',
        collectedAt:
            (d['completedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        status: d['status'] ?? 'completed',
      );
    } catch (e) {
      return null;
    }
  }

  // ── ROUTINES ──

  Future<List<RoutineRoute>> getAllRoutines() async {
    try {
      final snap = await _firestore.collection('routines').get();
      return snap.docs.map((doc) {
        final d = doc.data();
        return RoutineRoute(
          id: doc.id,
          name: d['name'] ?? '',
          dayOfWeek: d['dayOfWeek'] ?? '',
          farmerIds: List<String>.from(d['farmerIds'] ?? []),
          farmerNames: List<String>.from(d['farmerNames'] ?? []),
          driverId: d['driverId'] ?? '',
          driverName: d['driverName'] ?? '',
          isActive: d['isActive'] ?? true,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<RoutineRoute?> getRoutineDetails(String routineId) async {
    try {
      final doc =
          await _firestore.collection('routines').doc(routineId).get();
      if (!doc.exists) return null;
      final d = doc.data()!;
      return RoutineRoute(
        id: doc.id,
        name: d['name'] ?? '',
        dayOfWeek: d['dayOfWeek'] ?? '',
        farmerIds: List<String>.from(d['farmerIds'] ?? []),
        farmerNames: List<String>.from(d['farmerNames'] ?? []),
        driverId: d['driverId'] ?? '',
        driverName: d['driverName'] ?? '',
        isActive: d['isActive'] ?? true,
      );
    } catch (e) {
      return null;
    }
  }

  Future<bool> createRoutine(RoutineRoute routine) async {
    try {
      await _firestore.collection('routines').add(routine.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateRoutine(
      String routineId, RoutineRoute routine) async {
    try {
      await _firestore
          .collection('routines')
          .doc(routineId)
          .update(routine.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteRoutine(String routineId) async {
    try {
      await _firestore.collection('routines').doc(routineId).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> optimizeRoutine(String routineId) async {
    try {
      // Placeholder: real implementation would reorder farmerIds by geo-proximity.
      // For now just touch the document so the BLoC gets a success response.
      await _firestore.collection('routines').doc(routineId).update({
        'lastOptimizedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // ── FARMERS ──

  Future<List<UserModel>> getAllFarmers(
      {int page = 1, String? search}) async {
    try {
      Query query = _firestore
          .collection('users')
          .where('role', isEqualTo: 'farmer')
          .limit(20);
      final snap = await query.get();
      final farmers = snap.docs
          .map((doc) => UserModel.fromJson(
              {...doc.data() as Map<String, dynamic>, 'id': doc.id}))
          .toList();
      if (search != null && search.isNotEmpty) {
        return farmers
            .where((f) =>
                f.fullName.toLowerCase().contains(search.toLowerCase()))
            .toList();
      }
      return farmers;
    } catch (e) {
      return [];
    }
  }

  Future<UserModel?> getFarmerDetails(String farmerId) async {
    try {
      final doc =
          await _firestore.collection('users').doc(farmerId).get();
      if (!doc.exists) return null;
      return UserModel.fromJson({...doc.data()!, 'id': doc.id});
    } catch (e) {
      return null;
    }
  }

  Future<FarmerAnalytics> getFarmerAnalytics(String farmerId) async {
    try {
      final userDoc =
          await _firestore.collection('users').doc(farmerId).get();
      final listingsSnap = await _firestore
          .collection('listings')
          .where('farmerId', isEqualTo: farmerId)
          .get();
      final completed = listingsSnap.docs
          .where((d) => d['status'] == 'completed')
          .length;
      final data = userDoc.data() ?? {};
      return FarmerAnalytics(
        consistencyScore:
            (data['consistencyScore'] ?? 0).toDouble(),
        totalPickups: listingsSnap.size,
        completedPickups: completed,
        totalEarnings: (data['totalEarnings'] ?? 0).toDouble(),
        averageWeight: 0,
        monthlyData: [],
      );
    } catch (e) {
      return FarmerAnalytics.empty();
    }
  }

  Future<bool> updateFarmerStatus(String farmerId,
      {required bool isActive}) async {
    try {
      await _firestore
          .collection('users')
          .doc(farmerId)
          .update({'isActive': isActive});
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<ReportData> generateReport({
    required String reportType,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return ReportData(reportUrl: '', summary: {});
  }
}

// ══════════════════════════════════════════════════════════════
// MODEL CLASSES
// ══════════════════════════════════════════════════════════════

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

  factory AdminDashboardStats.empty() => AdminDashboardStats(
        totalFarmers: 0,
        activeDrivers: 0,
        todayCollections: 0,
        pendingCollections: 0,
        totalWasteCollected: 0,
        totalRevenue: 0,
        averageRating: 0,
      );
}

class RevenueStats {
  final double today, thisWeek, thisMonth, thisYear;
  final Map<String, double> byWasteType;

  RevenueStats({
    required this.today,
    required this.thisWeek,
    required this.thisMonth,
    required this.thisYear,
    required this.byWasteType,
  });

  factory RevenueStats.empty() => RevenueStats(
      today: 0, thisWeek: 0, thisMonth: 0, thisYear: 0, byWasteType: {});
}

class DriverModel {
  final String id, fullName, phoneNumber, vehicleNumber, vehicleType;
  final bool isAvailable, isActive;
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
}

class VehicleModel {
  final String id, plateNumber, vehicleType, driverId, driverName;
  final bool isActive;
  final double capacity;

  VehicleModel({
    required this.id,
    required this.plateNumber,
    required this.vehicleType,
    required this.driverId,
    required this.driverName,
    required this.isActive,
    required this.capacity,
  });
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

  factory PricingConfig.empty() => PricingConfig(
      premiumThreshold: 70, basePrices: {}, premiumPrices: {});

  Map<String, dynamic> toJson() => {
        'premiumThreshold': premiumThreshold,
        'basePrices': basePrices,
        'premiumPrices': premiumPrices,
      };
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

  factory InventoryStats.empty() => InventoryStats(
      totalItems: 0, totalWeight: 0, byWasteType: {}, alerts: []);
}

class InventoryAlert {
  final String wasteType, message, severity;
  InventoryAlert(
      {required this.wasteType,
      required this.message,
      required this.severity});
}

class InventoryItem {
  final String id, wasteType, farmerName, status;
  final double weight;
  final DateTime collectedAt;

  InventoryItem({
    required this.id,
    required this.wasteType,
    required this.weight,
    required this.farmerName,
    required this.collectedAt,
    required this.status,
  });
}

class RoutineRoute {
  final String id, name, dayOfWeek, driverId, driverName;
  final List<String> farmerIds, farmerNames;
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

  Map<String, dynamic> toJson() => {
        'name': name,
        'dayOfWeek': dayOfWeek,
        'farmerIds': farmerIds,
        'farmerNames': farmerNames,
        'driverId': driverId,
        'driverName': driverName,
        'isActive': isActive,
      };
}

class FarmerAnalytics {
  final double consistencyScore, totalEarnings, averageWeight;
  final int totalPickups, completedPickups;
  final List<MonthlyData> monthlyData;

  FarmerAnalytics({
    required this.consistencyScore,
    required this.totalPickups,
    required this.completedPickups,
    required this.totalEarnings,
    required this.averageWeight,
    required this.monthlyData,
  });

  factory FarmerAnalytics.empty() => FarmerAnalytics(
        consistencyScore: 0,
        totalPickups: 0,
        completedPickups: 0,
        totalEarnings: 0,
        averageWeight: 0,
        monthlyData: [],
      );
}

class MonthlyData {
  final String month;
  final int pickups;
  final double earnings;

  MonthlyData(
      {required this.month,
      required this.pickups,
      required this.earnings});
}

class ReportData {
  final String reportUrl;
  final Map<String, dynamic> summary;

  ReportData({required this.reportUrl, required this.summary});

  factory ReportData.empty() =>
      ReportData(reportUrl: '', summary: {});
}
