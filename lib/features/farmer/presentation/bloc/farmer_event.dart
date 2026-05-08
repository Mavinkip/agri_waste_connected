part of 'farmer_bloc.dart';

abstract class FarmerEvent extends Equatable {
  const FarmerEvent();

  @override
  List<Object?> get props => [];
}

// Profile Events
class LoadFarmerProfile extends FarmerEvent {
  const LoadFarmerProfile();
}

class UpdateFarmerProfile extends FarmerEvent {
  final Map<String, dynamic> updates;

  const UpdateFarmerProfile(this.updates);

  @override
  List<Object?> get props => [updates];
}

class UpdateFarmLocation extends FarmerEvent {
  final String latitude;
  final String longitude;
  final String address;

  const UpdateFarmLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  @override
  List<Object?> get props => [latitude, longitude, address];
}

// Dashboard Events
class LoadDashboardStats extends FarmerEvent {
  const LoadDashboardStats();
}

class LoadConsistencyScore extends FarmerEvent {
  const LoadConsistencyScore();
}

// Earnings Events
class LoadEarningsSummary extends FarmerEvent {
  const LoadEarningsSummary();
}

class LoadEarningsHistory extends FarmerEvent {
  final int page;
  final int limit;

  const LoadEarningsHistory({
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [page, limit];
}

class LoadMoreEarnings extends FarmerEvent {
  const LoadMoreEarnings();
}

class RefreshEarnings extends FarmerEvent {
  const RefreshEarnings();
}

// Schedule Events
class LoadRoutineSchedule extends FarmerEvent {
  const LoadRoutineSchedule();
}

class UpdateRoutineSchedule extends FarmerEvent {
  final bool isActive;
  final String? preferredDay;
  final String? preferredTimeSlot;

  const UpdateRoutineSchedule({
    required this.isActive,
    this.preferredDay,
    this.preferredTimeSlot,
  });

  @override
  List<Object?> get props => [isActive, preferredDay, preferredTimeSlot];
}

// Pricing Events
class LoadPricingInfo extends FarmerEvent {
  const LoadPricingInfo();
}

// Notification Events
class LoadNotifications extends FarmerEvent {
  final bool unreadOnly;

  const LoadNotifications({this.unreadOnly = false});

  @override
  List<Object?> get props => [unreadOnly];
}

class MarkNotificationRead extends FarmerEvent {
  final String notificationId;

  const MarkNotificationRead(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class MarkAllNotificationsRead extends FarmerEvent {
  const MarkAllNotificationsRead();
}

// Refresh Events
class RefreshFarmerData extends FarmerEvent {
  const RefreshFarmerData();
}
