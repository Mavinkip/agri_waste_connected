part of 'driver_bloc.dart';

abstract class DriverEvent extends Equatable {
  const DriverEvent();

  @override
  List<Object?> get props => [];
}

// Collection Events
class LoadAssignedCollections extends DriverEvent {
  final String? status;
  final int page;

  const LoadAssignedCollections({this.status, this.page = 1});

  @override
  List<Object?> get props => [status, page];
}

class LoadCollectionDetails extends DriverEvent {
  final String collectionId;

  const LoadCollectionDetails(this.collectionId);

  @override
  List<Object?> get props => [collectionId];
}

class MarkArrival extends DriverEvent {
  final String collectionId;
  final String? notes;

  const MarkArrival(this.collectionId, {this.notes});

  @override
  List<Object?> get props => [collectionId, notes];
}

class RecordWeight extends DriverEvent {
  final String collectionId;
  final double actualWeight;
  final String? notes;

  const RecordWeight({
    required this.collectionId,
    required this.actualWeight,
    this.notes,
  });

  @override
  List<Object?> get props => [collectionId, actualWeight, notes];
}

class SubmitQualityCheck extends DriverEvent {
  final String collectionId;
  final int rating;
  final String qualityNotes;
  final List<String>? photoUrls;

  const SubmitQualityCheck({
    required this.collectionId,
    required this.rating,
    required this.qualityNotes,
    this.photoUrls,
  });

  @override
  List<Object?> get props => [collectionId, rating, qualityNotes, photoUrls];
}

class ConfirmPayment extends DriverEvent {
  final String collectionId;

  const ConfirmPayment(this.collectionId);

  @override
  List<Object?> get props => [collectionId];
}

class CompleteCollection extends DriverEvent {
  final String collectionId;

  const CompleteCollection(this.collectionId);

  @override
  List<Object?> get props => [collectionId];
}

// Routine Evaluation Events
class EvaluateRoutine extends DriverEvent {
  final String collectionId;
  final int qualityRating;
  final bool shouldContinue;
  final String? notes;

  const EvaluateRoutine({
    required this.collectionId,
    required this.qualityRating,
    required this.shouldContinue,
    this.notes,
  });

  @override
  List<Object?> get props => [collectionId, qualityRating, shouldContinue, notes];
}

// Dashboard Events
class LoadDriverDashboard extends DriverEvent {}

class LoadTodaySchedule extends DriverEvent {}

// Availability Events
class UpdateAvailability extends DriverEvent {
  final bool isAvailable;

  const UpdateAvailability(this.isAvailable);

  @override
  List<Object?> get props => [isAvailable];
}

// Sync Events
class SyncOfflineCollections extends DriverEvent {}

// Refresh Events
class RefreshDriverData extends DriverEvent {}
