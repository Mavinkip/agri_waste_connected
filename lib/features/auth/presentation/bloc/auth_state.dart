part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserModel user;
  final String token;

  const AuthAuthenticated({
    required this.user,
    required this.token,
  });

  @override
  List<Object?> get props => [user, token];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthPhoneVerifiedState extends AuthState {
  final String phoneNumber;

  const AuthPhoneVerifiedState(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

class AuthOTPVerifiedState extends AuthState {
  final String phoneNumber;

  const AuthOTPVerifiedState(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}
