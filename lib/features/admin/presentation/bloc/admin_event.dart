part of 'admin_bloc.dart';

abstract class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object?> get props => [];
}

// ==================== DASHBOARD EVENTS ====================
class LoadDashboardStats extends AdminEvent {}

class LoadRevenueStats extends AdminEvent {
  final String? period;

  const LoadRevenueStats({this.period});

  @override
  List<Object?> get props => [period];
}

// ==================== FLEET MANAGEMENT EVENTS ====================
class LoadAllDrivers extends AdminEvent {
  final bool? isAvailable;

  const LoadAllDrivers({this.isAvailable});

  @override
  List<Object?> get props => [isAvailable];
}

class LoadDriverDetails extends AdminEvent {
  final String driverId;

  const LoadDriverDetails(this.driverId);

  @override
  List<Object?> get props => [driverId];
}

class UpdateDriverStatus extends AdminEvent {
  final String driverId;
  final bool isActive;

  const UpdateDriverStatus({
    required this.driverId,
    required this.isActive,
  });

  @override
  List<Object?> get props => [driverId, isActive];
}

class AssignCollection extends AdminEvent {
  final String driverId;
  final String collectionId;

  const AssignCollection({
    required this.driverId,
    required this.collectionId,
  });

  @override
  List<Object?> get props => [driverId, collectionId];
}

class LoadAllVehicles extends AdminEvent {}

class AddVehicle extends AdminEvent {
  final Map<String, dynamic> vehicleData;

  const AddVehicle(this.vehicleData);

  @override
  List<Object?> get props => [vehicleData];
}

// ==================== PRICING MANAGEMENT EVENTS ====================
class LoadPricingConfig extends AdminEvent {}

class UpdatePricingConfig extends AdminEvent {
  final PricingConfig config;

  const UpdatePricingConfig(this.config);

  @override
  List<Object?> get props => [config];
}

class UpdateWasteTypePrice extends AdminEvent {
  final String wasteType;
  final double basePrice;
  final double premiumPrice;

  const UpdateWasteTypePrice({
    required this.wasteType,
    required this.basePrice,
    required this.premiumPrice,
  });

  @override
  List<Object?> get props => [wasteType, basePrice, premiumPrice];
}

// ==================== INVENTORY EVENTS ====================
class LoadInventoryStats extends AdminEvent {}

class LoadInventoryItems extends AdminEvent {
  final String? wasteType;
  final int page;

  const LoadInventoryItems({this.wasteType, this.page = 1});

  @override
  List<Object?> get props => [wasteType, page];
}

class LoadInventoryItemDetails extends AdminEvent {
  final String itemId;

  const LoadInventoryItemDetails(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

class LoadMoreInventoryItems extends AdminEvent {}

// ==================== ROUTINE MANAGEMENT EVENTS ====================
class LoadAllRoutines extends AdminEvent {}

class LoadRoutineDetails extends AdminEvent {
  final String routineId;

  const LoadRoutineDetails(this.routineId);

  @override
  List<Object?> get props => [routineId];
}

class CreateRoutine extends AdminEvent {
  final RoutineRoute routine;

  const CreateRoutine(this.routine);

  @override
  List<Object?> get props => [routine];
}

class UpdateRoutine extends AdminEvent {
  final String routineId;
  final RoutineRoute routine;

  const UpdateRoutine({
    required this.routineId,
    required this.routine,
  });

  @override
  List<Object?> get props => [routineId, routine];
}

class DeleteRoutine extends AdminEvent {
  final String routineId;

  const DeleteRoutine(this.routineId);

  @override
  List<Object?> get props => [routineId];
}

class OptimizeRoutine extends AdminEvent {
  final String routineId;

  const OptimizeRoutine(this.routineId);

  @override
  List<Object?> get props => [routineId];
}

// ==================== FARMER MANAGEMENT EVENTS ====================
class LoadAllFarmers extends AdminEvent {
  final int page;
  final String? search;

  const LoadAllFarmers({this.page = 1, this.search});

  @override
  List<Object?> get props => [page, search];
}

class LoadFarmerDetails extends AdminEvent {
  final String farmerId;

  const LoadFarmerDetails(this.farmerId);

  @override
  List<Object?> get props => [farmerId];
}

class LoadFarmerAnalytics extends AdminEvent {
  final String farmerId;

  const LoadFarmerAnalytics(this.farmerId);

  @override
  List<Object?> get props => [farmerId];
}

class UpdateFarmerStatus extends AdminEvent {
  final String farmerId;
  final bool isActive;

  const UpdateFarmerStatus({
    required this.farmerId,
    required this.isActive,
  });

  @override
  List<Object?> get props => [farmerId, isActive];
}

class LoadMoreFarmers extends AdminEvent {}

// ==================== REPORT EVENTS ====================
class GenerateReport extends AdminEvent {
  final String reportType;
  final DateTime startDate;
  final DateTime endDate;

  const GenerateReport({
    required this.reportType,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [reportType, startDate, endDate];
}

// ==================== REFRESH EVENTS ====================
class RefreshAdminData extends AdminEvent {}
