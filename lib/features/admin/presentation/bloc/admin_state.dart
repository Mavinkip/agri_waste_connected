part of 'admin_bloc.dart';

abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object?> get props => [];
}

// ==================== INITIAL STATE ====================
class AdminInitial extends AdminState {}

// ==================== LOADING STATES ====================
class AdminLoading extends AdminState {}

class DashboardLoading extends AdminState {}

class DriversLoading extends AdminState {}

class InventoryLoading extends AdminState {}

class RoutinesLoading extends AdminState {}

class FarmersLoading extends AdminState {}

// ==================== DASHBOARD STATES ====================
class DashboardStatsLoaded extends AdminState {
  final AdminDashboardStats stats;

  const DashboardStatsLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

class RevenueStatsLoaded extends AdminState {
  final RevenueStats stats;

  const RevenueStatsLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

// ==================== FLEET STATES ====================
class DriversLoaded extends AdminState {
  final List<DriverModel> drivers;
  final bool hasMore;

  const DriversLoaded({required this.drivers, this.hasMore = false});

  @override
  List<Object?> get props => [drivers, hasMore];
}

class DriverDetailsLoaded extends AdminState {
  final DriverModel driver;

  const DriverDetailsLoaded(this.driver);

  @override
  List<Object?> get props => [driver];
}

class VehiclesLoaded extends AdminState {
  final List<VehicleModel> vehicles;

  const VehiclesLoaded(this.vehicles);

  @override
  List<Object?> get props => [vehicles];
}

class DriverStatusUpdated extends AdminState {
  final String driverId;
  final bool isActive;
  final String message;

  const DriverStatusUpdated({
    required this.driverId,
    required this.isActive,
    required this.message,
  });

  @override
  List<Object?> get props => [driverId, isActive, message];
}

class CollectionAssigned extends AdminState {
  final String driverId;
  final String collectionId;
  final String message;

  const CollectionAssigned({
    required this.driverId,
    required this.collectionId,
    required this.message,
  });

  @override
  List<Object?> get props => [driverId, collectionId, message];
}

class VehicleAdded extends AdminState {
  final String message;

  const VehicleAdded(this.message);

  @override
  List<Object?> get props => [message];
}

// ==================== PRICING STATES ====================
class PricingConfigLoaded extends AdminState {
  final PricingConfig config;

  const PricingConfigLoaded(this.config);

  @override
  List<Object?> get props => [config];
}

class PricingConfigUpdated extends AdminState {
  final String message;

  const PricingConfigUpdated(this.message);

  @override
  List<Object?> get props => [message];
}

class WasteTypePriceUpdated extends AdminState {
  final String wasteType;
  final double basePrice;
  final double premiumPrice;
  final String message;

  const WasteTypePriceUpdated({
    required this.wasteType,
    required this.basePrice,
    required this.premiumPrice,
    required this.message,
  });

  @override
  List<Object?> get props => [wasteType, basePrice, premiumPrice, message];
}

// ==================== INVENTORY STATES ====================
class InventoryStatsLoaded extends AdminState {
  final InventoryStats stats;

  const InventoryStatsLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

class InventoryItemsLoaded extends AdminState {
  final List<InventoryItem> items;
  final bool hasMore;
  final int currentPage;

  const InventoryItemsLoaded({
    required this.items,
    this.hasMore = false,
    this.currentPage = 1,
  });

  @override
  List<Object?> get props => [items, hasMore, currentPage];
}

class InventoryItemDetailsLoaded extends AdminState {
  final InventoryItem item;

  const InventoryItemDetailsLoaded(this.item);

  @override
  List<Object?> get props => [item];
}

// ==================== ROUTINE STATES ====================
class RoutinesLoaded extends AdminState {
  final List<RoutineRoute> routines;

  const RoutinesLoaded(this.routines);

  @override
  List<Object?> get props => [routines];
}

class RoutineDetailsLoaded extends AdminState {
  final RoutineRoute routine;

  const RoutineDetailsLoaded(this.routine);

  @override
  List<Object?> get props => [routine];
}

class RoutineCreated extends AdminState {
  final String message;

  const RoutineCreated(this.message);

  @override
  List<Object?> get props => [message];
}

class RoutineUpdated extends AdminState {
  final String message;

  const RoutineUpdated(this.message);

  @override
  List<Object?> get props => [message];
}

class RoutineDeleted extends AdminState {
  final String message;

  const RoutineDeleted(this.message);

  @override
  List<Object?> get props => [message];
}

class RoutineOptimized extends AdminState {
  final String message;
  final Map<String, dynamic>? optimizationData;

  const RoutineOptimized(this.message, {this.optimizationData});

  @override
  List<Object?> get props => [message, optimizationData];
}

// ==================== FARMER STATES ====================
class FarmersLoaded extends AdminState {
  final List<UserModel> farmers;
  final bool hasMore;
  final int currentPage;

  const FarmersLoaded({
    required this.farmers,
    this.hasMore = false,
    this.currentPage = 1,
  });

  @override
  List<Object?> get props => [farmers, hasMore, currentPage];
}

class FarmerDetailsLoaded extends AdminState {
  final UserModel farmer;

  const FarmerDetailsLoaded(this.farmer);

  @override
  List<Object?> get props => [farmer];
}

class FarmerAnalyticsLoaded extends AdminState {
  final FarmerAnalytics analytics;

  const FarmerAnalyticsLoaded(this.analytics);

  @override
  List<Object?> get props => [analytics];
}

class FarmerStatusUpdated extends AdminState {
  final String farmerId;
  final bool isActive;
  final String message;

  const FarmerStatusUpdated({
    required this.farmerId,
    required this.isActive,
    required this.message,
  });

  @override
  List<Object?> get props => [farmerId, isActive, message];
}

// ==================== REPORT STATES ====================
class ReportGenerated extends AdminState {
  final ReportData report;

  const ReportGenerated(this.report);

  @override
  List<Object?> get props => [report];
}

// ==================== ERROR & SUCCESS STATES ====================
class AdminError extends AdminState {
  final String message;

  const AdminError(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminSuccess extends AdminState {
  final String message;

  const AdminSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
