class UserModel {
  final String uid;
  final String name;
  final String phone;
  final String role;
  final String county;
  final String subCounty;
  final List<String> communityIds;
  final double? latitude;
  final double? longitude;
  final double totalEarnings;
  final double consistencyScore;

  const UserModel({
    required this.uid,
    required this.name,
    required this.phone,
    required this.role,
    required this.county,
    required this.subCounty,
    this.communityIds = const [],
    this.latitude,
    this.longitude,
    this.totalEarnings = 0,
    this.consistencyScore = 0,
  });

  factory UserModel.fromMap(String uid, Map<String, dynamic> data) {
    return UserModel(
      uid: uid,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      role: data['role'] ?? 'farmer',
      county: data['county'] ?? '',
      subCounty: data['subCounty'] ?? '',
      communityIds: List<String>.from(data['communityIds'] ?? []),
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      totalEarnings: (data['totalEarnings'] as num?)?.toDouble() ?? 0,
      consistencyScore: (data['consistencyScore'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'phone': phone,
    'role': role,
    'county': county,
    'subCounty': subCounty,
    'communityIds': communityIds,
    'latitude': latitude,
    'longitude': longitude,
    'totalEarnings': totalEarnings,
    'consistencyScore': consistencyScore,
  };

  UserModel copyWith({List<String>? communityIds}) => UserModel(
    uid: uid, name: name, phone: phone, role: role,
    county: county, subCounty: subCounty,
    communityIds: communityIds ?? this.communityIds,
    latitude: latitude, longitude: longitude,
    totalEarnings: totalEarnings, consistencyScore: consistencyScore,
  );
}
