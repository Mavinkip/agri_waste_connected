import 'package:equatable/equatable.dart';

class County extends Equatable {
  final String id;
  final String name;
  final List<SubCounty> subCounties;
  final DateTime lastUpdated;
  final String? updatedBy;

  const County({
    required this.id,
    required this.name,
    required this.subCounties,
    required this.lastUpdated,
    this.updatedBy,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'subCounties': subCounties.map((s) => s.toJson()).toList(),
    'lastUpdated': lastUpdated.toIso8601String(),
    'updatedBy': updatedBy,
  };

  factory County.fromJson(Map<String, dynamic> json) => County(
    id: json['id'] ?? json['name'].toLowerCase().replaceAll(' ', '_'),
    name: json['name'],
    subCounties: (json['subCounties'] as List).map((s) => SubCounty.fromJson(s)).toList(),
    lastUpdated: DateTime.parse(json['lastUpdated']),
    updatedBy: json['updatedBy'],
  );

  @override
  List<Object?> get props => [id, name, subCounties, lastUpdated];
}

class SubCounty extends Equatable {
  final String name;
  final List<String> wards;

  const SubCounty({required this.name, required this.wards});

  Map<String, dynamic> toJson() => {'name': name, 'wards': wards};
  factory SubCounty.fromJson(Map<String, dynamic> json) => SubCounty(
    name: json['name'],
    wards: List<String>.from(json['wards']),
  );

  @override
  List<Object?> get props => [name, wards];
}

class CollectionSchedule extends Equatable {
  final String id;
  final String wasteType;
  final String dayOfWeek;
  final String timeSlot;
  final String countyName;
  final String subCountyName;
  final List<String> wards;
  final bool isActive;
  final int maxCapacityKg;
  final String? driverId;
  final DateTime lastUpdated;

  const CollectionSchedule({
    required this.id,
    required this.wasteType,
    required this.dayOfWeek,
    required this.timeSlot,
    required this.countyName,
    required this.subCountyName,
    required this.wards,
    this.isActive = true,
    this.maxCapacityKg = 500,
    this.driverId,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'wasteType': wasteType,
    'dayOfWeek': dayOfWeek,
    'timeSlot': timeSlot,
    'countyName': countyName,
    'subCountyName': subCountyName,
    'wards': wards,
    'isActive': isActive,
    'maxCapacityKg': maxCapacityKg,
    'driverId': driverId,
    'lastUpdated': lastUpdated.toIso8601String(),
  };

  factory CollectionSchedule.fromJson(Map<String, dynamic> json) => CollectionSchedule(
    id: json['id'],
    wasteType: json['wasteType'],
    dayOfWeek: json['dayOfWeek'],
    timeSlot: json['timeSlot'],
    countyName: json['countyName'],
    subCountyName: json['subCountyName'],
    wards: List<String>.from(json['wards']),
    isActive: json['isActive'] ?? true,
    maxCapacityKg: json['maxCapacityKg'] ?? 500,
    driverId: json['driverId'],
    lastUpdated: DateTime.parse(json['lastUpdated']),
  );

  @override
  List<Object?> get props => [id, wasteType, dayOfWeek, countyName, isActive];
}
