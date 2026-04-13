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
