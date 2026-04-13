part of 'sell_wizard_cubit.dart';

abstract class SellWizardState extends Equatable {
  final int currentStep;
  
  const SellWizardState({this.currentStep = 0});
  
  @override
  List<Object?> get props => [currentStep];
  
  SellWizardState copyWith({int? currentStep});
}

// Initial State
class SellWizardInitial extends SellWizardState {
  const SellWizardInitial() : super(currentStep: 0);
  
  @override
  SellWizardState copyWith({int? currentStep}) {
    return SellWizardInitial();
  }
}

// Step 1: Waste Type Selected
class SellWizardWasteTypeSelected extends SellWizardState {
  final WasteType wasteType;
  
  const SellWizardWasteTypeSelected(this.wasteType) : super(currentStep: 0);
  
  @override
  List<Object?> get props => [wasteType, currentStep];
  
  @override
  SellWizardState copyWith({int? currentStep}) {
    return SellWizardWasteTypeSelected(
      wasteType,
    );
  }
}

// Step 2: Quantity Entered
class SellWizardQuantityEntered extends SellWizardState {
  final double quantity;
  
  const SellWizardQuantityEntered(this.quantity) : super(currentStep: 1);
  
  @override
  List<Object?> get props => [quantity, currentStep];
  
  @override
  SellWizardState copyWith({int? currentStep}) {
    return SellWizardQuantityEntered(
      quantity,
    );
  }
}

// Step 3: Photo States
class SellWizardPhotoAdded extends SellWizardState {
  final String photoPath;
  
  const SellWizardPhotoAdded(this.photoPath) : super(currentStep: 2);
  
  @override
  List<Object?> get props => [photoPath, currentStep];
  
  @override
  SellWizardState copyWith({int? currentStep}) {
    return SellWizardPhotoAdded(photoPath);
  }
}

class SellWizardPhotoSkipped extends SellWizardState {
  const SellWizardPhotoSkipped() : super(currentStep: 2);
  
  @override
  SellWizardState copyWith({int? currentStep}) {
    return const SellWizardPhotoSkipped();
  }
}

class SellWizardPhotoRemoved extends SellWizardState {
  const SellWizardPhotoRemoved() : super(currentStep: 2);
  
  @override
  SellWizardState copyWith({int? currentStep}) {
    return const SellWizardPhotoRemoved();
  }
}

// Step 4: Location Updated
class SellWizardLocationUpdated extends SellWizardState {
  final String latitude;
  final String longitude;
  final String address;
  
  const SellWizardLocationUpdated(
    this.latitude,
    this.longitude,
    this.address,
  ) : super(currentStep: 3);
  
  @override
  List<Object?> get props => [latitude, longitude, address, currentStep];
  
  @override
  SellWizardState copyWith({int? currentStep}) {
    return SellWizardLocationUpdated(
      latitude,
      longitude,
      address,
    );
  }
}

// Pickup Type Selected
class SellWizardPickupTypeSelected extends SellWizardState {
  final PickupType pickupType;
  
  const SellWizardPickupTypeSelected(this.pickupType) : super(currentStep: 3);
  
  @override
  List<Object?> get props => [pickupType, currentStep];
  
  @override
  SellWizardState copyWith({int? currentStep}) {
    return SellWizardPickupTypeSelected(pickupType);
  }
}

// Notes Added
class SellWizardNotesAdded extends SellWizardState {
  final String notes;
  
  const SellWizardNotesAdded(this.notes) : super(currentStep: 3);
  
  @override
  List<Object?> get props => [notes, currentStep];
  
  @override
  SellWizardState copyWith({int? currentStep}) {
    return SellWizardNotesAdded(notes);
  }
}

// Submitting State
class SellWizardSubmitting extends SellWizardState {
  const SellWizardSubmitting() : super(currentStep: 4);
  
  @override
  SellWizardState copyWith({int? currentStep}) {
    return const SellWizardSubmitting();
  }
}

// Success State
class SellWizardSuccess extends SellWizardState {
  final WasteListingModel listing;
  
  const SellWizardSuccess(this.listing) : super(currentStep: 4);
  
  @override
  List<Object?> get props => [listing, currentStep];
  
  @override
  SellWizardState copyWith({int? currentStep}) {
    return SellWizardSuccess(listing);
  }
}

// Error State
class SellWizardError extends SellWizardState {
  final String message;
  
  const SellWizardError(this.message) : super(currentStep: 0);
  
  @override
  List<Object?> get props => [message, currentStep];
  
  @override
  SellWizardState copyWith({int? currentStep}) {
    return SellWizardError(message);
  }
}

// Convenience extension for step information
extension SellWizardStateExtension on SellWizardState {
  bool get isSubmitting => this is SellWizardSubmitting;
  bool get isSuccess => this is SellWizardSuccess;
  bool get isError => this is SellWizardError;
  bool get canProceed {
    if (this is SellWizardSubmitting) return false;
    return true;
  }
  
  String? get errorMessage {
    if (this is SellWizardError) {
      return (this as SellWizardError).message;
    }
    return null;
  }
  
  WasteListingModel? get createdListing {
    if (this is SellWizardSuccess) {
      return (this as SellWizardSuccess).listing;
    }
    return null;
  }
}
