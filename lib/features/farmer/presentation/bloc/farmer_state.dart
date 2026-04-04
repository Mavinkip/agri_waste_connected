part of 'farmer_bloc.dart';

abstract class FarmerState extends Equatable {
  const FarmerState();

  @override
  List<Object?> get props => [];
}

// Initial State
class FarmerInitial extends FarmerState {}

// Loading States
class FarmerLoading extends FarmerState {}

class FarmerProfileLoading extends FarmerState {}

class FarmerEarningsLoading extends FarmerState {}

class FarmerScheduleLoading extends FarmerState {}

// Profile States
class FarmerProfileLoaded extends FarmerState {
  final UserModel profile;

  const FarmerProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

class FarmerProfileUpdateSuccess extends FarmerState {
  final UserModel profile;
  final String message;

  const FarmerProfileUpdateSuccess(this.profile, this.message);

  @override
  List<Object?> get props => [profile, message];
}

// Dashboard States
class FarmerDashboardLoaded extends FarmerState {
  final FarmerDashboardStats stats;

  const FarmerDashboardLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

class ConsistencyScoreLoaded extends FarmerState {
  final double score;

  const ConsistencyScoreLoaded(this.score);

  @override
  List<Object?> get props => [score];
}

// Earnings States
class FarmerEarningsLoaded extends FarmerState {
  final EarningsSummary summary;
  final List<EarningTransaction> transactions;
  final bool hasMore;
  final int currentPage;

  const FarmerEarningsLoaded({
    required this.summary,
    required this.transactions,
    this.hasMore = false,
    this.currentPage = 1,
  });

  @override
  List<Object?> get props => [summary, transactions, hasMore, currentPage];
}

class FarmerEarningsLoadingMore extends FarmerState {
  final EarningsSummary summary;
  final List<EarningTransaction> existingTransactions;

  const FarmerEarningsLoadingMore({
    required this.summary,
    required this.existingTransactions,
  });

  @override
  List<Object?> get props => [summary, existingTransactions];
}

// Schedule States
class FarmerScheduleLoaded extends FarmerState {
  final List<RoutineSchedule> schedules;

  const FarmerScheduleLoaded(this.schedules);

  @override
  List<Object?> get props => [schedules];
}

class FarmerScheduleUpdateSuccess extends FarmerState {
  final String message;

  const FarmerScheduleUpdateSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// Pricing States
class PricingInfoLoaded extends FarmerState {
  final PricingInfo pricingInfo;

  const PricingInfoLoaded(this.pricingInfo);

  @override
  List<Object?> get props => [pricingInfo];
}

// Notification States
class NotificationsLoaded extends FarmerState {
  final List<FarmerNotification> notifications;
  final int unreadCount;

  const NotificationsLoaded({
    required this.notifications,
    required this.unreadCount,
  });

  @override
  List<Object?> get props => [notifications, unreadCount];
}

class NotificationMarkedRead extends FarmerState {
  final String notificationId;

  const NotificationMarkedRead(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

// Error States
class FarmerError extends FarmerState {
  final String message;

  const FarmerError(this.message);

  @override
  List<Object?> get props => [message];
}

// Success States (without data)
class FarmerSuccess extends FarmerState {
  final String message;

  const FarmerSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
