import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../shared/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthCheckStatus>(_onCheckStatus);
    on<AuthPhoneVerified>(_onPhoneVerified);
    on<AuthOTPSent>(_onOTPSent);
    on<AuthUpdateProfile>(_onUpdateProfile);
    
    // Auto-check status on initialization
    add(AuthCheckStatus());
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    // For testing without backend, you can use this mock
    // Remove this mock and use real API when backend is ready
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock authentication for testing
    if (event.phoneNumber == "0712345678" && event.password == "password123") {
      final mockUser = UserModel(
        id: "1",
        phoneNumber: event.phoneNumber,
        fullName: "Test Farmer",
        role: UserRole.farmer,
        createdAt: DateTime.now(),
        consistencyScore: 85.0,
        totalEarnings: 15000.0,
        completedPickups: 12,
      );
      emit(AuthAuthenticated(user: mockUser, token: "mock_token_123"));
    } else {
      emit(const AuthError("Invalid phone number or password"));
    }
    
    // Real implementation (uncomment when backend is ready):
    // final response = await _authRepository.login(
    //   event.phoneNumber,
    //   event.password,
    // );
    // 
    // if (response.success && response.user != null && response.token != null) {
    //   emit(AuthAuthenticated(
    //     user: response.user!,
    //     token: response.token!,
    //   ));
    // } else {
    //   emit(AuthError(response.message ?? 'Login failed'));
    // }
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final registerData = RegisterData(
      fullName: event.fullName,
      phoneNumber: event.phoneNumber,
      password: event.password,
      role: event.role,
    );
    
    final response = await _authRepository.register(registerData);
    
    if (response.success && response.user != null && response.token != null) {
      emit(AuthAuthenticated(
        user: response.user!,
        token: response.token!,
      ));
    } else {
      emit(AuthError(response.message ?? 'Registration failed'));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    await _authRepository.logout();
    emit(AuthUnauthenticated());
  }

  Future<void> _onCheckStatus(
    AuthCheckStatus event,
    Emitter<AuthState> emit,
  ) async {
    final isLoggedIn = await _authRepository.isLoggedIn();
    
    if (isLoggedIn) {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user: user, token: ''));
        return;
      }
    }
    emit(AuthUnauthenticated());
  }

  Future<void> _onPhoneVerified(
    AuthPhoneVerified event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthPhoneVerifiedState(event.phoneNumber));
  }

  Future<void> _onOTPSent(
    AuthOTPSent event,
    Emitter<AuthState> emit,
  ) async {
    final isValid = await _authRepository.verifyOTP(
      event.phoneNumber,
      event.otp,
    );
    
    if (isValid) {
      emit(AuthOTPVerifiedState(event.phoneNumber));
    } else {
      emit(const AuthError('Invalid OTP'));
    }
  }

  Future<void> _onUpdateProfile(
    AuthUpdateProfile event,
    Emitter<AuthState> emit,
  ) async {
    if (state is AuthAuthenticated) {
      emit(AuthLoading());
      // Update profile logic here
      // After update, emit new AuthAuthenticated with updated user
    }
  }
}
