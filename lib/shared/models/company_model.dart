import 'package:cloud_firestore/cloud_firestore.dart';

class CompanyModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String county;
  final String subCounty;
  final String ward;
  final String address;
  final bool isActive;
  final double totalWasteProcessed;
  final double totalPaid;
  final DateTime createdAt;
  final Map<String, double> priceList; // wasteType -> price per kg

  CompanyModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.county,
    required this.subCounty,
    required this.ward,
    required this.address,
    this.isActive = true,
    this.totalWasteProcessed = 0,
    this.totalPaid = 0,
    required this.createdAt,
    this.priceList = const {},
  });

  factory CompanyModel.fromMap(String id, Map<String, dynamic> data) {
    return CompanyModel(
      id: id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      county: data['county'] ?? '',
      subCounty: data['subCounty'] ?? '',
      ward: data['ward'] ?? '',
      address: data['address'] ?? '',
      isActive: data['isActive'] ?? true,
      totalWasteProcessed: (data['totalWasteProcessed'] ?? 0).toDouble(),
      totalPaid: (data['totalPaid'] ?? 0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      priceList: Map<String, double>.from(data['priceList'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'phone': phone,
    'email': email,
    'county': county,
    'subCounty': subCounty,
    'ward': ward,
    'address': address,
    'isActive': isActive,
    'totalWasteProcessed': totalWasteProcessed,
    'totalPaid': totalPaid,
    'createdAt': Timestamp.fromDate(createdAt),
    'priceList': priceList,
  };
}
