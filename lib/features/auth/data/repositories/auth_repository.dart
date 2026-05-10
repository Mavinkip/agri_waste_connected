import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../shared/models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  })  : _auth = auth,
        _firestore = firestore;

  // Convert phone to email format for Firebase Auth
  String _phoneToEmail(String phone) =>
      '${phone.replaceAll(RegExp(r'[^0-9]'), '')}@agri.local';

  Future<AuthResponse> login(String phoneNumber, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: _phoneToEmail(phoneNumber),
        password: password,
      );

      final doc = await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      if (!doc.exists) {
        return AuthResponse.failure(message: 'User profile not found');
      }

      // Fix: Use fromMap instead of fromJson
      final user = UserModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      final token = await credential.user!.getIdToken() ?? '';

      await _saveUserLocally(user);
      return AuthResponse.success(user: user, token: token);
    } on FirebaseAuthException catch (e) {
      return AuthResponse.failure(
          message: e.message ?? 'Login failed. Please try again.');
    } catch (e) {
      return AuthResponse.failure(message: 'Login failed. Please try again.');
    }
  }

  Future<AuthResponse> register(RegisterData data) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: _phoneToEmail(data.phoneNumber),
        password: data.password,
      );

      // Fix: Use the fields that match your UserModel
      final userDoc = {
        'name': data.fullName,        // Changed from fullName to name
        'phone': data.phoneNumber,    // Changed from phoneNumber to phone
        'role': data.role,            // role is already a String in your model
        'county': '',                  // Default empty
        'subCounty': '',               // Default empty
        'communityIds': [],            // Empty array
        'totalEarnings': 0,            // Default 0
        'consistencyScore': 0,         // Default 0
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(userDoc);

      // Fix: Create UserModel with your model's constructor
      final user = UserModel(
        uid: credential.user!.uid,
        name: data.fullName,
        phone: data.phoneNumber,
        role: data.role,
        county: '',
        subCounty: '',
        communityIds: [],
        latitude: null,
        longitude: null,
        totalEarnings: 0,
        consistencyScore: 0,
      );

      final token = await credential.user!.getIdToken() ?? '';
      await _saveUserLocally(user);
      return AuthResponse.success(user: user, token: token);
    } on FirebaseAuthException catch (e) {
      return AuthResponse.failure(
          message: e.message ?? 'Registration failed. Please try again.');
    } catch (e) {
      return AuthResponse.failure(
          message: 'Registration failed. Please try again.');
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
  }

  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();
      if (!doc.exists) return null;
      // Fix: Use fromMap instead of fromJson
      return UserModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    } catch (e) {
      // Try local cache
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user_data');
      if (userData != null) {
        final Map<String, dynamic> jsonMap = jsonDecode(userData);
        // Fix: Create UserModel from stored map
        return UserModel.fromMap(jsonMap['uid'], jsonMap);
      }
      return null;
    }
  }

  Future<bool> isLoggedIn() async {
    return _auth.currentUser != null;
  }

  Future<void> _saveUserLocally(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    // Fix: Use toMap() instead of toJson()
    await prefs.setString('user_data', jsonEncode(user.toMap()));
  }

  Future<bool> verifyPhoneNumber(String phoneNumber) async {
    try {
      final methods = await _auth.fetchSignInMethodsForEmail(
          _phoneToEmail(phoneNumber));
      return methods.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}

class RegisterData {
  final String fullName;
  final String phoneNumber;
  final String password;
  final String role; // Changed from UserRole enum to String

  RegisterData({
    required this.fullName,
    required this.phoneNumber,
    required this.password,
    required this.role,
  });
}

class AuthResponse {
  final bool success;
  final UserModel? user;
  final String? token;
  final String? message;

  AuthResponse._({
    required this.success,
    this.user,
    this.token,
    this.message,
  });

  factory AuthResponse.success(
      {required UserModel user, required String token}) =>
      AuthResponse._(success: true, user: user, token: token);

  factory AuthResponse.failure({required String message}) =>
      AuthResponse._(success: false, message: message);
}
