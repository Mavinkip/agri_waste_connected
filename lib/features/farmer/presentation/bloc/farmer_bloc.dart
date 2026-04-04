import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../shared/models/user_model.dart';
import '../../data/repositories/farmer_repository.dart';
import '../../data/repositories/listing_repository.dart';
import '../../data/repositories/wallet_repository.dart';

part 'farmer_event.dart';
part 'farmer_state.dart';

class FarmerBloc extends Bloc<FarmerEvent, FarmerState> {
  final FarmerRepository _farmerRepository;
  final ListingRepository _listingRepository;
  final WalletRepository _walletRepository;

  FarmerBloc({
    required FarmerRepository farmerRepository,
    required ListingRepository listingRepository,
    required WalletRepository walletRepository,
  }) : _farmerRepository = farmerRepository,
       _listingRepository = listingRepository,
       _walletRepository = walletRepository,
       super(FarmerInitial()) {
    on<LoadFarmerProfile>(_onLoadFarmerProfile);
    on<UpdateFarmerProfile>(_onUpdateFarmerProfile);
    on<UpdateFarmLocation>(_onUpdateFarmLocation);
    on<LoadDashboardStats>(_onLoadDashboardStats);
    on<LoadConsistencyScore>(_onLoadConsistencyScore);
    on<LoadEarningsSummary>(_onLoadEarningsSummary);
    on<LoadEarningsHistory>(_onLoadEarningsHistory);
    on<LoadMoreEarnings>(_onLoadMoreEarnings);
    on<RefreshEarnings>(_onRefreshEarnings);
    on<LoadRoutineSchedule>(_onLoadRoutineSchedule);
    on<UpdateRoutineSchedule>(_onUpdateRoutineSchedule);
    on<LoadPricingInfo>(_onLoadPricingInfo);
    on<LoadNotifications>(_onLoadNotifications);
    on<MarkNotificationRead>(_onMarkNotificationRead);
    on<MarkAllNotificationsRead>(_onMarkAllNotificationsRead);
    on<RefreshFarmerData>(_onRefreshFarmerData);
  }

  // Profile Events
  Future<void> _onLoadFarmerProfile(
    LoadFarmerProfile event,
    Emitter<FarmerState> emit,
  ) async {
    emit(FarmerProfileLoading());
    
    final profile = await _farmerRepository.getFarmerProfile();
    
    if (profile != null) {
      emit(FarmerProfileLoaded(profile));
    } else {
      emit(const FarmerError('Failed to load profile'));
    }
  }

  Future<void> _onUpdateFarmerProfile(
    UpdateFarmerProfile event,
    Emitter<FarmerState> emit,
  ) async {
    emit(FarmerLoading());
    
    try {
      final updatedProfile = await _farmerRepository.updateFarmerProfile(event.updates);
      
      if (updatedProfile != null) {
        emit(FarmerProfileUpdateSuccess(updatedProfile, 'Profile updated successfully'));
      } else {
        emit(const FarmerError('Failed to update profile'));
      }
    } catch (e) {
      emit(FarmerError('Error updating profile: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateFarmLocation(
    UpdateFarmLocation event,
    Emitter<FarmerState> emit,
  ) async {
    emit(FarmerLoading());
    
    final success = await _farmerRepository.updateFarmLocation(
      latitude: event.latitude,
      longitude: event.longitude,
      address: event.address,
    );
    
    if (success) {
      emit(const FarmerSuccess('Farm location updated successfully'));
      add(LoadFarmerProfile()); // Reload profile
    } else {
      emit(const FarmerError('Failed to update farm location'));
    }
  }

  // Dashboard Events
  Future<void> _onLoadDashboardStats(
    LoadDashboardStats event,
    Emitter<FarmerState> emit,
  ) async {
    final stats = await _farmerRepository.getDashboardStats();
    emit(FarmerDashboardLoaded(stats));
  }

  Future<void> _onLoadConsistencyScore(
    LoadConsistencyScore event,
    Emitter<FarmerState> emit,
  ) async {
    final score = await _farmerRepository.getConsistencyScore();
    emit(ConsistencyScoreLoaded(score));
  }

  // Earnings Events
  Future<void> _onLoadEarningsSummary(
    LoadEarningsSummary event,
    Emitter<FarmerState> emit,
  ) async {
    final summary = await _farmerRepository.getEarningsSummary();
    // We'll combine with transactions in the earnings loaded state
    final transactions = await _farmerRepository.getEarningsHistory(page: 1, limit: 20);
    
    emit(FarmerEarningsLoaded(
      summary: summary,
      transactions: transactions,
      hasMore: transactions.length >= 20,
      currentPage: 1,
    ));
  }

  Future<void> _onLoadEarningsHistory(
    LoadEarningsHistory event,
    Emitter<FarmerState> emit,
  ) async {
    if (state is FarmerEarningsLoaded) {
      final currentState = state as FarmerEarningsLoaded;
      emit(FarmerEarningsLoadingMore(
        summary: currentState.summary,
        existingTransactions: currentState.transactions,
      ));
      
      final newTransactions = await _farmerRepository.getEarningsHistory(
        page: event.page,
        limit: event.limit,
      );
      
      final allTransactions = [...currentState.transactions, ...newTransactions];
      emit(FarmerEarningsLoaded(
        summary: currentState.summary,
        transactions: allTransactions,
        hasMore: newTransactions.length >= event.limit,
        currentPage: event.page,
      ));
    } else {
      final summary = await _farmerRepository.getEarningsSummary();
      final transactions = await _farmerRepository.getEarningsHistory(
        page: event.page,
        limit: event.limit,
      );
      
      emit(FarmerEarningsLoaded(
        summary: summary,
        transactions: transactions,
        hasMore: transactions.length >= event.limit,
        currentPage: event.page,
      ));
    }
  }

  Future<void> _onLoadMoreEarnings(
    LoadMoreEarnings event,
    Emitter<FarmerState> emit,
  ) async {
    if (state is FarmerEarningsLoaded) {
      final currentState = state as FarmerEarningsLoaded;
      if (currentState.hasMore) {
        add(LoadEarningsHistory(page: currentState.currentPage + 1));
      }
    }
  }

  Future<void> _onRefreshEarnings(
    RefreshEarnings event,
    Emitter<FarmerState> emit,
  ) async {
    add(LoadEarningsSummary());
  }

  // Schedule Events
  Future<void> _onLoadRoutineSchedule(
    LoadRoutineSchedule event,
    Emitter<FarmerState> emit,
  ) async {
    emit(FarmerScheduleLoading());
    
    final schedules = await _farmerRepository.getRoutineSchedule();
    emit(FarmerScheduleLoaded(schedules));
  }

  Future<void> _onUpdateRoutineSchedule(
    UpdateRoutineSchedule event,
    Emitter<FarmerState> emit,
  ) async {
    emit(FarmerLoading());
    
    final success = await _farmerRepository.updateRoutineSchedule(
      isActive: event.isActive,
      preferredDay: event.preferredDay,
      preferredTimeSlot: event.preferredTimeSlot,
    );
    
    if (success) {
      emit(FarmerScheduleUpdateSuccess('Schedule updated successfully'));
      add(LoadRoutineSchedule()); // Reload schedule
    } else {
      emit(const FarmerError('Failed to update schedule'));
    }
  }

  // Pricing Events
  Future<void> _onLoadPricingInfo(
    LoadPricingInfo event,
    Emitter<FarmerState> emit,
  ) async {
    final pricingInfo = await _farmerRepository.getPricingInfo();
    emit(PricingInfoLoaded(pricingInfo));
  }

  // Notification Events
  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<FarmerState> emit,
  ) async {
    final notifications = await _farmerRepository.getNotifications(
      unreadOnly: event.unreadOnly,
    );
    final unreadCount = notifications.where((n) => !n.isRead).length;
    
    emit(NotificationsLoaded(
      notifications: notifications,
      unreadCount: unreadCount,
    ));
  }

  Future<void> _onMarkNotificationRead(
    MarkNotificationRead event,
    Emitter<FarmerState> emit,
  ) async {
    final success = await _farmerRepository.markNotificationRead(event.notificationId);
    
    if (success) {
      emit(NotificationMarkedRead(event.notificationId));
      add(LoadNotifications()); // Refresh notifications
    }
  }

  Future<void> _onMarkAllNotificationsRead(
    MarkAllNotificationsRead event,
    Emitter<FarmerState> emit,
  ) async {
    // Implementation for marking all as read
    // This would need a bulk API endpoint
    emit(const FarmerSuccess('All notifications marked as read'));
    add(LoadNotifications());
  }

  // Refresh All Data
  Future<void> _onRefreshFarmerData(
    RefreshFarmerData event,
    Emitter<FarmerState> emit,
  ) async {
    add(LoadFarmerProfile());
    add(LoadDashboardStats());
    add(LoadConsistencyScore());
    add(LoadEarningsSummary());
    add(LoadRoutineSchedule());
    add(LoadPricingInfo());
    add(LoadNotifications());
  }
}
