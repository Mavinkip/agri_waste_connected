import 'package:equatable/equatable.dart';

class RecyclingCompanyModel extends Equatable {
  final String id;
  final String name;
  final String contactPerson;
  final String phone;
  final String email;
  final String county;
  final String address;
  final double lat;
  final double lng;
  final List<String> wasteTypesAccepted;
  final Map<String, double> buyingPrices; // wasteType -> KSh per kg
  final bool isActive;
  final DateTime createdAt;

  const RecyclingCompanyModel({
    required this.id,
    required this.name,
    required this.contactPerson,
    required this.phone,
    required this.email,
    required this.county,
    required this.address,
    required this.lat,
    required this.lng,
    this.wasteTypesAccepted = const [],
    this.buyingPrices = const {},
    this.isActive = true,
    required this.createdAt,
  });

  factory RecyclingCompanyModel.fromJson(Map<String, dynamic> json) =>
      RecyclingCompanyModel(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        contactPerson: json['contactPerson'] ?? '',
        phone: json['phone'] ?? '',
        email: json['email'] ?? '',
        county: json['county'] ?? '',
        address: json['address'] ?? '',
        lat: (json['lat'] ?? 0).toDouble(),
        lng: (json['lng'] ?? 0).toDouble(),
        wasteTypesAccepted:
        List<String>.from(json['wasteTypesAccepted'] ?? []),
        buyingPrices: Map<String, double>.from(
            (json['buyingPrices'] ?? {})
                .map((k, v) => MapEntry(k, (v as num).toDouble()))),
        isActive: json['isActive'] ?? true,
        createdAt: json['createdAt'] is String
            ? DateTime.parse(json['createdAt'])
            : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'contactPerson': contactPerson,
    'phone': phone,
    'email': email,
    'county': county,
    'address': address,
    'lat': lat,
    'lng': lng,
    'wasteTypesAccepted': wasteTypesAccepted,
    'buyingPrices': buyingPrices,
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
  };

  @override
  List<Object?> get props => [id, name, isActive];
}