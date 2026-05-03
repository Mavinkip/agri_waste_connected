// lib/shared/models/user_model.dart
import 'package:equatable/equatable.dart';

enum UserRole {
  farmer,
  driver,
  admin,
}

class UserModel extends Equatable {
  final String id;
  final String phoneNumber;
  final String fullName;
  final UserRole role;
  final String? email;
  final String? profileImageUrl;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  
  // Farmer-specific fields
  final String? farmLocationLat;
  final String? farmLocationLng;
  final String? farmAddress;
  final double? consistencyScore;
  final double? totalEarnings;
  final int? completedPickups;
  
  // Driver-specific fields
  final String? vehicleNumber;
  final String? vehicleType;
  final bool? isAvailable;
  final int? completedDeliveries;
  
  // Admin-specific fields
  final String? department;
  final String? accessLevel;
  
  const UserModel({
    required this.id,
    required this.phoneNumber,
    required this.fullName,
    required this.role,
    this.email,
    this.profileImageUrl,
    this.isVerified = false,
    required this.createdAt,
    this.lastLoginAt,
    this.farmLocationLat,
    this.farmLocationLng,
    this.farmAddress,
    this.consistencyScore,
    this.totalEarnings,
    this.completedPickups,
    this.vehicleNumber,
    this.vehicleType,
    this.isAvailable,
    this.completedDeliveries,
    this.department,
    this.accessLevel,
  });
  
  // Manual fromJson - no code generation needed
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      phoneNumber: json['phoneNumber'] as String,
      fullName: json['fullName'] as String,
      role: _stringToRole(json['role'] as String),
      email: json['email'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: json['lastLoginAt'] != null 
          ? DateTime.parse(json['lastLoginAt'] as String) 
          : null,
      farmLocationLat: json['farmLocationLat'] as String?,
      farmLocationLng: json['farmLocationLng'] as String?,
      farmAddress: json['farmAddress'] as String?,
      consistencyScore: (json['consistencyScore'] as num?)?.toDouble(),
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble(),
      completedPickups: json['completedPickups'] as int?,
      vehicleNumber: json['vehicleNumber'] as String?,
      vehicleType: json['vehicleType'] as String?,
      isAvailable: json['isAvailable'] as bool?,
      completedDeliveries: json['completedDeliveries'] as int?,
      department: json['department'] as String?,
      accessLevel: json['accessLevel'] as String?,
    );
  }
  
  // Manual toJson - no code generation needed
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'fullName': fullName,
      'role': _roleToString(role),
      'email': email,
      'profileImageUrl': profileImageUrl,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'farmLocationLat': farmLocationLat,
      'farmLocationLng': farmLocationLng,
      'farmAddress': farmAddress,
      'consistencyScore': consistencyScore,
      'totalEarnings': totalEarnings,
      'completedPickups': completedPickups,
      'vehicleNumber': vehicleNumber,
      'vehicleType': vehicleType,
      'isAvailable': isAvailable,
      'completedDeliveries': completedDeliveries,
      'department': department,
      'accessLevel': accessLevel,
    };
  }
  
  static UserRole _stringToRole(String role) {
    switch (role) {
      case 'farmer': return UserRole.farmer;
      case 'driver': return UserRole.driver;
      case 'admin': return UserRole.admin;
      default: return UserRole.farmer;
    }
  }
  
  static String _roleToString(UserRole role) {
    switch (role) {
      case UserRole.farmer: return 'farmer';
      case UserRole.driver: return 'driver';
      case UserRole.admin: return 'admin';
    }
  }
  
  @override
  List<Object?> get props => [
        id,
        phoneNumber,
        fullName,
        role,
        email,
        profileImageUrl,
        isVerified,
        createdAt,
        lastLoginAt,
      ];
  
  UserModel copyWith({
    String? id,
    String? phoneNumber,
    String? fullName,
    UserRole? role,
    String? email,
    String? profileImageUrl,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    String? farmLocationLat,
    String? farmLocationLng,
    String? farmAddress,
    double? consistencyScore,
    double? totalEarnings,
    int? completedPickups,
    String? vehicleNumber,
    String? vehicleType,
    bool? isAvailable,
    int? completedDeliveries,
    String? department,
    String? accessLevel,
  }) {
    return UserModel(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      farmLocationLat: farmLocationLat ?? this.farmLocationLat,
      farmLocationLng: farmLocationLng ?? this.farmLocationLng,
      farmAddress: farmAddress ?? this.farmAddress,
      consistencyScore: consistencyScore ?? this.consistencyScore,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      completedPickups: completedPickups ?? this.completedPickups,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      vehicleType: vehicleType ?? this.vehicleType,
      isAvailable: isAvailable ?? this.isAvailable,
      completedDeliveries: completedDeliveries ?? this.completedDeliveries,
      department: department ?? this.department,
      accessLevel: accessLevel ?? this.accessLevel,
    );
  }
}
