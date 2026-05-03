#!/bin/bash

# Agri-Waste Connect - File Creation Script
# Run this from your project root: /home/delva/project/agri_waste_connected

echo "🌿 Creating Agri-Waste Connect files..."

# Create directory structure if not exists
mkdir -p lib/core/constants
mkdir -p lib/core/network
mkdir -p lib/core/services
mkdir -p lib/shared/models
mkdir -p lib/shared/services

# ============================================
# Step 1.1: app_colors.dart
# ============================================
cat > lib/core/constants/app_colors.dart << 'EOF'
// lib/core/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Primary brand colors
  static const Color primaryGreen = Color(0xFF1A7A4A);
  static const Color primaryBlue = Color(0xFF1C4E80);
  static const Color primaryOrange = Color(0xFFD46B08);
  
  // Secondary colors
  static const Color secondaryGreen = Color(0xFF2E9E64);
  static const Color secondaryBlue = Color(0xFF2A6B9E);
  static const Color secondaryOrange = Color(0xFFFA8C16);
  
  // Neutral colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFF5F5F5);
  static const Color lightGray = Color(0xFFE0E0E0);
  static const Color mediumGray = Color(0xFF9E9E9E);
  static const Color darkGray = Color(0xFF424242);
  static const Color black = Color(0xFF212121);
  
  // Semantic colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Background colors
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color backgroundDark = Color(0xFF121212);
  
  // Card and surface colors
  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF1E1E1E);
  
  // Gradient definitions
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryGreen, secondaryGreen],
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryOrange, secondaryOrange],
  );
  
  // Shadow
  static const BoxShadow cardShadow = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 8,
    offset: Offset(0, 2),
  );
}
EOF
echo "✅ Created lib/core/constants/app_colors.dart"

# ============================================
# Step 1.2: app_strings.dart
# ============================================
cat > lib/core/constants/app_strings.dart << 'EOF'
// lib/core/constants/app_strings.dart
class AppStrings {
  // App name
  static const String appName = 'Agri-Waste Connect';
  
  // Auth screens
  static const String loginTitle = 'Welcome Back';
  static const String loginSubtitle = 'Sign in to continue';
  static const String registerTitle = 'Create Account';
  static const String registerSubtitle = 'Join the agricultural waste revolution';
  static const String phoneNumber = 'Phone Number';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String fullName = 'Full Name';
  static const String login = 'Login';
  static const String register = 'Register';
  static const String forgotPassword = 'Forgot Password?';
  static const String dontHaveAccount = 'Don\'t have an account? ';
  static const String alreadyHaveAccount = 'Already have an account? ';
  static const String signUp = 'Sign Up';
  
  // Role strings
  static const String roleFarmer = 'Farmer';
  static const String roleDriver = 'Driver';
  static const String roleAdmin = 'Administrator';
  
  // Waste types
  static const String cropResidue = 'Crop Residue';
  static const String fruitWaste = 'Fruit Waste';
  static const String vegetableWaste = 'Vegetable Waste';
  static const String livestockManure = 'Livestock Manure';
  static const String coffeeHusks = 'Coffee Husks';
  static const String riceHulls = 'Rice Hulls';
  static const String cornStover = 'Corn Stover';
  static const String other = 'Other';
  
  // Units
  static const String kg = 'kg';
  static const String ton = 'ton';
  static const String tons = 'tons';
  
  // Common actions
  static const String submit = 'Submit';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String back = 'Back';
  static const String next = 'Next';
  static const String save = 'Save';
  static const String edit = 'Edit';
  static const String delete = 'Delete';
  static const String close = 'Close';
  
  // Error messages
  static const String networkError = 'Network connection error';
  static const String serverError = 'Server error occurred';
  static const String authError = 'Authentication failed';
  static const String invalidPhone = 'Please enter a valid phone number';
  static const String invalidPassword = 'Password must be at least 6 characters';
  static const String passwordsDoNotMatch = 'Passwords do not match';
  static const String requiredField = 'This field is required';
  static const String somethingWentWrong = 'Something went wrong. Please try again.';
  
  // Success messages
  static const String loginSuccess = 'Login successful!';
  static const String registerSuccess = 'Registration successful!';
  static const String listingCreated = 'Waste listing created successfully';
  static const String paymentProcessed = 'Payment processed successfully';
  
  // Farmer screens
  static const String farmerHome = 'Farmer Dashboard';
  static const String sellWaste = 'Sell Waste';
  static const String myEarnings = 'My Earnings';
  static const String mySchedule = 'My Schedule';
  static const String totalEarned = 'Total Earned';
  static const String activeListings = 'Active Listings';
  static const String completedSales = 'Completed Sales';
  static const String consistencyScore = 'Consistency Score';
  
  // Sell wizard
  static const String selectWasteType = 'Select Waste Type';
  static const String enterQuantity = 'Enter Quantity';
  static const String estimatedWeight = 'Estimated Weight';
  static const String addPhotos = 'Add Photos (Optional)';
  static const String confirmPickupLocation = 'Confirm Pickup Location';
  static const String listingSuccess = 'Listing Created!';
  static const String driverWillContact = 'A driver will contact you shortly';
  
  // Driver screens
  static const String driverHome = 'Driver Dashboard';
  static const String assignedCollections = 'Assigned Collections';
  static const String completePickup = 'Complete Pickup';
  static const String weighWaste = 'Weigh Waste';
  static const String qualityCheck = 'Quality Check';
  static const String confirmPayment = 'Confirm Payment';
  static const String routineEvaluation = 'Routine Evaluation';
  
  // Admin screens
  static const String adminDashboard = 'Admin Dashboard';
  static const String fleetManagement = 'Fleet Management';
  static const String pricingManagement = 'Pricing Management';
  static const String inventoryManagement = 'Inventory Management';
  static const String routeManagement = 'Route Management';
  
  // M-Pesa
  static const String mpesaPayment = 'M-Pesa Payment';
  static const String paymentConfirmation = 'Payment Confirmation';
  static const String paymentSuccessful = 'Payment Successful!';
  static const String transactionId = 'Transaction ID';
  
  // USSD
  static const String ussdCode = '*384*50#';
  static const String ussdMessage = 'Dial $ussdCode to access our USSD service';
  
  // Offline
  static const String offlineMode = 'You are offline';
  static const String syncing = 'Syncing data...';
  static const String syncComplete = 'Sync complete';
}
EOF
echo "✅ Created lib/core/constants/app_strings.dart"

# ============================================
# Step 1.3: user_model.dart
# ============================================
cat > lib/shared/models/user_model.dart << 'EOF'
// lib/shared/models/user_model.dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

enum UserRole {
  @JsonValue('farmer')
  farmer,
  @JsonValue('driver')
  driver,
  @JsonValue('admin')
  admin,
}

@JsonSerializable()
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
  
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
  
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
EOF
echo "✅ Created lib/shared/models/user_model.dart"

# ============================================
# Step 1.4: waste_listing_model.dart
# ============================================
cat > lib/shared/models/waste_listing_model.dart << 'EOF'
// lib/shared/models/waste_listing_model.dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'waste_listing_model.g.dart';

enum WasteType {
  @JsonValue('crop_residue')
  cropResidue,
  @JsonValue('fruit_waste')
  fruitWaste,
  @JsonValue('vegetable_waste')
  vegetableWaste,
  @JsonValue('livestock_manure')
  livestockManure,
  @JsonValue('coffee_husks')
  coffeeHusks,
  @JsonValue('rice_hulls')
  riceHulls,
  @JsonValue('corn_stover')
  cornStover,
  @JsonValue('other')
  other,
}

enum ListingStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('assigned')
  assigned,
  @JsonValue('in_transit')
  inTransit,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled,
}

enum PickupType {
  @JsonValue('routine')
  routine,
  @JsonValue('manual')
  manual,
}

@JsonSerializable()
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
  
  factory WasteListingModel.fromJson(Map<String, dynamic> json) =>
      _$WasteListingModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$WasteListingModelToJson(this);
  
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
EOF
echo "✅ Created lib/shared/models/waste_listing_model.dart"

# ============================================
# Step 1.5: api_client.dart
# ============================================
cat > lib/core/network/api_client.dart << 'EOF'
// lib/core/network/api_client.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_strings.dart';

class ApiClient {
  static const String baseUrl = 'https://api.agriwasteconnect.com/v1';
  
  final http.Client _httpClient;
  String? _authToken;
  
  ApiClient({http.Client? httpClient}) : _httpClient = httpClient ?? http.Client();
  
  Future<void> setAuthToken(String token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }
  
  Future<void> loadAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
  }
  
  void clearAuthToken() async {
    _authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
  
  Map<String, String> _getHeaders() {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    
    return headers;
  }
  
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await _httpClient
          .get(Uri.parse('$baseUrl$endpoint'), headers: _getHeaders())
          .timeout(const Duration(seconds: 30));
      
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(),
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 30));
      
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _httpClient.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(),
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 30));
      
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final response = await _httpClient
          .delete(Uri.parse('$baseUrl$endpoint'), headers: _getHeaders())
          .timeout(const Duration(seconds: 30));
      
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> patch(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _httpClient.patch(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(),
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 30));
      
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<http.StreamedResponse> postMultipart(
    String endpoint,
    Map<String, String> fields,
    List<http.MultipartFile> files,
  ) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl$endpoint'))
        ..headers.addAll(_getHeaders())
        ..fields.addAll(fields)
        ..files.addAll(files);
      
      return await request.send().timeout(const Duration(seconds: 60));
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Map<String, dynamic> _handleResponse(http.Response response) {
    final Map<String, dynamic> responseData = jsonDecode(response.body);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseData;
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: responseData['message'] ?? AppStrings.serverError,
        data: responseData,
      );
    }
  }
  
  Exception _handleError(dynamic error) {
    if (error is ApiException) return error;
    if (error is http.ClientException) {
      return ApiException(
        statusCode: 0,
        message: AppStrings.networkError,
      );
    }
    return ApiException(
      statusCode: 500,
      message: AppStrings.somethingWentWrong,
    );
  }
  
  void dispose() {
    _httpClient.close();
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final Map<String, dynamic>? data;
  
  ApiException({
    required this.statusCode,
    required this.message,
    this.data,
  });
  
  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}
EOF
echo "✅ Created lib/core/network/api_client.dart"

# ============================================
# Step 1.6: offline_sync_repository.dart
# ============================================
cat > lib/shared/services/offline_sync_repository.dart << 'EOF'
// lib/shared/services/offline_sync_repository.dart
import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../core/network/api_client.dart';
import '../models/waste_listing_model.dart';

class OfflineSyncRepository {
  static final OfflineSyncRepository _instance = OfflineSyncRepository._internal();
  factory OfflineSyncRepository() => _instance;
  OfflineSyncRepository._internal();
  
  Database? _database;
  final ApiClient _apiClient = ApiClient();
  final StreamController<SyncStatus> _syncStatusController = StreamController.broadcast();
  Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;
  
  SyncStatus _currentStatus = SyncStatus.idle;
  SyncStatus get currentStatus => _currentStatus;
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'agri_waste.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }
  
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE pending_operations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        operation_type TEXT NOT NULL,
        endpoint TEXT NOT NULL,
        data TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        retry_count INTEGER DEFAULT 0,
        last_retry INTEGER
      )
    ''');
    
    await db.execute('''
      CREATE TABLE local_listings (
        id TEXT PRIMARY KEY,
        farmer_id TEXT NOT NULL,
        waste_type TEXT NOT NULL,
        estimated_quantity REAL NOT NULL,
        pickup_lat TEXT NOT NULL,
        pickup_lng TEXT NOT NULL,
        pickup_address TEXT NOT NULL,
        pickup_type TEXT NOT NULL,
        status TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        synced INTEGER DEFAULT 0,
        last_updated INTEGER NOT NULL
      )
    ''');
    
    await db.execute('''
      CREATE TABLE user_profile (
        id TEXT PRIMARY KEY,
        phone_number TEXT NOT NULL,
        full_name TEXT NOT NULL,
        role TEXT NOT NULL,
        data TEXT NOT NULL,
        last_sync INTEGER NOT NULL
      )
    ''');
    
    await db.execute('''
      CREATE TABLE sync_metadata (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
    
    await db.execute('CREATE INDEX idx_pending_created ON pending_operations(created_at)');
    await db.execute('CREATE INDEX idx_listings_synced ON local_listings(synced)');
  }
  
  Future<void> queueOperation({
    required String operationType,
    required String endpoint,
    required Map<String, dynamic> data,
  }) async {
    final db = await database;
    await db.insert('pending_operations', {
      'operation_type': operationType,
      'endpoint': endpoint,
      'data': data.toString(),
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
  }
  
  Future<List<Map<String, dynamic>>> getPendingOperations() async {
    final db = await database;
    return await db.query(
      'pending_operations',
      orderBy: 'created_at ASC',
    );
  }
  
  Future<void> removeOperation(int id) async {
    final db = await database;
    await db.delete('pending_operations', where: 'id = ?', whereArgs: [id]);
  }
  
  Future<void> updateRetryCount(int id) async {
    final db = await database;
    await db.update(
      'pending_operations',
      {
        'retry_count': db.rawUpdate('retry_count + 1'),
        'last_retry': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  Future<void> saveListingLocally(WasteListingModel listing) async {
    final db = await database;
    await db.insert(
      'local_listings',
      {
        'id': listing.id,
        'farmer_id': listing.farmerId,
        'waste_type': listing.wasteType.toString(),
        'estimated_quantity': listing.estimatedQuantity,
        'pickup_lat': listing.pickupLat,
        'pickup_lng': listing.pickupLng,
        'pickup_address': listing.pickupAddress,
        'pickup_type': listing.pickupType.toString(),
        'status': listing.status.toString(),
        'created_at': listing.createdAt.millisecondsSinceEpoch,
        'synced': 1,
        'last_updated': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  Future<List<WasteListingModel>> getLocalListings({bool? synced}) async {
    final db = await database;
    String where = '';
    List<dynamic> whereArgs = [];
    
    if (synced != null) {
      where = 'synced = ?';
      whereArgs = [synced ? 1 : 0];
    }
    
    final results = await db.query(
      'local_listings',
      where: where,
      whereArgs: whereArgs,
    );
    
    return results.map((result) {
      return WasteListingModel(
        id: result['id'] as String,
        farmerId: result['farmer_id'] as String,
        farmerName: '',
        wasteType: _parseWasteType(result['waste_type'] as String),
        estimatedQuantity: result['estimated_quantity'] as double,
        pickupLat: result['pickup_lat'] as String,
        pickupLng: result['pickup_lng'] as String,
        pickupAddress: result['pickup_address'] as String,
        pickupType: _parsePickupType(result['pickup_type'] as String),
        status: _parseListingStatus(result['status'] as String),
        createdAt: DateTime.fromMillisecondsSinceEpoch(result['created_at'] as int),
        isPhotoRequired: true,
      );
    }).toList();
  }
  
  Future<SyncResult> syncWithServer() async {
    if (_currentStatus == SyncStatus.syncing) {
      return SyncResult.failure('Sync already in progress');
    }
    
    _currentStatus = SyncStatus.syncing;
    _syncStatusController.add(_currentStatus);
    
    final results = <SyncOperationResult>[];
    final operations = await getPendingOperations();
    
    for (var operation in operations) {
      try {
        final id = operation['id'] as int;
        final endpoint = operation['endpoint'] as String;
        final data = operation['data'] as String;
        final Map<String, dynamic> jsonData = {};
        
        await _executeOperation(operation['operation_type'] as String, endpoint, jsonData);
        
        await removeOperation(id);
        results.add(SyncOperationResult.success(id));
      } catch (e) {
        await updateRetryCount(operation['id'] as int);
        results.add(SyncOperationResult.failure(operation['id'] as int, e.toString()));
        
        final retryCount = operation['retry_count'] as int;
        if (retryCount >= 5) {
          await removeOperation(operation['id'] as int);
          results.add(SyncOperationResult.failure(operation['id'] as int, 'Max retries exceeded'));
        }
      }
    }
    
    _currentStatus = SyncStatus.idle;
    _syncStatusController.add(_currentStatus);
    
    final successCount = results.where((r) => r.success).length;
    final failureCount = results.where((r) => !r.success).length;
    
    return SyncResult.completed(
      total: operations.length,
      success: successCount,
      failure: failureCount,
      results: results,
    );
  }
  
  Future<void> _executeOperation(String type, String endpoint, Map<String, dynamic> data) async {
    switch (type.toLowerCase()) {
      case 'post':
        await _apiClient.post(endpoint, data);
        break;
      case 'put':
        await _apiClient.put(endpoint, data);
        break;
      case 'patch':
        await _apiClient.patch(endpoint, data);
        break;
      case 'delete':
        await _apiClient.delete(endpoint);
        break;
      default:
        throw Exception('Unknown operation type: $type');
    }
  }
  
  WasteType _parseWasteType(String type) {
    if (type.contains('cropResidue')) return WasteType.cropResidue;
    if (type.contains('fruitWaste')) return WasteType.fruitWaste;
    if (type.contains('vegetableWaste')) return WasteType.vegetableWaste;
    if (type.contains('livestockManure')) return WasteType.livestockManure;
    if (type.contains('coffeeHusks')) return WasteType.coffeeHusks;
    if (type.contains('riceHulls')) return WasteType.riceHulls;
    if (type.contains('cornStover')) return WasteType.cornStover;
    return WasteType.other;
  }
  
  PickupType _parsePickupType(String type) {
    return type.contains('routine') ? PickupType.routine : PickupType.manual;
  }
  
  ListingStatus _parseListingStatus(String status) {
    if (status.contains('pending')) return ListingStatus.pending;
    if (status.contains('assigned')) return ListingStatus.assigned;
    if (status.contains('inTransit')) return ListingStatus.inTransit;
    if (status.contains('completed')) return ListingStatus.completed;
    return ListingStatus.pending;
  }
  
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('pending_operations');
    await db.delete('local_listings');
    await db.delete('user_profile');
    await db.delete('sync_metadata');
  }
  
  void dispose() {
    _syncStatusController.close();
    _database?.close();
  }
}

enum SyncStatus {
  idle,
  syncing,
  error,
}

class SyncResult {
  final bool success;
  final String? errorMessage;
  final int? total;
  final int? successCount;
  final int? failureCount;
  final List<SyncOperationResult>? results;
  
  SyncResult._({this.success = true, this.errorMessage, this.total, this.successCount, this.failureCount, this.results});
  
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
  
  factory SyncOperationResult.success(int id) => SyncOperationResult(id, true);
  factory SyncOperationResult.failure(int id, String error) => SyncOperationResult(id, false, error);
}
EOF
echo "✅ Created lib/shared/services/offline_sync_repository.dart"

# ============================================
# Create JSON serialization build.yaml
# ============================================
cat > build.yaml << 'EOF'
targets:
  $default:
    builders:
      json_serializable:
        options:
          explicit_to_json: true
          include_if_null: false
EOF
echo "✅ Created build.yaml"

echo ""
echo "=========================================="
echo "🎉 All files created successfully!"
echo "=========================================="
echo ""
echo "📁 Files created:"
echo "   - lib/core/constants/app_colors.dart"
echo "   - lib/core/constants/app_strings.dart"
echo "   - lib/shared/models/user_model.dart"
echo "   - lib/shared/models/waste_listing_model.dart"
echo "   - lib/core/network/api_client.dart"
echo "   - lib/shared/services/offline_sync_repository.dart"
echo "   - build.yaml"
echo ""
echo "🚀 Next steps:"
echo "   1. Make the script executable: chmod +x create_files.sh"
echo "   2. Run it: ./create_files.sh"
echo "   3. Then run: flutter pub run build_runner build --delete-conflicting-outputs"
echo "   4. This will generate the .g.dart files for JSON serialization"
echo ""
