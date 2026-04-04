import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/repositories/admin_repositories.dart';
import '../../../../shared/models/user_model.dart';

part 'admin_event.dart';
part 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final AdminRepository _adminRepository;

  AdminBloc({required AdminRepository adminRepository})
      : _adminRepository = adminRepository,
        super(AdminInitial()) {
    // Dashboard Events
    on<LoadDashboardStats>(_onLoadDashboardStats);
    on<LoadRevenueStats>(_onLoadRevenueStats);
    
    // Fleet Events
    on<LoadAllDrivers>(_onLoadAllDrivers);
    on<LoadDriverDetails>(_onLoadDriverDetails);
    on<UpdateDriverStatus>(_onUpdateDriverStatus);
    on<AssignCollection>(_onAssignCollection);
    on<LoadAllVehicles>(_onLoadAllVehicles);
    on<AddVehicle>(_onAddVehicle);
    
    // Pricing Events
    on<LoadPricingConfig>(_onLoadPricingConfig);
    on<UpdatePricingConfig>(_onUpdatePricingConfig);
    on<UpdateWasteTypePrice>(_onUpdateWasteTypePrice);
    
    // Inventory Events
    on<LoadInventoryStats>(_onLoadInventoryStats);
    on<LoadInventoryItems>(_onLoadInventoryItems);
    on<LoadInventoryItemDetails>(_onLoadInventoryItemDetails);
    on<LoadMoreInventoryItems>(_onLoadMoreInventoryItems);
    
    // Routine Events
    on<LoadAllRoutines>(_onLoadAllRoutines);
    on<LoadRoutineDetails>(_onLoadRoutineDetails);
    on<CreateRoutine>(_onCreateRoutine);
    on<UpdateRoutine>(_onUpdateRoutine);
    on<DeleteRoutine>(_onDeleteRoutine);
    on<OptimizeRoutine>(_onOptimizeRoutine);
    
    // Farmer Events
    on<LoadAllFarmers>(_onLoadAllFarmers);
    on<LoadFarmerDetails>(_onLoadFarmerDetails);
    on<LoadFarmerAnalytics>(_onLoadFarmerAnalytics);
    on<UpdateFarmerStatus>(_onUpdateFarmerStatus);
    on<LoadMoreFarmers>(_onLoadMoreFarmers);
    
    // Report Events
    on<GenerateReport>(_onGenerateReport);
    
    // Refresh Event
    on<RefreshAdminData>(_onRefreshAdminData);
  }

  // ==================== DASHBOARD HANDLERS ====================
  Future<void> _onLoadDashboardStats(
    LoadDashboardStats event,
    Emitter<AdminState> emit,
  ) async {
    emit(DashboardLoading());
    final stats = await _adminRepository.getDashboardStats();
    emit(DashboardStatsLoaded(stats));
  }

  Future<void> _onLoadRevenueStats(
    LoadRevenueStats event,
    Emitter<AdminState> emit,
  ) async {
    final stats = await _adminRepository.getRevenueStats(period: event.period);
    emit(RevenueStatsLoaded(stats));
  }

  // ==================== FLEET HANDLERS ====================
  Future<void> _onLoadAllDrivers(
    LoadAllDrivers event,
    Emitter<AdminState> emit,
  ) async {
    emit(DriversLoading());
    final drivers = await _adminRepository.getAllDrivers(isAvailable: event.isAvailable);
    emit(DriversLoaded(drivers: drivers));
  }

  Future<void> _onLoadDriverDetails(
    LoadDriverDetails event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    final driver = await _adminRepository.getDriverDetails(event.driverId);
    if (driver != null) {
      emit(DriverDetailsLoaded(driver));
    } else {
      emit(const AdminError('Driver not found'));
    }
  }

  Future<void> _onUpdateDriverStatus(
    UpdateDriverStatus event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    final success = await _adminRepository.updateDriverStatus(
      event.driverId,
      isActive: event.isActive,
    );
    
    if (success) {
      emit(DriverStatusUpdated(
        driverId: event.driverId,
        isActive: event.isActive,
        message: 'Driver status updated successfully',
      ));
      add(LoadAllDrivers()); // Refresh list
    } else {
      emit(const AdminError('Failed to update driver status'));
    }
  }

  Future<void> _onAssignCollection(
    AssignCollection event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    final success = await _adminRepository.assignCollection(
      event.driverId,
      event.collectionId,
    );
    
    if (success) {
      emit(CollectionAssigned(
        driverId: event.driverId,
        collectionId: event.collectionId,
        message: 'Collection assigned successfully',
      ));
    } else {
      emit(const AdminError('Failed to assign collection'));
    }
  }

  Future<void> _onLoadAllVehicles(
    LoadAllVehicles event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    final vehicles = await _adminRepository.getAllVehicles();
    emit(VehiclesLoaded(vehicles));
  }

  Future<void> _onAddVehicle(
    AddVehicle event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    final success = await _adminRepository.addVehicle(event.vehicleData);
    
    if (success) {
      emit(const VehicleAdded('Vehicle added successfully'));
      add(LoadAllVehicles()); // Refresh list
    } else {
      emit(const AdminError('Failed to add vehicle'));
    }
  }

  // ==================== PRICING HANDLERS ====================
  Future<void> _onLoadPricingConfig(
    LoadPricingConfig event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    final config = await _adminRepository.getPricingConfig();
    emit(PricingConfigLoaded(config));
  }

  Future<void> _onUpdatePricingConfig(
    UpdatePricingConfig event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    final success = await _adminRepository.updatePricingConfig(event.config);
    
    if (success) {
      emit(const PricingConfigUpdated('Pricing configuration updated'));
      add(LoadPricingConfig()); // Refresh
    } else {
      emit(const AdminError('Failed to update pricing configuration'));
    }
  }

  Future<void> _onUpdateWasteTypePrice(
    UpdateWasteTypePrice event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    final success = await _adminRepository.updateWasteTypePrice(
      event.wasteType,
      event.basePrice,
      event.premiumPrice,
    );
    
    if (success) {
      emit(WasteTypePriceUpdated(
        wasteType: event.wasteType,
        basePrice: event.basePrice,
        premiumPrice: event.premiumPrice,
        message: 'Price updated successfully',
      ));
      add(LoadPricingConfig()); // Refresh
    } else {
      emit(const AdminError('Failed to update price'));
    }
  }

  // ==================== INVENTORY HANDLERS ====================
  Future<void> _onLoadInventoryStats(
    LoadInventoryStats event,
    Emitter<AdminState> emit,
  ) async {
    emit(InventoryLoading());
    final stats = await _adminRepository.getInventoryStats();
    emit(InventoryStatsLoaded(stats));
  }

  Future<void> _onLoadInventoryItems(
    LoadInventoryItems event,
    Emitter<AdminState> emit,
  ) async {
    if (event.page == 1) {
      emit(InventoryLoading());
    }
    
    final items = await _adminRepository.getInventoryItems(
      wasteType: event.wasteType,
      page: event.page,
    );
    
    if (state is InventoryItemsLoaded && event.page > 1) {
      final currentState = state as InventoryItemsLoaded;
      final allItems = [...currentState.items, ...items];
      emit(InventoryItemsLoaded(
        items: allItems,
        hasMore: items.length >= 20,
        currentPage: event.page,
      ));
    } else {
      emit(InventoryItemsLoaded(
        items: items,
        hasMore: items.length >= 20,
        currentPage: event.page,
      ));
    }
  }

  Future<void> _onLoadInventoryItemDetails(
    LoadInventoryItemDetails event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    final item = await _adminRepository.getInventoryItemDetails(event.itemId);
    if (item != null) {
      emit(InventoryItemDetailsLoaded(item));
    } else {
      emit(const AdminError('Inventory item not found'));
    }
  }

  Future<void> _onLoadMoreInventoryItems(
    LoadMoreInventoryItems event,
    Emitter<AdminState> emit,
  ) async {
    if (state is InventoryItemsLoaded) {
      final currentState = state as InventoryItemsLoaded;
      if (currentState.hasMore) {
        add(LoadInventoryItems(page: currentState.currentPage + 1));
      }
    }
  }

  // ==================== ROUTINE HANDLERS ====================
  Future<void> _onLoadAllRoutines(
    LoadAllRoutines event,
    Emitter<AdminState> emit,
  ) async {
    emit(RoutinesLoading());
    final routines = await _adminRepository.getAllRoutines();
    emit(RoutinesLoaded(routines));
  }

  Future<void> _onLoadRoutineDetails(
    LoadRoutineDetails event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    final routine = await _adminRepository.getRoutineDetails(event.routineId);
    if (routine != null) {
      emit(RoutineDetailsLoaded(routine));
    } else {
      emit(const AdminError('Routine not found'));
    }
  }

  Future<void> _onCreateRoutine(
    CreateRoutine event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    final success = await _adminRepository.createRoutine(event.routine);
    
    if (success) {
      emit(const RoutineCreated('Routine created successfully'));
      add(LoadAllRoutines()); // Refresh list
    } else {
      emit(const AdminError('Failed to create routine'));
    }
  }

  Future<void> _onUpdateRoutine(
    UpdateRoutine event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    final success = await _adminRepository.updateRoutine(
      event.routineId,
      event.routine,
    );
    
    if (success) {
      emit(const RoutineUpdated('Routine updated successfully'));
      add(LoadAllRoutines()); // Refresh list
    } else {
      emit(const AdminError('Failed to update routine'));
    }
  }

  Future<void> _onDeleteRoutine(
    DeleteRoutine event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    final success = await _adminRepository.deleteRoutine(event.routineId);
    
    if (success) {
      emit(const RoutineDeleted('Routine deleted successfully'));
      add(LoadAllRoutines()); // Refresh list
    } else {
      emit(const AdminError('Failed to delete routine'));
    }
  }

  Future<void> _onOptimizeRoutine(
    OptimizeRoutine event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    final success = await _adminRepository.optimizeRoutine(event.routineId);
    
    if (success) {
      emit(const RoutineOptimized('Routine optimized successfully'));
      add(LoadRoutineDetails(event.routineId)); // Refresh details
    } else {
      emit(const AdminError('Failed to optimize routine'));
    }
  }

  // ==================== FARMER HANDLERS ====================
  Future<void> _onLoadAllFarmers(
    LoadAllFarmers event,
    Emitter<AdminState> emit,
  ) async {
    if (event.page == 1) {
      emit(FarmersLoading());
    }
    
    final farmers = await _adminRepository.getAllFarmers(
      page: event.page,
      search: event.search,
    );
    
    if (state is FarmersLoaded && event.page > 1) {
      final currentState = state as FarmersLoaded;
      final allFarmers = [...currentState.farmers, ...farmers];
      emit(FarmersLoaded(
        farmers: allFarmers,
        hasMore: farmers.length >= 20,
        currentPage: event.page,
      ));
    } else {
      emit(FarmersLoaded(
        farmers: farmers,
        hasMore: farmers.length >= 20,
        currentPage: event.page,
      ));
    }
  }

  Future<void> _onLoadFarmerDetails(
    LoadFarmerDetails event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    final farmer = await _adminRepository.getFarmerDetails(event.farmerId);
    if (farmer != null) {
      emit(FarmerDetailsLoaded(farmer));
    } else {
      emit(const AdminError('Farmer not found'));
    }
  }

  Future<void> _onLoadFarmerAnalytics(
    LoadFarmerAnalytics event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    final analytics = await _adminRepository.getFarmerAnalytics(event.farmerId);
    emit(FarmerAnalyticsLoaded(analytics));
  }

  Future<void> _onUpdateFarmerStatus(
    UpdateFarmerStatus event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    final success = await _adminRepository.updateFarmerStatus(
      event.farmerId,
      isActive: event.isActive,
    );
    
    if (success) {
      emit(FarmerStatusUpdated(
        farmerId: event.farmerId,
        isActive: event.isActive,
        message: 'Farmer status updated successfully',
      ));
      add(LoadAllFarmers()); // Refresh list
    } else {
      emit(const AdminError('Failed to update farmer status'));
    }
  }

  Future<void> _onLoadMoreFarmers(
    LoadMoreFarmers event,
    Emitter<AdminState> emit,
  ) async {
    if (state is FarmersLoaded) {
      final currentState = state as FarmersLoaded;
      if (currentState.hasMore) {
        add(LoadAllFarmers(page: currentState.currentPage + 1));
      }
    }
  }

  // ==================== REPORT HANDLERS ====================
  Future<void> _onGenerateReport(
    GenerateReport event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    final report = await _adminRepository.generateReport(
      reportType: event.reportType,
      startDate: event.startDate,
      endDate: event.endDate,
    );
    emit(ReportGenerated(report));
  }

  // ==================== REFRESH HANDLER ====================
  Future<void> _onRefreshAdminData(
    RefreshAdminData event,
    Emitter<AdminState> emit,
  ) async {
    add(LoadDashboardStats());
    add(LoadRevenueStats());
    add(LoadAllDrivers());
    add(LoadInventoryStats());
    add(LoadAllRoutines());
    add(LoadAllFarmers());
  }
}
