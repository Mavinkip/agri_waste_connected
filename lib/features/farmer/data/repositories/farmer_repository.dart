import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../shared/models/user_model.dart';

class FarmerRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FarmerRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth;

  String get _uid => _auth.currentUser!.uid;

  Future<UserModel?> getFarmerProfile() async {
    try {
      final doc = await _firestore.collection('users').doc(_uid).get();
      if (!doc.exists) return null;
      return UserModel.fromJson({...doc.data()!, 'id': doc.id});
    } catch (e) {
      return null;
    }
  }

  Future<UserModel?> updateFarmerProfile(Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('users').doc(_uid).update(updates);
      return getFarmerProfile();
    } catch (e) {
      rethrow;
    }
  }

  Future<FarmerDashboardStats> getDashboardStats() async {
    try {
      final userDoc = await _firestore.collection('users').doc(_uid).get();
      final listingsSnap = await _firestore
          .collection('listings')
          .where('farmerId', isEqualTo: _uid)
          .get();

      final completed =
          listingsSnap.docs.where((d) => d['status'] == 'completed').length;
      final active = listingsSnap.docs
          .where((d) => d['status'] == 'pending' || d['status'] == 'assigned')
          .length;

      final data = userDoc.data() ?? {};
      return FarmerDashboardStats(
        totalEarnings: (data['totalEarnings'] ?? 0).toDouble(),
        completedSales: completed,
        activeListings: active,
        consistencyScore: (data['consistencyScore'] ?? 0).toDouble(),
        totalPickups: completed,
        averageRating: (data['averageRating'] ?? 0).toDouble(),
      );
    } catch (e) {
      return FarmerDashboardStats.empty();
    }
  }

  Future<double> getConsistencyScore() async {
    try {
      final doc = await _firestore.collection('users').doc(_uid).get();
      return (doc.data()?['consistencyScore'] ?? 0).toDouble();
    } catch (e) {
      return 0.0;
    }
  }

  Future<bool> updateFarmLocation({
    required String latitude,
    required String longitude,
    required String address,
  }) async {
    try {
      await _firestore.collection('users').doc(_uid).update({
        'farmLocationLat': latitude,
        'farmLocationLng': longitude,
        'farmAddress': address,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<EarningsSummary> getEarningsSummary() async {
    try {
      final doc = await _firestore.collection('users').doc(_uid).get();
      final data = doc.data() ?? {};
      return EarningsSummary(
        totalEarned: (data['totalEarnings'] ?? 0).toDouble(),
        pendingPayment: (data['pendingPayment'] ?? 0).toDouble(),
        thisMonth: (data['thisMonthEarnings'] ?? 0).toDouble(),
        lastMonth: (data['lastMonthEarnings'] ?? 0).toDouble(),
        lifetimeEarnings: (data['totalEarnings'] ?? 0).toDouble(),
      );
    } catch (e) {
      return EarningsSummary.empty();
    }
  }

  Future<List<EarningTransaction>> getEarningsHistory(
      {int page = 1, int limit = 20}) async {
    try {
      final snap = await _firestore
          .collection('transactions')
          .where('farmerId', isEqualTo: _uid)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snap.docs.map((doc) {
        final d = doc.data();
        return EarningTransaction(
          id: doc.id,
          listingId: d['listingId'] ?? '',
          amount: (d['amount'] ?? 0).toDouble(),
          wasteType: d['wasteType'] ?? '',
          quantity: (d['quantity'] ?? 0).toDouble(),
          status: d['status'] ?? 'completed',
          date: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          transactionId: d['mpesaRef'],
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<RoutineSchedule>> getRoutineSchedule() async {
    try {
      final snap = await _firestore
          .collection('routines')
          .where('farmerIds', arrayContains: _uid)
          .where('isActive', isEqualTo: true)
          .get();

      return snap.docs.map((doc) {
        final d = doc.data();
        return RoutineSchedule(
          id: doc.id,
          dayOfWeek: d['dayOfWeek'] ?? '',
          timeSlot: d['timeSlot'] ?? '',
          isActive: d['isActive'] ?? true,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> updateRoutineSchedule({
    required bool isActive,
    String? preferredDay,
    String? preferredTimeSlot,
  }) async {
    try {
      await _firestore.collection('users').doc(_uid).update({
        'routineActive': isActive,
        if (preferredDay != null) 'preferredDay': preferredDay,
        if (preferredTimeSlot != null) 'preferredTimeSlot': preferredTimeSlot,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<PricingInfo> getPricingInfo() async {
    try {
      final doc = await _firestore.collection('pricing').doc('config').get();
      if (!doc.exists) return PricingInfo.empty();
      final data = doc.data()!;
      return PricingInfo(
        basePrices: Map<String, double>.from((data['basePrices'] as Map)
            .map((k, v) => MapEntry(k, (v as num).toDouble()))),
        premiumPrices: Map<String, double>.from((data['premiumPrices'] as Map)
            .map((k, v) => MapEntry(k, (v as num).toDouble()))),
        premiumThreshold: (data['premiumThreshold'] ?? 70).toDouble(),
      );
    } catch (e) {
      return PricingInfo.empty();
    }
  }

  Future<List<FarmerNotification>> getNotifications(
      {bool unreadOnly = false}) async {
    try {
      Query query = _firestore
          .collection('notifications')
          .where('userId', isEqualTo: _uid)
          .orderBy('createdAt', descending: true)
          .limit(50);

      if (unreadOnly) query = query.where('isRead', isEqualTo: false);

      final snap = await query.get();
      return snap.docs.map((doc) {
        final d = doc.data() as Map<String, dynamic>;
        return FarmerNotification(
          id: doc.id,
          title: d['title'] ?? '',
          message: d['message'] ?? '',
          type: d['type'] ?? 'general',
          isRead: d['isRead'] ?? false,
          createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> markNotificationRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
      return true;
    } catch (e) {
      return false;
    }
  }
}

// ── Model classes ──

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

  factory FarmerDashboardStats.fromJson(Map<String, dynamic> json) =>
      FarmerDashboardStats(
        totalEarnings: (json['total_earnings'] ?? 0).toDouble(),
        completedSales: json['completed_sales'] ?? 0,
        activeListings: json['active_listings'] ?? 0,
        consistencyScore: (json['consistency_score'] ?? 0).toDouble(),
        totalPickups: json['total_pickups'] ?? 0,
        averageRating: (json['average_rating'] ?? 0).toDouble(),
      );

  factory FarmerDashboardStats.empty() => FarmerDashboardStats(
        totalEarnings: 0,
        completedSales: 0,
        activeListings: 0,
        consistencyScore: 0,
        totalPickups: 0,
        averageRating: 0,
      );
}

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

  factory EarningsSummary.fromJson(Map<String, dynamic> json) =>
      EarningsSummary(
        totalEarned: (json['total_earned'] ?? 0).toDouble(),
        pendingPayment: (json['pending_payment'] ?? 0).toDouble(),
        thisMonth: (json['this_month'] ?? 0).toDouble(),
        lastMonth: (json['last_month'] ?? 0).toDouble(),
        lifetimeEarnings: (json['lifetime_earnings'] ?? 0).toDouble(),
      );

  factory EarningsSummary.empty() => EarningsSummary(
        totalEarned: 0,
        pendingPayment: 0,
        thisMonth: 0,
        lastMonth: 0,
        lifetimeEarnings: 0,
      );
}

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

  factory EarningTransaction.fromJson(Map<String, dynamic> json) =>
      EarningTransaction(
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

  factory RoutineSchedule.fromJson(Map<String, dynamic> json) =>
      RoutineSchedule(
        id: json['id'],
        dayOfWeek: json['day_of_week'],
        timeSlot: json['time_slot'],
        isActive: json['is_active'],
        nextPickupDate: json['next_pickup_date'] != null
            ? DateTime.parse(json['next_pickup_date'])
            : null,
      );
}

class PricingInfo {
  final Map<String, double> basePrices;
  final Map<String, double> premiumPrices;
  final double premiumThreshold;

  PricingInfo({
    required this.basePrices,
    required this.premiumPrices,
    required this.premiumThreshold,
  });

  factory PricingInfo.fromJson(Map<String, dynamic> json) => PricingInfo(
        basePrices: Map<String, double>.from(json['base_prices']),
        premiumPrices: Map<String, double>.from(json['premium_prices']),
        premiumThreshold: (json['premium_threshold'] ?? 70).toDouble(),
      );

  factory PricingInfo.empty() => PricingInfo(
        basePrices: {},
        premiumPrices: {},
        premiumThreshold: 70,
      );

  double getPriceForWasteType(String wasteType, double consistencyScore) {
    final basePrice = basePrices[wasteType] ?? 0;
    if (consistencyScore >= premiumThreshold) {
      return premiumPrices[wasteType] ?? basePrice;
    }
    return basePrice;
  }
}

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

  factory FarmerNotification.fromJson(Map<String, dynamic> json) =>
      FarmerNotification(
        id: json['id'],
        title: json['title'],
        message: json['message'],
        type: json['type'],
        isRead: json['is_read'],
        createdAt: DateTime.parse(json['created_at']),
        data: json['data'],
      );
}
