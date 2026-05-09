import 'package:equatable/equatable.dart';

enum CommunityStatus { forming, active, collected, completed }

class CommunityModel extends Equatable {
  final String id;
  final String name;
  final String adminId;
  final String county;
  final String subCounty;
  final String ward;
  final double targetWeightKg;
  final double currentEstimatedKg;
  final double actualCollectedKg;
  final String? collectionPointFarmerId;
  final String? collectionPointFarmerName;
  final String? collectionPointAddress;
  final double? collectionPointLat;
  final double? collectionPointLng;
  final List<String> farmerIds;
  final String? assignedDriverId;
  final String? assignedCompanyId;
  final CommunityStatus status;
  final DateTime createdAt;
  final DateTime? targetDate;

  const CommunityModel({
    required this.id,
    required this.name,
    required this.adminId,
    required this.county,
    required this.subCounty,
    required this.ward,
    required this.targetWeightKg,
    this.currentEstimatedKg = 0,
    this.actualCollectedKg = 0,
    this.collectionPointFarmerId,
    this.collectionPointFarmerName,
    this.collectionPointAddress,
    this.collectionPointLat,
    this.collectionPointLng,
    this.farmerIds = const [],
    this.assignedDriverId,
    this.assignedCompanyId,
    this.status = CommunityStatus.forming,
    required this.createdAt,
    this.targetDate,
  });

  double get progressPercent =>
      targetWeightKg > 0
          ? (currentEstimatedKg / targetWeightKg).clamp(0.0, 1.0)
          : 0.0;

  bool get targetReached => currentEstimatedKg >= targetWeightKg;

  factory CommunityModel.fromJson(Map<String, dynamic> json) =>
      CommunityModel(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        adminId: json['adminId'] ?? '',
        county: json['county'] ?? '',
        subCounty: json['subCounty'] ?? '',
        ward: json['ward'] ?? '',
        targetWeightKg: (json['targetWeightKg'] ?? 0).toDouble(),
        currentEstimatedKg:
        (json['currentEstimatedKg'] ?? 0).toDouble(),
        actualCollectedKg:
        (json['actualCollectedKg'] ?? 0).toDouble(),
        collectionPointFarmerId: json['collectionPointFarmerId'],
        collectionPointFarmerName: json['collectionPointFarmerName'],
        collectionPointAddress: json['collectionPointAddress'],
        collectionPointLat:
        (json['collectionPointLat'] as num?)?.toDouble(),
        collectionPointLng:
        (json['collectionPointLng'] as num?)?.toDouble(),
        farmerIds: List<String>.from(json['farmerIds'] ?? []),
        assignedDriverId: json['assignedDriverId'],
        assignedCompanyId: json['assignedCompanyId'],
        status: _statusFromString(json['status'] ?? 'forming'),
        createdAt: json['createdAt'] is String
            ? DateTime.parse(json['createdAt'])
            : DateTime.now(),
        targetDate: json['targetDate'] != null
            ? DateTime.parse(json['targetDate'])
            : null,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'adminId': adminId,
    'county': county,
    'subCounty': subCounty,
    'ward': ward,
    'targetWeightKg': targetWeightKg,
    'currentEstimatedKg': currentEstimatedKg,
    'actualCollectedKg': actualCollectedKg,
    'collectionPointFarmerId': collectionPointFarmerId,
    'collectionPointFarmerName': collectionPointFarmerName,
    'collectionPointAddress': collectionPointAddress,
    'collectionPointLat': collectionPointLat,
    'collectionPointLng': collectionPointLng,
    'farmerIds': farmerIds,
    'assignedDriverId': assignedDriverId,
    'assignedCompanyId': assignedCompanyId,
    'status': _statusToString(status),
    'createdAt': createdAt.toIso8601String(),
    'targetDate': targetDate?.toIso8601String(),
  };

  static CommunityStatus _statusFromString(String s) {
    switch (s) {
      case 'active': return CommunityStatus.active;
      case 'collected': return CommunityStatus.collected;
      case 'completed': return CommunityStatus.completed;
      default: return CommunityStatus.forming;
    }
  }

  static String _statusToString(CommunityStatus s) {
    switch (s) {
      case CommunityStatus.active: return 'active';
      case CommunityStatus.collected: return 'collected';
      case CommunityStatus.completed: return 'completed';
      default: return 'forming';
    }
  }

  @override
  List<Object?> get props => [id, name, status, currentEstimatedKg];
}