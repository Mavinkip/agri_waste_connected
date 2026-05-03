import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../shared/models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository({required FirebaseAuth auth, required FirebaseFirestore firestore})
      : _auth = auth, _firestore = firestore;

  String _phoneToEmail(String phone) => '${phone.replaceAll(RegExp(r'[^0-9]'), '')}@agri.local';

  Future<AuthResponse> login(String phoneNumber, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: _phoneToEmail(phoneNumber), password: password);

      // Try Firestore, return basic user if it fails
      UserModel user;
      try {
        final doc = await _firestore.collection('users').doc(credential.user!.uid).get();
        if (doc.exists) {
          user = UserModel.fromJson({...doc.data()!, 'id': doc.id});
        } else {
          user = UserModel(id: credential.user!.uid, phoneNumber: phoneNumber, fullName: phoneNumber, role: UserRole.farmer, createdAt: DateTime.now());
        }
      } catch (_) {
        user = UserModel(id: credential.user!.uid, phoneNumber: phoneNumber, fullName: phoneNumber, role: UserRole.farmer, createdAt: DateTime.now());
      }

      await _saveUserLocally(user);
      return AuthResponse.success(user: user, token: 'token_ok');
    } on FirebaseAuthException catch (e) {
      return AuthResponse.failure(message: e.message ?? 'Login failed');
    } catch (e) {
      return AuthResponse.failure(message: 'Login failed. Try again.');
    }
  }

  Future<AuthResponse> register(RegisterData data) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: _phoneToEmail(data.phoneNumber), password: data.password);

      final user = UserModel(
        id: credential.user!.uid, phoneNumber: data.phoneNumber,
        fullName: data.fullName, role: data.role, createdAt: DateTime.now());

      // Firestore in background - don't wait
      _firestore.collection('users').doc(credential.user!.uid).set({
        'phoneNumber': data.phoneNumber, 'fullName': data.fullName,
        'role': data.role.name, 'isVerified': false,
        'createdAt': FieldValue.serverTimestamp(),
      }).catchError((_) {});

      await _saveUserLocally(user);
      return AuthResponse.success(user: user, token: 'token_ok');
    } on FirebaseAuthException catch (e) {
      return AuthResponse.failure(message: e.message ?? 'Registration failed');
    } catch (e) {
      return AuthResponse.failure(message: 'Registration failed. Try again.');
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('user_data');
      if (data != null) return UserModel.fromJson(jsonDecode(data));
    } catch (_) {}
    return null;
  }

  Future<bool> isLoggedIn() async => _auth.currentUser != null;

  Future<void> _saveUserLocally(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(user.toJson()));
  }

  Future<bool> verifyPhoneNumber(String phoneNumber) async {
    try {
      final methods = await _auth.fetchSignInMethodsForEmail(_phoneToEmail(phoneNumber));
      return methods.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}

class RegisterData {
  final String fullName, phoneNumber, password;
  final UserRole role;
  RegisterData({required this.fullName, required this.phoneNumber, required this.password, required this.role});
}

class AuthResponse {
  final bool success;
  final UserModel? user;
  final String? token;
  final String? message;
  AuthResponse._({required this.success, this.user, this.token, this.message});
  factory AuthResponse.success({required UserModel user, required String token}) =>
      AuthResponse._(success: true, user: user, token: token);
  factory AuthResponse.failure({required String message}) =>
      AuthResponse._(success: false, message: message);
}
