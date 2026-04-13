#!/bin/bash
# ============================================================
# SESSION 4 — ERROR FIXES
# Run this entire file OR copy-paste each block one at a time
# ============================================================

# ────────────────────────────────────────────────────────────
# FIX 1: Create a temporary firebase_options.dart
# (This lets the app compile NOW — replace it properly later
#  by running: flutterfire configure)
# ────────────────────────────────────────────────────────────
cat > /home/delva/project/agri_waste_connected/lib/firebase_options.dart << 'EOF'
// TEMPORARY — replace this file by running:
//   dart pub global activate flutterfire_cli
//   flutterfire configure
//
// Paste your actual values from Firebase Console:
// Project Settings → Your Apps → Android → google-services.json

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // ── REPLACE THESE VALUES with your actual Firebase project values ──
  // Find them in: Firebase Console → Project Settings → General
  // OR run: flutterfire configure  (auto-fills everything)

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',
    appId: 'YOUR_ANDROID_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
    iosBundleId: 'com.example.agriWasteConnected',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY',
    appId: 'YOUR_WEB_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
    authDomain: 'YOUR_PROJECT_ID.firebaseapp.com',
  );
}
EOF

echo "✅ firebase_options.dart created (fill in your values or run flutterfire configure)"

# ────────────────────────────────────────────────────────────
# FIX 2: Rewrite offline_sync_repository.dart
# Removes ALL sqflite code — uses Firestore offline cache instead
# ────────────────────────────────────────────────────────────
cat > /home/delva/project/agri_waste_connected/lib/shared/services/offline_sync_repository.dart << 'EOF'
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
EOF

echo "✅ offline_sync_repository.dart rewritten (sqflite removed)"

# ────────────────────────────────────────────────────────────
# FIX 3: Rewrite auth_repository.dart with Firebase params
# ────────────────────────────────────────────────────────────
cat > /home/delva/project/agri_waste_connected/lib/features/auth/data/repositories/auth_repository.dart << 'EOF'
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../shared/models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  })  : _auth = auth,
        _firestore = firestore;

  // Convert phone to email format for Firebase Auth
  String _phoneToEmail(String phone) =>
      '${phone.replaceAll(RegExp(r'[^0-9]'), '')}@agri.local';

  Future<AuthResponse> login(String phoneNumber, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: _phoneToEmail(phoneNumber),
        password: password,
      );

      final doc = await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      if (!doc.exists) {
        return AuthResponse.failure(message: 'User profile not found');
      }

      final user = UserModel.fromJson({...doc.data()!, 'id': doc.id});
      final token = await credential.user!.getIdToken() ?? '';

      await _saveUserLocally(user);
      return AuthResponse.success(user: user, token: token);
    } on FirebaseAuthException catch (e) {
      return AuthResponse.failure(
          message: e.message ?? 'Login failed. Please try again.');
    } catch (e) {
      return AuthResponse.failure(message: 'Login failed. Please try again.');
    }
  }

  Future<AuthResponse> register(RegisterData data) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: _phoneToEmail(data.phoneNumber),
        password: data.password,
      );

      final userDoc = {
        'phoneNumber': data.phoneNumber,
        'fullName': data.fullName,
        'role': data.role.name,
        'isVerified': false,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(userDoc);

      final user = UserModel(
        id: credential.user!.uid,
        phoneNumber: data.phoneNumber,
        fullName: data.fullName,
        role: data.role,
        createdAt: DateTime.now(),
      );

      final token = await credential.user!.getIdToken() ?? '';
      await _saveUserLocally(user);
      return AuthResponse.success(user: user, token: token);
    } on FirebaseAuthException catch (e) {
      return AuthResponse.failure(
          message: e.message ?? 'Registration failed. Please try again.');
    } catch (e) {
      return AuthResponse.failure(
          message: 'Registration failed. Please try again.');
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
  }

  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();
      if (!doc.exists) return null;
      return UserModel.fromJson({...doc.data()!, 'id': doc.id});
    } catch (e) {
      // Try local cache
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user_data');
      if (userData != null) {
        return UserModel.fromJson(jsonDecode(userData));
      }
      return null;
    }
  }

  Future<bool> isLoggedIn() async {
    return _auth.currentUser != null;
  }

  Future<void> _saveUserLocally(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(user.toJson()));
  }

  Future<bool> verifyPhoneNumber(String phoneNumber) async {
    try {
      final methods = await _auth.fetchSignInMethodsForEmail(
          _phoneToEmail(phoneNumber));
      return methods.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}

class RegisterData {
  final String fullName;
  final String phoneNumber;
  final String password;
  final UserRole role;

  RegisterData({
    required this.fullName,
    required this.phoneNumber,
    required this.password,
    required this.role,
  });
}

class AuthResponse {
  final bool success;
  final UserModel? user;
  final String? token;
  final String? message;

  AuthResponse._({
    required this.success,
    this.user,
    this.token,
    this.message,
  });

  factory AuthResponse.success(
          {required UserModel user, required String token}) =>
      AuthResponse._(success: true, user: user, token: token);

  factory AuthResponse.failure({required String message}) =>
      AuthResponse._(success: false, message: message);
}
EOF

echo "✅ auth_repository.dart rewritten (Firebase)"

# ────────────────────────────────────────────────────────────
# FIX 4: Rewrite farmer_repository.dart with Firebase params
# ────────────────────────────────────────────────────────────
cat > /home/delva/project/agri_waste_connected/lib/features/farmer/data/repositories/farmer_repository.dart << 'EOF'
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/models/waste_listing_model.dart';

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
      final doc =
          await _firestore.collection('pricing').doc('config').get();
      if (!doc.exists) return PricingInfo.empty();
      final data = doc.data()!;
      return PricingInfo(
        basePrices: Map<String, double>.from(
            (data['basePrices'] as Map).map((k, v) => MapEntry(k, (v as num).toDouble()))),
        premiumPrices: Map<String, double>.from(
            (data['premiumPrices'] as Map).map((k, v) => MapEntry(k, (v as num).toDouble()))),
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
EOF

echo "✅ farmer_repository.dart rewritten (Firebase)"

# ────────────────────────────────────────────────────────────
# FIX 5: Rewrite listing_repository.dart with Firebase params
# ────────────────────────────────────────────────────────────
cat > /home/delva/project/agri_waste_connected/lib/features/farmer/data/repositories/listing_repository.dart << 'EOF'
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../../shared/models/waste_listing_model.dart';

class ListingRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final FirebaseAuth _auth;

  ListingRepository({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _storage = storage,
        _auth = auth;

  String get _uid => _auth.currentUser!.uid;

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
    final user = _auth.currentUser!;

    // Get farmer name from Firestore
    final userDoc = await _firestore.collection('users').doc(_uid).get();
    final farmerName = userDoc.data()?['fullName'] ?? 'Unknown Farmer';

    final docRef = await _firestore.collection('listings').add({
      'farmerId': user.uid,
      'farmerName': farmerName,
      'wasteType': wasteType.name,
      'estimatedQuantity': estimatedQuantity,
      'pickupLat': pickupLat,
      'pickupLng': pickupLng,
      'pickupAddress': pickupAddress,
      'pickupType': pickupType.name,
      'status': 'pending',
      'isPhotoRequired': isPhotoRequired,
      'photoUrl': photos,
      'notes': notes,
      'createdAt': FieldValue.serverTimestamp(),
    });

    final snap = await docRef.get();
    final data = snap.data()!;

    return WasteListingModel(
      id: snap.id,
      farmerId: data['farmerId'],
      farmerName: data['farmerName'],
      wasteType: wasteType,
      estimatedQuantity: estimatedQuantity,
      pickupLat: pickupLat,
      pickupLng: pickupLng,
      pickupAddress: pickupAddress,
      pickupType: pickupType,
      status: ListingStatus.pending,
      createdAt: DateTime.now(),
      isPhotoRequired: isPhotoRequired,
      notes: notes,
    );
  }

  Future<List<WasteListingModel>> getFarmerListings({
    ListingStatus? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      Query query = _firestore
          .collection('listings')
          .where('farmerId', isEqualTo: _uid)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (status != null) {
        query = query.where('status', isEqualTo: status.name);
      }

      final snap = await query.get();
      return snap.docs.map((doc) {
        final d = doc.data() as Map<String, dynamic>;
        return WasteListingModel.fromJson({...d, 'id': doc.id});
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<WasteListingModel?> getListing(String listingId) async {
    try {
      final doc =
          await _firestore.collection('listings').doc(listingId).get();
      if (!doc.exists) return null;
      return WasteListingModel.fromJson({...doc.data()!, 'id': doc.id});
    } catch (e) {
      return null;
    }
  }

  Future<WasteListingModel?> updateListing(
      String listingId, Map<String, dynamic> updates) async {
    try {
      await _firestore
          .collection('listings')
          .doc(listingId)
          .update(updates);
      return getListing(listingId);
    } catch (e) {
      return null;
    }
  }

  Future<bool> cancelListing(String listingId) async {
    try {
      await _firestore
          .collection('listings')
          .doc(listingId)
          .update({'status': 'cancelled'});
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<int> getActiveListingsCount() async {
    try {
      final snap = await _firestore
          .collection('listings')
          .where('farmerId', isEqualTo: _uid)
          .where('status', whereIn: ['pending', 'assigned'])
          .get();
      return snap.size;
    } catch (e) {
      return 0;
    }
  }

  Future<List<String>> uploadPhotos(List<String> photoPaths) async {
    final urls = <String>[];
    for (final path in photoPaths) {
      try {
        final file = File(path);
        final ref = _storage
            .ref()
            .child('listings/$_uid/${DateTime.now().millisecondsSinceEpoch}.jpg');
        await ref.putFile(file);
        final url = await ref.getDownloadURL();
        urls.add(url);
      } catch (e) {
        // Skip failed uploads
      }
    }
    return urls;
  }

  Future<ListingStatistics> getListingStatistics() async {
    try {
      final snap = await _firestore
          .collection('listings')
          .where('farmerId', isEqualTo: _uid)
          .get();

      final docs = snap.docs;
      final completed =
          docs.where((d) => d['status'] == 'completed').length;
      final pending =
          docs.where((d) => d['status'] == 'pending').length;
      final cancelled =
          docs.where((d) => d['status'] == 'cancelled').length;

      return ListingStatistics(
        totalListings: docs.length,
        completedListings: completed,
        pendingListings: pending,
        cancelledListings: cancelled,
        averageCompletionTime: 0,
        totalWasteCollected: 0,
      );
    } catch (e) {
      return ListingStatistics.empty();
    }
  }
}

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

  factory ListingStatistics.empty() => ListingStatistics(
        totalListings: 0,
        completedListings: 0,
        pendingListings: 0,
        cancelledListings: 0,
        averageCompletionTime: 0,
        totalWasteCollected: 0,
      );
}
EOF

echo "✅ listing_repository.dart rewritten (Firebase)"

# ────────────────────────────────────────────────────────────
# FIX 6: Rewrite wallet_repository.dart with Firebase params
# ────────────────────────────────────────────────────────────
cat > /home/delva/project/agri_waste_connected/lib/features/farmer/data/repositories/wallet_repository.dart << 'EOF'
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WalletRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  WalletRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth;

  String get _uid => _auth.currentUser!.uid;

  Future<WalletBalance> getWalletBalance() async {
    try {
      final doc = await _firestore.collection('users').doc(_uid).get();
      final data = doc.data() ?? {};
      return WalletBalance(
        availableBalance: (data['walletBalance'] ?? 0).toDouble(),
        pendingBalance: (data['pendingBalance'] ?? 0).toDouble(),
        totalEarned: (data['totalEarnings'] ?? 0).toDouble(),
        totalWithdrawn: (data['totalWithdrawn'] ?? 0).toDouble(),
        lastUpdated: DateTime.now().toIso8601String(),
      );
    } catch (e) {
      return WalletBalance.empty();
    }
  }

  Future<List<WalletTransaction>> getTransactionHistory({
    int page = 1,
    int limit = 20,
    String? type,
  }) async {
    try {
      Query query = _firestore
          .collection('transactions')
          .where('farmerId', isEqualTo: _uid)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (type != null) query = query.where('type', isEqualTo: type);

      final snap = await query.get();
      return snap.docs.map((doc) {
        final d = doc.data() as Map<String, dynamic>;
        return WalletTransaction(
          id: doc.id,
          type: d['type'] ?? 'credit',
          amount: (d['amount'] ?? 0).toDouble(),
          status: d['status'] ?? 'completed',
          description: d['description'] ?? '',
          createdAt:
              (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          reference: d['mpesaRef'],
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<WithdrawalResponse> requestWithdrawal({
    required double amount,
    required String phoneNumber,
    String? notes,
  }) async {
    try {
      final docRef =
          await _firestore.collection('withdrawals').add({
        'farmerId': _uid,
        'amount': amount,
        'phoneNumber': phoneNumber,
        'notes': notes,
        'status': 'pending',
        'requestedAt': FieldValue.serverTimestamp(),
      });
      return WithdrawalResponse(
        success: true,
        withdrawalId: docRef.id,
        message: 'Withdrawal request submitted',
        status: 'pending',
      );
    } catch (e) {
      return WithdrawalResponse.failure('Withdrawal request failed');
    }
  }

  Future<List<Withdrawal>> getWithdrawalHistory(
      {int page = 1, int limit = 20}) async {
    try {
      final snap = await _firestore
          .collection('withdrawals')
          .where('farmerId', isEqualTo: _uid)
          .orderBy('requestedAt', descending: true)
          .limit(limit)
          .get();

      return snap.docs.map((doc) {
        final d = doc.data();
        return Withdrawal(
          id: doc.id,
          amount: (d['amount'] ?? 0).toDouble(),
          status: d['status'] ?? 'pending',
          phoneNumber: d['phoneNumber'] ?? '',
          requestedAt:
              (d['requestedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          processedAt: (d['processedAt'] as Timestamp?)?.toDate(),
          transactionId: d['mpesaRef'],
          failureReason: d['failureReason'],
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, double>> getEarningsByWasteType() async {
    try {
      final snap = await _firestore
          .collection('transactions')
          .where('farmerId', isEqualTo: _uid)
          .where('type', isEqualTo: 'credit')
          .get();

      final Map<String, double> result = {};
      for (final doc in snap.docs) {
        final d = doc.data();
        final type = d['wasteType'] as String? ?? 'other';
        final amount = (d['amount'] ?? 0).toDouble();
        result[type] = (result[type] ?? 0) + amount;
      }
      return result;
    } catch (e) {
      return {};
    }
  }
}

// ── Model classes ──

class WalletBalance {
  final double availableBalance;
  final double pendingBalance;
  final double totalEarned;
  final double totalWithdrawn;
  final String lastUpdated;

  WalletBalance({
    required this.availableBalance,
    required this.pendingBalance,
    required this.totalEarned,
    required this.totalWithdrawn,
    required this.lastUpdated,
  });

  factory WalletBalance.empty() => WalletBalance(
        availableBalance: 0,
        pendingBalance: 0,
        totalEarned: 0,
        totalWithdrawn: 0,
        lastUpdated: DateTime.now().toIso8601String(),
      );
}

class WalletTransaction {
  final String id;
  final String type;
  final double amount;
  final String status;
  final String description;
  final DateTime createdAt;
  final String? reference;

  WalletTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.status,
    required this.description,
    required this.createdAt,
    this.reference,
  });
}

class Withdrawal {
  final String id;
  final double amount;
  final String status;
  final String phoneNumber;
  final DateTime requestedAt;
  final DateTime? processedAt;
  final String? transactionId;
  final String? failureReason;

  Withdrawal({
    required this.id,
    required this.amount,
    required this.status,
    required this.phoneNumber,
    required this.requestedAt,
    this.processedAt,
    this.transactionId,
    this.failureReason,
  });
}

class WithdrawalResponse {
  final bool success;
  final String? withdrawalId;
  final String? message;
  final String? status;

  WithdrawalResponse({
    required this.success,
    this.withdrawalId,
    this.message,
    this.status,
  });

  factory WithdrawalResponse.failure(String message) =>
      WithdrawalResponse(success: false, message: message);
}

class MpesaPaymentStatus {
  final bool success;
  final String status;
  final String? message;
  final String? transactionId;
  final DateTime? completedAt;

  MpesaPaymentStatus({
    required this.success,
    required this.status,
    this.message,
    this.transactionId,
    this.completedAt,
  });

  factory MpesaPaymentStatus.failure(String message) =>
      MpesaPaymentStatus(success: false, status: 'failed', message: message);
}
EOF

echo "✅ wallet_repository.dart rewritten (Firebase)"

# ────────────────────────────────────────────────────────────
# FIX 7: Rewrite collection_repository.dart with Firebase params
# ────────────────────────────────────────────────────────────
cat > /home/delva/project/agri_waste_connected/lib/features/driver/data/repositories/collection_repository.dart << 'EOF'
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../../shared/models/waste_listing_model.dart';

class CollectionRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final FirebaseAuth _auth;

  CollectionRepository({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _storage = storage,
        _auth = auth;

  String get _uid => _auth.currentUser!.uid;

  Future<List<WasteListingModel>> getAssignedCollections({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      Query query = _firestore
          .collection('listings')
          .where('driverId', isEqualTo: _uid)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (status != null) query = query.where('status', isEqualTo: status);

      final snap = await query.get();
      return snap.docs.map((doc) {
        final d = doc.data() as Map<String, dynamic>;
        return WasteListingModel.fromJson({...d, 'id': doc.id});
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<WasteListingModel?> getCollectionDetails(
      String collectionId) async {
    try {
      final doc =
          await _firestore.collection('listings').doc(collectionId).get();
      if (!doc.exists) return null;
      return WasteListingModel.fromJson({...doc.data()!, 'id': doc.id});
    } catch (e) {
      return null;
    }
  }

  Future<bool> markArrival(String collectionId, {String? notes}) async {
    try {
      await _firestore.collection('listings').doc(collectionId).update({
        'status': 'inTransit',
        'arrivedAt': FieldValue.serverTimestamp(),
        'arrivalNotes': notes,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> recordWeight({
    required String collectionId,
    required double actualWeight,
    String? notes,
  }) async {
    try {
      await _firestore.collection('listings').doc(collectionId).update({
        'actualQuantity': actualWeight,
        'weightNotes': notes,
        'weighedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> submitQualityCheck({
    required String collectionId,
    required int rating,
    required String qualityNotes,
    List<String>? photoUrls,
  }) async {
    try {
      await _firestore.collection('listings').doc(collectionId).update({
        'qualityRating': rating,
        'qualityNotes': qualityNotes,
        'driverPhotoUrls': photoUrls ?? [],
        'qualityCheckedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> confirmPayment(String collectionId) async {
    try {
      await _firestore.collection('listings').doc(collectionId).update({
        'paymentConfirmed': true,
        'paymentConfirmedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> completeCollection(String collectionId) async {
    try {
      // Get listing to calculate payout
      final doc =
          await _firestore.collection('listings').doc(collectionId).get();
      final data = doc.data()!;
      final actualWeight =
          (data['actualQuantity'] ?? data['estimatedQuantity'] ?? 0)
              .toDouble();
      final wasteType = data['wasteType'] ?? 'cropResidue';

      // Get pricing
      final pricingDoc =
          await _firestore.collection('pricing').doc('config').get();
      final basePrices =
          Map<String, dynamic>.from(pricingDoc.data()?['basePrices'] ?? {});
      final pricePerKg =
          (basePrices[wasteType] ?? 5).toDouble();
      final finalPayout = actualWeight * pricePerKg;

      // Update listing as completed
      await _firestore.collection('listings').doc(collectionId).update({
        'status': 'completed',
        'finalPayout': finalPayout,
        'completedAt': FieldValue.serverTimestamp(),
      });

      // Create transaction record
      await _firestore.collection('transactions').add({
        'farmerId': data['farmerId'],
        'listingId': collectionId,
        'driverId': _uid,
        'amount': finalPayout,
        'wasteType': wasteType,
        'quantity': actualWeight,
        'type': 'credit',
        'status': 'pending_mpesa',
        'description': 'Payment for ${wasteType} - ${actualWeight}kg',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update farmer total earnings
      await _firestore
          .collection('users')
          .doc(data['farmerId'])
          .update({
        'totalEarnings': FieldValue.increment(finalPayout),
        'completedPickups': FieldValue.increment(1),
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<RoutineEvaluationResult> evaluateRoutine({
    required String collectionId,
    required int qualityRating,
    required bool shouldContinue,
    String? notes,
  }) async {
    try {
      final doc =
          await _firestore.collection('listings').doc(collectionId).get();
      final farmerId = doc.data()?['farmerId'];

      await _firestore.collection('listings').doc(collectionId).update({
        'routineEvaluation': {
          'qualityRating': qualityRating,
          'shouldContinue': shouldContinue,
          'notes': notes,
          'evaluatedAt': FieldValue.serverTimestamp(),
        }
      });

      // Update farmer consistency score
      if (farmerId != null) {
        final farmerDoc =
            await _firestore.collection('users').doc(farmerId).get();
        final currentScore =
            (farmerDoc.data()?['consistencyScore'] ?? 70).toDouble();
        final newScore = shouldContinue
            ? (currentScore + 2).clamp(0, 100).toDouble()
            : (currentScore - 5).clamp(0, 100).toDouble();

        await _firestore.collection('users').doc(farmerId).update({
          'consistencyScore': newScore,
        });

        return RoutineEvaluationResult(
          success: true,
          shouldContinue: shouldContinue,
          updatedConsistencyScore: newScore,
          message: 'Evaluation submitted successfully',
        );
      }

      return RoutineEvaluationResult(
          success: true, message: 'Evaluation submitted');
    } catch (e) {
      return RoutineEvaluationResult.failure('Failed to submit evaluation');
    }
  }

  Future<DriverDashboardStats> getDashboardStats() async {
    try {
      final allSnap = await _firestore
          .collection('listings')
          .where('driverId', isEqualTo: _uid)
          .get();

      final today = DateTime.now();
      final todayDocs = allSnap.docs.where((d) {
        final ts = d.data()['completedAt'] as Timestamp?;
        if (ts == null) return false;
        final date = ts.toDate();
        return date.year == today.year &&
            date.month == today.month &&
            date.day == today.day;
      });

      final completed =
          allSnap.docs.where((d) => d['status'] == 'completed').length;

      return DriverDashboardStats(
        assignedCollections: allSnap.docs
            .where((d) =>
                d['status'] == 'assigned' || d['status'] == 'inTransit')
            .length,
        completedToday: todayDocs.length,
        totalCompleted: completed,
        totalWasteCollected: 0,
        averageRating: 0,
        pendingEvaluations: 0,
      );
    } catch (e) {
      return DriverDashboardStats.empty();
    }
  }

  Future<bool> updateAvailability(bool isAvailable) async {
    try {
      await _firestore.collection('users').doc(_uid).update({
        'isAvailable': isAvailable,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<WasteListingModel>> getTodaySchedule() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    try {
      final snap = await _firestore
          .collection('listings')
          .where('driverId', isEqualTo: _uid)
          .where('scheduledDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('scheduledDate',
              isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      return snap.docs.map((doc) {
        final d = doc.data();
        return WasteListingModel.fromJson({...d, 'id': doc.id});
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<String?> uploadCollectionPhoto(
      String collectionId, String photoPath) async {
    try {
      final file = File(photoPath);
      final ref = _storage.ref().child(
          'collections/$collectionId/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  Future<void> syncOfflineCollections() async {
    // Firestore handles sync automatically via persistence setting
  }
}

// ── Model classes ──

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

  factory DriverDashboardStats.empty() => DriverDashboardStats(
        assignedCollections: 0,
        completedToday: 0,
        totalCompleted: 0,
        totalWasteCollected: 0,
        averageRating: 0,
        pendingEvaluations: 0,
      );
}

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

  factory RoutineEvaluationResult.failure(String message) =>
      RoutineEvaluationResult(success: false, message: message);
}
EOF

echo "✅ collection_repository.dart rewritten (Firebase)"

# ────────────────────────────────────────────────────────────
# FIX 8: Rewrite admin_repositories.dart with Firebase params
# ────────────────────────────────────────────────────────────
cat > /home/delva/project/agri_waste_connected/lib/features/admin/data/repositories/admin_repositories.dart << 'EOF'
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
      final listings =
          await _firestore.collection('listings').get();

      final pending = listings.docs
          .where((d) => d['status'] == 'pending')
          .length;

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

  // ── PRICING ──

  Future<PricingConfig> getPricingConfig() async {
    try {
      final doc =
          await _firestore.collection('pricing').doc('config').get();
      if (!doc.exists) return PricingConfig.empty();
      final data = doc.data()!;
      return PricingConfig(
        premiumThreshold: (data['premiumThreshold'] ?? 70).toDouble(),
        basePrices: Map<String, double>.from(
            (data['basePrices'] as Map).map(
                (k, v) => MapEntry(k, (v as num).toDouble()))),
        premiumPrices: Map<String, double>.from(
            (data['premiumPrices'] as Map).map(
                (k, v) => MapEntry(k, (v as num).toDouble()))),
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
          .map((doc) =>
              UserModel.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id}))
          .toList();

      if (search != null && search.isNotEmpty) {
        return farmers
            .where((f) => f.fullName
                .toLowerCase()
                .contains(search.toLowerCase()))
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

// ── Model classes ──

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

  factory DriverModel.fromJson(Map<String, dynamic> json) => DriverModel(
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
  factory InventoryAlert.fromJson(Map<String, dynamic> json) =>
      InventoryAlert(
          wasteType: json['waste_type'],
          message: json['message'],
          severity: json['severity']);
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

  factory RoutineRoute.fromJson(Map<String, dynamic> json) => RoutineRoute(
        id: json['id'],
        name: json['name'],
        dayOfWeek: json['day_of_week'],
        farmerIds: List<String>.from(json['farmer_ids'] ?? []),
        farmerNames: List<String>.from(json['farmer_names'] ?? []),
        driverId: json['driver_id'],
        driverName: json['driver_name'],
        isActive: json['is_active'] ?? true,
      );

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

  factory MonthlyData.fromJson(Map<String, dynamic> json) => MonthlyData(
      month: json['month'],
      pickups: json['pickups'] ?? 0,
      earnings: (json['earnings'] ?? 0).toDouble());
}

class ReportData {
  final String reportUrl;
  final Map<String, dynamic> summary;

  ReportData({required this.reportUrl, required this.summary});

  factory ReportData.empty() =>
      ReportData(reportUrl: '', summary: {});
}
EOF

echo "✅ admin_repositories.dart rewritten (Firebase)"

# ────────────────────────────────────────────────────────────
# DONE — now run:
# ────────────────────────────────────────────────────────────
echo ""
echo "════════════════════════════════════════════════════════"
echo "  ALL FILES WRITTEN. Now run:"
echo ""
echo "  flutter pub get"
echo "  flutter run"
echo ""
echo "  If you still see firebase_options errors, fill in"
echo "  your values in lib/firebase_options.dart OR run:"
echo "  flutterfire configure"
echo "════════════════════════════════════════════════════════"
