part of 'driver_bloc.dart';

abstract class DriverState extends Equatable {
  const DriverState();

  @override
  List<Object?> get props => [];
}

// Initial State
class DriverInitial extends DriverState {}

// Loading States
class DriverLoading extends DriverState {}

class CollectionsLoading extends DriverState {}

class CollectionDetailsLoading extends DriverState {}

// Collections Loaded
class CollectionsLoaded extends DriverState {
  final List<WasteListingModel> collections;
  final bool hasMore;
  final int currentPage;

  const CollectionsLoaded({
    required this.collections,
    this.hasMore = false,
    this.currentPage = 1,
  });

  @override
  List<Object?> get props => [collections, hasMore, currentPage];
}

// Collection Details Loaded
class CollectionDetailsLoaded extends DriverState {
  final WasteListingModel collection;

  const CollectionDetailsLoaded(this.collection);

  @override
  List<Object?> get props => [collection];
}

// Operation Success States
class ArrivalMarked extends DriverState {
  final String collectionId;
  final String message;

  const ArrivalMarked(this.collectionId, this.message);

  @override
  List<Object?> get props => [collectionId, message];
}

class WeightRecorded extends DriverState {
  final String collectionId;
  final double weight;
  final String message;

  const WeightRecorded(this.collectionId, this.weight, this.message);

  @override
  List<Object?> get props => [collectionId, weight, message];
}

class QualitySubmitted extends DriverState {
  final String collectionId;
  final int rating;
  final String message;

  const QualitySubmitted(this.collectionId, this.rating, this.message);

  @override
  List<Object?> get props => [collectionId, rating, message];
}

class PaymentConfirmed extends DriverState {
  final String collectionId;
  final String message;

  const PaymentConfirmed(this.collectionId, this.message);

  @override
  List<Object?> get props => [collectionId, message];
}

class CollectionCompleted extends DriverState {
  final String collectionId;
  final String message;

  const CollectionCompleted(this.collectionId, this.message);

  @override
  List<Object?> get props => [collectionId, message];
}

// Routine Evaluation State
class RoutineEvaluated extends DriverState {
  final String collectionId;
  final bool shouldContinue;
  final double? updatedConsistencyScore;
  final String message;

  const RoutineEvaluated({
    required this.collectionId,
    required this.shouldContinue,
    this.updatedConsistencyScore,
    required this.message,
  });

  @override
  List<Object?> get props => [collectionId, shouldContinue, updatedConsistencyScore, message];
}

// Dashboard States
class DriverDashboardLoaded extends DriverState {
  final DriverDashboardStats stats;

  const DriverDashboardLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

class TodayScheduleLoaded extends DriverState {
  final List<WasteListingModel> schedule;

  const TodayScheduleLoaded(this.schedule);

  @override
  List<Object?> get props => [schedule];
}

// Availability State
class AvailabilityUpdated extends DriverState {
  final bool isAvailable;
  final String message;

  const AvailabilityUpdated(this.isAvailable, this.message);

  @override
  List<Object?> get props => [isAvailable, message];
}

// Sync State
class OfflineSyncCompleted extends DriverState {
  final int syncedCount;
  final String message;

  const OfflineSyncCompleted(this.syncedCount, this.message);

  @override
  List<Object?> get props => [syncedCount, message];
}

// Error State
class DriverError extends DriverState {
  final String message;

  const DriverError(this.message);

  @override
  List<Object?> get props => [message];
}

// Success State (generic)
class DriverSuccess extends DriverState {
  final String message;

  const DriverSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
