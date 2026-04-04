part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String phoneNumber;
  final String password;

  const AuthLoginRequested({
    required this.phoneNumber,
    required this.password,
  });

  @override
  List<Object?> get props => [phoneNumber, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String fullName;
  final String phoneNumber;
  final String password;
  final UserRole role;

  const AuthRegisterRequested({
    required this.fullName,
    required this.phoneNumber,
    required this.password,
    required this.role,
  });

  @override
  List<Object?> get props => [fullName, phoneNumber, password, role];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthCheckStatus extends AuthEvent {}

class AuthPhoneVerified extends AuthEvent {
  final String phoneNumber;

  const AuthPhoneVerified(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

class AuthOTPSent extends AuthEvent {
  final String phoneNumber;
  final String otp;

  const AuthOTPSent({
    required this.phoneNumber,
    required this.otp,
  });

  @override
  List<Object?> get props => [phoneNumber, otp];
}

class AuthUpdateProfile extends AuthEvent {
  final Map<String, dynamic> profileData;

  const AuthUpdateProfile(this.profileData);

  @override
  List<Object?> get props => [profileData];
}
