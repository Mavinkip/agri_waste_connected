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

  Future<WasteListingModel?> getCollectionDetails(String collectionId) async {
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
          (data['actualQuantity'] ?? data['estimatedQuantity'] ?? 0).toDouble();
      final wasteType = data['wasteType'] ?? 'cropResidue';

      // Get pricing
      final pricingDoc =
          await _firestore.collection('pricing').doc('config').get();
      final basePrices =
          Map<String, dynamic>.from(pricingDoc.data()?['basePrices'] ?? {});
      final pricePerKg = (basePrices[wasteType] ?? 5).toDouble();
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
        'description': 'Payment for $wasteType - ${actualWeight}kg',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update farmer total earnings
      await _firestore.collection('users').doc(data['farmerId']).update({
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
            .where(
                (d) => d['status'] == 'assigned' || d['status'] == 'inTransit')
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
          .where('scheduledDate', isLessThan: Timestamp.fromDate(endOfDay))
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
