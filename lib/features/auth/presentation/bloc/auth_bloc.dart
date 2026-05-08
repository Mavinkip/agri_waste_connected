<<<<<<< HEAD
import 'package:flutter_bloc/flutter_bloc.dart';
=======
import 'dart:async';
import 'package:bloc/bloc.dart';
>>>>>>> upstream/master
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
<<<<<<< HEAD
    on<AuthLoginRequested>(_onLogin);
    on<AuthRegisterRequested>(_onRegister);
    on<AuthLogoutRequested>(_onLogout);
=======
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
>>>>>>> upstream/master
    on<AuthCheckStatus>(_onCheckStatus);
    on<AuthPhoneVerified>(_onPhoneVerified);
    on<AuthOTPSent>(_onOTPSent);
    on<AuthUpdateProfile>(_onUpdateProfile);
<<<<<<< HEAD
    add(AuthCheckStatus());
  }

  Future<void> _onLogin(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await _authRepository.login(event.phoneNumber, event.password);
      if (emit.isDone) return; // Fix 2: emitter might be stale on web
      if (response.success) {
        emit(AuthAuthenticated(user: response.user!, token: response.token!));
      } else {
        emit(AuthError(response.message ?? 'Login failed'));
      }
    } catch (e) {
      if (emit.isDone) return;
      emit(AuthError('Error: ${e.toString().substring(0, 50)}'));
    }
  }

  Future<void> _onRegister(AuthRegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await _authRepository.register(RegisterData(
        fullName: event.fullName, phoneNumber: event.phoneNumber,
        password: event.password, role: event.role,
      ));
      if (emit.isDone) return;
      if (response.success) {
        emit(AuthAuthenticated(user: response.user!, token: response.token!));
      } else {
        emit(AuthError(response.message ?? 'Registration failed'));
      }
    } catch (e) {
      if (emit.isDone) return;
      emit(AuthError('Error: ${e.toString().substring(0, 50)}'));
    }
  }

  Future<void> _onLogout(AuthLogoutRequested event, Emitter<AuthState> emit) async {
=======

    add(AuthCheckStatus());
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final response = await _authRepository.login(
      event.phoneNumber,
      event.password,
    );

    if (response.success && response.user != null && response.token != null) {
      emit(AuthAuthenticated(
        user: response.user!,
        token: response.token!,
      ));
    } else {
      emit(AuthError(response.message ?? 'Login failed'));
    }
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
>>>>>>> upstream/master
    await _authRepository.logout();
    emit(AuthUnauthenticated());
  }

<<<<<<< HEAD
  Future<void> _onCheckStatus(AuthCheckStatus event, Emitter<AuthState> emit) async {
    final isLoggedIn = await _authRepository.isLoggedIn();
=======
  Future<void> _onCheckStatus(
    AuthCheckStatus event,
    Emitter<AuthState> emit,
  ) async {
    final isLoggedIn = await _authRepository.isLoggedIn();

>>>>>>> upstream/master
    if (isLoggedIn) {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user: user, token: ''));
        return;
      }
    }
    emit(AuthUnauthenticated());
  }

<<<<<<< HEAD
  Future<void> _onPhoneVerified(AuthPhoneVerified event, Emitter<AuthState> emit) async {}
  Future<void> _onOTPSent(AuthOTPSent event, Emitter<AuthState> emit) async {}
  Future<void> _onUpdateProfile(AuthUpdateProfile event, Emitter<AuthState> emit) async {}
=======
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
    // AuthRepository.verifyPhoneNumber checks if phone is registered in Firebase Auth.
    // Replace this with real OTP verification once SMS is wired up.
    final isValid =
        await _authRepository.verifyPhoneNumber(event.phoneNumber);

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
      // Update profile logic here — re-fetch user and emit AuthAuthenticated
    }
  }
>>>>>>> upstream/master
}
