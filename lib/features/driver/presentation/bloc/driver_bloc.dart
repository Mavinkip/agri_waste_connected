import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/repositories/collection_repository.dart';
import '../../../../shared/models/waste_listing_model.dart';

part 'driver_event.dart';
part 'driver_state.dart';

class DriverBloc extends Bloc<DriverEvent, DriverState> {
  final CollectionRepository _collectionRepository;

  DriverBloc({required CollectionRepository collectionRepository})
      : _collectionRepository = collectionRepository,
        super(DriverInitial()) {
    on<LoadAssignedCollections>(_onLoadAssignedCollections);
    on<LoadCollectionDetails>(_onLoadCollectionDetails);
    on<MarkArrival>(_onMarkArrival);
    on<RecordWeight>(_onRecordWeight);
    on<SubmitQualityCheck>(_onSubmitQualityCheck);
    on<ConfirmPayment>(_onConfirmPayment);
    on<CompleteCollection>(_onCompleteCollection);
    on<EvaluateRoutine>(_onEvaluateRoutine);
    on<LoadDriverDashboard>(_onLoadDriverDashboard);
    on<LoadTodaySchedule>(_onLoadTodaySchedule);
    on<UpdateAvailability>(_onUpdateAvailability);
    on<SyncOfflineCollections>(_onSyncOfflineCollections);
    on<RefreshDriverData>(_onRefreshDriverData);
  }

  // Load Assigned Collections
  Future<void> _onLoadAssignedCollections(
    LoadAssignedCollections event,
    Emitter<DriverState> emit,
  ) async {
    if (event.page == 1) {
      emit(CollectionsLoading());
    }

    final collections = await _collectionRepository.getAssignedCollections(
      status: event.status,
      page: event.page,
      limit: 20,
    );

    if (state is CollectionsLoaded && event.page > 1) {
      final currentState = state as CollectionsLoaded;
      final allCollections = [...currentState.collections, ...collections];
      emit(CollectionsLoaded(
        collections: allCollections,
        hasMore: collections.length >= 20,
        currentPage: event.page,
      ));
    } else {
      emit(CollectionsLoaded(
        collections: collections,
        hasMore: collections.length >= 20,
        currentPage: event.page,
      ));
    }
  }

  // Load Collection Details
  Future<void> _onLoadCollectionDetails(
    LoadCollectionDetails event,
    Emitter<DriverState> emit,
  ) async {
    emit(CollectionDetailsLoading());
    
    final collection = await _collectionRepository.getCollectionDetails(event.collectionId);
    
    if (collection != null) {
      emit(CollectionDetailsLoaded(collection));
    } else {
      emit(const DriverError('Failed to load collection details'));
    }
  }

  // Mark Arrival
  Future<void> _onMarkArrival(
    MarkArrival event,
    Emitter<DriverState> emit,
  ) async {
    emit(DriverLoading());
    
    final success = await _collectionRepository.markArrival(
      event.collectionId,
      notes: event.notes,
    );
    
    if (success) {
      emit(ArrivalMarked(event.collectionId, 'Arrival marked successfully'));
      // Refresh collection details
      add(LoadCollectionDetails(event.collectionId));
    } else {
      emit(const DriverError('Failed to mark arrival. Please try again.'));
    }
  }

  // Record Weight
  Future<void> _onRecordWeight(
    RecordWeight event,
    Emitter<DriverState> emit,
  ) async {
    emit(DriverLoading());
    
    final success = await _collectionRepository.recordWeight(
      collectionId: event.collectionId,
      actualWeight: event.actualWeight,
      notes: event.notes,
    );
    
    if (success) {
      emit(WeightRecorded(
        event.collectionId,
        event.actualWeight,
        'Weight recorded successfully',
      ));
      add(LoadCollectionDetails(event.collectionId));
    } else {
      emit(const DriverError('Failed to record weight. Please try again.'));
    }
  }

  // Submit Quality Check
  Future<void> _onSubmitQualityCheck(
    SubmitQualityCheck event,
    Emitter<DriverState> emit,
  ) async {
    emit(DriverLoading());
    
    final success = await _collectionRepository.submitQualityCheck(
      collectionId: event.collectionId,
      rating: event.rating,
      qualityNotes: event.qualityNotes,
      photoUrls: event.photoUrls,
    );
    
    if (success) {
      emit(QualitySubmitted(
        event.collectionId,
        event.rating,
        'Quality check submitted successfully',
      ));
      add(LoadCollectionDetails(event.collectionId));
    } else {
      emit(const DriverError('Failed to submit quality check'));
    }
  }

  // Confirm Payment
  Future<void> _onConfirmPayment(
    ConfirmPayment event,
    Emitter<DriverState> emit,
  ) async {
    emit(DriverLoading());
    
    final success = await _collectionRepository.confirmPayment(event.collectionId);
    
    if (success) {
      emit(PaymentConfirmed(event.collectionId, 'Payment confirmed successfully'));
      add(LoadCollectionDetails(event.collectionId));
    } else {
      emit(const DriverError('Failed to confirm payment'));
    }
  }

  // Complete Collection
  Future<void> _onCompleteCollection(
    CompleteCollection event,
    Emitter<DriverState> emit,
  ) async {
    emit(DriverLoading());
    
    final success = await _collectionRepository.completeCollection(event.collectionId);
    
    if (success) {
      emit(CollectionCompleted(event.collectionId, 'Collection completed successfully'));
      add(LoadAssignedCollections()); // Refresh the list
    } else {
      emit(const DriverError('Failed to complete collection'));
    }
  }

  // Evaluate Routine
  Future<void> _onEvaluateRoutine(
    EvaluateRoutine event,
    Emitter<DriverState> emit,
  ) async {
    emit(DriverLoading());
    
    final result = await _collectionRepository.evaluateRoutine(
      collectionId: event.collectionId,
      qualityRating: event.qualityRating,
      shouldContinue: event.shouldContinue,
      notes: event.notes,
    );
    
    if (result.success) {
      emit(RoutineEvaluated(
        collectionId: event.collectionId,
        shouldContinue: event.shouldContinue,
        updatedConsistencyScore: result.updatedConsistencyScore,
        message: result.message ?? 'Evaluation submitted successfully',
      ));
      add(LoadCollectionDetails(event.collectionId));
    } else {
      emit(DriverError(result.message ?? 'Failed to submit evaluation'));
    }
  }

  // Load Driver Dashboard
  Future<void> _onLoadDriverDashboard(
    LoadDriverDashboard event,
    Emitter<DriverState> emit,
  ) async {
    final stats = await _collectionRepository.getDashboardStats();
    emit(DriverDashboardLoaded(stats));
  }

  // Load Today's Schedule
  Future<void> _onLoadTodaySchedule(
    LoadTodaySchedule event,
    Emitter<DriverState> emit,
  ) async {
    final schedule = await _collectionRepository.getTodaySchedule();
    emit(TodayScheduleLoaded(schedule));
  }

  // Update Availability
  Future<void> _onUpdateAvailability(
    UpdateAvailability event,
    Emitter<DriverState> emit,
  ) async {
    emit(DriverLoading());
    
    final success = await _collectionRepository.updateAvailability(event.isAvailable);
    
    if (success) {
      emit(AvailabilityUpdated(
        event.isAvailable,
        'Availability updated successfully',
      ));
    } else {
      emit(const DriverError('Failed to update availability'));
    }
  }

  // Sync Offline Collections
  Future<void> _onSyncOfflineCollections(
    SyncOfflineCollections event,
    Emitter<DriverState> emit,
  ) async {
    emit(DriverLoading());
    
    await _collectionRepository.syncOfflineCollections();
    
    emit(const OfflineSyncCompleted(0, 'Offline data synced successfully'));
    add(RefreshDriverData());
  }

  // Refresh All Driver Data
  Future<void> _onRefreshDriverData(
    RefreshDriverData event,
    Emitter<DriverState> emit,
  ) async {
    add(LoadDriverDashboard());
    add(LoadTodaySchedule());
    add(LoadAssignedCollections());
  }
}
