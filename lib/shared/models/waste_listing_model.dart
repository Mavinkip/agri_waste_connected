// lib/shared/models/waste_listing_model.dart
import 'package:equatable/equatable.dart';

enum WasteType {
  cropResidue,
  fruitWaste,
  vegetableWaste,
  livestockManure,
  coffeeHusks,
  riceHulls,
  cornStover,
  other,
}

enum ListingStatus {
  pending,
  assigned,
  inTransit,
  completed,
  cancelled,
}

enum PickupType {
  routine,
  manual,
}

class WasteListingModel extends Equatable {
  final String id;
  final String farmerId;
  final String farmerName;
  final WasteType wasteType;
  final double estimatedQuantity;
  final double? actualQuantity;
  final String? photos;
  final String pickupLat;
  final String pickupLng;
  final String pickupAddress;
  final PickupType pickupType;
  final ListingStatus status;
  final String? driverId;
  final String? driverName;
  final int? qualityRating;
  final String? qualityNotes;
  final double? finalPayout;
  final String? transactionId;
  final DateTime createdAt;
  final DateTime? scheduledDate;
  final DateTime? pickupDate;
  final DateTime? completedDate;
  final bool isPhotoRequired;
  final String? notes;
  
  const WasteListingModel({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    required this.wasteType,
    required this.estimatedQuantity,
    this.actualQuantity,
    this.photos,
    required this.pickupLat,
    required this.pickupLng,
    required this.pickupAddress,
    required this.pickupType,
    required this.status,
    this.driverId,
    this.driverName,
    this.qualityRating,
    this.qualityNotes,
    this.finalPayout,
    this.transactionId,
    required this.createdAt,
    this.scheduledDate,
    this.pickupDate,
    this.completedDate,
    this.isPhotoRequired = true,
    this.notes,
  });
  
  factory WasteListingModel.fromJson(Map<String, dynamic> json) {
    return WasteListingModel(
      id: json['id'] as String,
      farmerId: json['farmerId'] as String,
      farmerName: json['farmerName'] as String,
      wasteType: _stringToWasteType(json['wasteType'] as String),
      estimatedQuantity: (json['estimatedQuantity'] as num).toDouble(),
      actualQuantity: (json['actualQuantity'] as num?)?.toDouble(),
      photos: json['photos'] as String?,
      pickupLat: json['pickupLat'] as String,
      pickupLng: json['pickupLng'] as String,
      pickupAddress: json['pickupAddress'] as String,
      pickupType: json['pickupType'] == 'routine' ? PickupType.routine : PickupType.manual,
      status: _stringToListingStatus(json['status'] as String),
      driverId: json['driverId'] as String?,
      driverName: json['driverName'] as String?,
      qualityRating: json['qualityRating'] as int?,
      qualityNotes: json['qualityNotes'] as String?,
      finalPayout: (json['finalPayout'] as num?)?.toDouble(),
      transactionId: json['transactionId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      scheduledDate: json['scheduledDate'] != null 
          ? DateTime.parse(json['scheduledDate'] as String) 
          : null,
      pickupDate: json['pickupDate'] != null 
          ? DateTime.parse(json['pickupDate'] as String) 
          : null,
      completedDate: json['completedDate'] != null 
          ? DateTime.parse(json['completedDate'] as String) 
          : null,
      isPhotoRequired: json['isPhotoRequired'] as bool? ?? true,
      notes: json['notes'] as String?,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'wasteType': _wasteTypeToString(wasteType),
      'estimatedQuantity': estimatedQuantity,
      'actualQuantity': actualQuantity,
      'photos': photos,
      'pickupLat': pickupLat,
      'pickupLng': pickupLng,
      'pickupAddress': pickupAddress,
      'pickupType': pickupType == PickupType.routine ? 'routine' : 'manual',
      'status': _listingStatusToString(status),
      'driverId': driverId,
      'driverName': driverName,
      'qualityRating': qualityRating,
      'qualityNotes': qualityNotes,
      'finalPayout': finalPayout,
      'transactionId': transactionId,
      'createdAt': createdAt.toIso8601String(),
      'scheduledDate': scheduledDate?.toIso8601String(),
      'pickupDate': pickupDate?.toIso8601String(),
      'completedDate': completedDate?.toIso8601String(),
      'isPhotoRequired': isPhotoRequired,
      'notes': notes,
    };
  }
  
  static WasteType _stringToWasteType(String type) {
    switch (type) {
      case 'cropResidue': return WasteType.cropResidue;
      case 'fruitWaste': return WasteType.fruitWaste;
      case 'vegetableWaste': return WasteType.vegetableWaste;
      case 'livestockManure': return WasteType.livestockManure;
      case 'coffeeHusks': return WasteType.coffeeHusks;
      case 'riceHulls': return WasteType.riceHulls;
      case 'cornStover': return WasteType.cornStover;
      default: return WasteType.other;
    }
  }
  
  static String _wasteTypeToString(WasteType type) {
    switch (type) {
      case WasteType.cropResidue: return 'cropResidue';
      case WasteType.fruitWaste: return 'fruitWaste';
      case WasteType.vegetableWaste: return 'vegetableWaste';
      case WasteType.livestockManure: return 'livestockManure';
      case WasteType.coffeeHusks: return 'coffeeHusks';
      case WasteType.riceHulls: return 'riceHulls';
      case WasteType.cornStover: return 'cornStover';
      case WasteType.other: return 'other';
    }
  }
  
  static ListingStatus _stringToListingStatus(String status) {
    switch (status) {
      case 'pending': return ListingStatus.pending;
      case 'assigned': return ListingStatus.assigned;
      case 'inTransit': return ListingStatus.inTransit;
      case 'completed': return ListingStatus.completed;
      case 'cancelled': return ListingStatus.cancelled;
      default: return ListingStatus.pending;
    }
  }
  
  static String _listingStatusToString(ListingStatus status) {
    switch (status) {
      case ListingStatus.pending: return 'pending';
      case ListingStatus.assigned: return 'assigned';
      case ListingStatus.inTransit: return 'inTransit';
      case ListingStatus.completed: return 'completed';
      case ListingStatus.cancelled: return 'cancelled';
    }
  }
  
  @override
  List<Object?> get props => [
        id,
        farmerId,
        wasteType,
        estimatedQuantity,
        actualQuantity,
        status,
        pickupType,
        createdAt,
      ];
  
  bool get isRoutine => pickupType == PickupType.routine;
  bool get isManual => pickupType == PickupType.manual;
  bool get isCompleted => status == ListingStatus.completed;
  bool get isPending => status == ListingStatus.pending;
  bool get isAssigned => status == ListingStatus.assigned;
  
  double get payoutAmount {
    if (finalPayout != null) return finalPayout!;
    if (actualQuantity != null) {
      return actualQuantity! * 5.0;
    }
    return 0.0;
  }
  
  WasteListingModel copyWith({
    String? id,
    String? farmerId,
    String? farmerName,
    WasteType? wasteType,
    double? estimatedQuantity,
    double? actualQuantity,
    String? photos,
    String? pickupLat,
    String? pickupLng,
    String? pickupAddress,
    PickupType? pickupType,
    ListingStatus? status,
    String? driverId,
    String? driverName,
    int? qualityRating,
    String? qualityNotes,
    double? finalPayout,
    String? transactionId,
    DateTime? createdAt,
    DateTime? scheduledDate,
    DateTime? pickupDate,
    DateTime? completedDate,
    bool? isPhotoRequired,
    String? notes,
  }) {
    return WasteListingModel(
      id: id ?? this.id,
      farmerId: farmerId ?? this.farmerId,
      farmerName: farmerName ?? this.farmerName,
      wasteType: wasteType ?? this.wasteType,
      estimatedQuantity: estimatedQuantity ?? this.estimatedQuantity,
      actualQuantity: actualQuantity ?? this.actualQuantity,
      photos: photos ?? this.photos,
      pickupLat: pickupLat ?? this.pickupLat,
      pickupLng: pickupLng ?? this.pickupLng,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      pickupType: pickupType ?? this.pickupType,
      status: status ?? this.status,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      qualityRating: qualityRating ?? this.qualityRating,
      qualityNotes: qualityNotes ?? this.qualityNotes,
      finalPayout: finalPayout ?? this.finalPayout,
      transactionId: transactionId ?? this.transactionId,
      createdAt: createdAt ?? this.createdAt,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      pickupDate: pickupDate ?? this.pickupDate,
      completedDate: completedDate ?? this.completedDate,
      isPhotoRequired: isPhotoRequired ?? this.isPhotoRequired,
      notes: notes ?? this.notes,
    );
  }
}
