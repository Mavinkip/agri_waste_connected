import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_client.dart';
import '../../../../shared/models/user_model.dart';

class AuthRepository {
  final ApiClient _apiClient;
  
  AuthRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();
  
  Future<AuthResponse> login(String phoneNumber, String password) async {
    try {
      final response = await _apiClient.post('/auth/login', {
        'phone_number': phoneNumber,
        'password': password,
      });
      
      final user = UserModel.fromJson(response['user']);
      final token = response['token'];
      
      await _apiClient.setAuthToken(token);
      await _saveUserData(user, token);
      
      return AuthResponse.success(user: user, token: token);
    } catch (e) {
      if (e is ApiException) {
        return AuthResponse.failure(message: e.message);
      }
      return AuthResponse.failure(message: 'Login failed. Please try again.');
    }
  }
  
  Future<AuthResponse> register(RegisterData data) async {
    try {
      final response = await _apiClient.post('/auth/register', {
        'full_name': data.fullName,
        'phone_number': data.phoneNumber,
        'password': data.password,
        'role': data.role.toString().split('.').last,
      });
      
      final user = UserModel.fromJson(response['user']);
      final token = response['token'];
      
      await _apiClient.setAuthToken(token);
      await _saveUserData(user, token);
      
      return AuthResponse.success(user: user, token: token);
    } catch (e) {
      if (e is ApiException) {
        return AuthResponse.failure(message: e.message);
      }
      return AuthResponse.failure(message: 'Registration failed. Please try again.');
    }
  }
  
  Future<void> logout() async {
    _apiClient.clearAuthToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
    await prefs.remove('auth_token');
  }
  
  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    
    if (userData != null) {
      try {
        final Map<String, dynamic> json = jsonDecode(userData);
        return UserModel.fromJson(json);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
  
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return token != null && token.isNotEmpty;
  }
  
  Future<void> _saveUserData(UserModel user, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(user.toJson()));
    await prefs.setString('auth_token', token);
  }
  
  Future<bool> verifyPhoneNumber(String phoneNumber) async {
    try {
      final response = await _apiClient.post('/auth/verify-phone', {
        'phone_number': phoneNumber,
      });
      return response['exists'] == true;
    } catch (e) {
      return false;
    }
  }
  
  Future<void> sendOTP(String phoneNumber) async {
    await _apiClient.post('/auth/send-otp', {
      'phone_number': phoneNumber,
    });
  }
  
  Future<bool> verifyOTP(String phoneNumber, String otp) async {
    try {
      final response = await _apiClient.post('/auth/verify-otp', {
        'phone_number': phoneNumber,
        'otp': otp,
      });
      return response['verified'] == true;
    } catch (e) {
      return false;
    }
  }
}

class RegisterData {
  final String fullName;
  final String phoneNumber;
  final String password;
  final UserRole role;
  
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
  
  factory AuthResponse.success({required UserModel user, required String token}) {
    return AuthResponse._(
      success: true,
      user: user,
      token: token,
    );
  }
  
  factory AuthResponse.failure({required String message}) {
    return AuthResponse._(
      success: false,
      message: message,
    );
  }
}
