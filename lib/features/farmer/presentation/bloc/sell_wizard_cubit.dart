import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/repositories/listing_repository.dart';
import '../../../../shared/models/waste_listing_model.dart';

part 'sell_wizard_state.dart';

class SellWizardCubit extends Cubit<SellWizardState> {
  final ListingRepository _listingRepository;
  
  // Wizard data
  WasteType? selectedWasteType;
  double? estimatedQuantity;
  String? photoPath;
  bool isPhotoRequired = true;
  String? pickupLat;
  String? pickupLng;
  String? pickupAddress;
  PickupType? pickupType;
  String? notes;
  
  SellWizardCubit({required ListingRepository listingRepository})
      : _listingRepository = listingRepository,
        super(const SellWizardInitial());
  
  // Step 1: Select Waste Type
  void selectWasteType(WasteType wasteType) {
    selectedWasteType = wasteType;
    emit(SellWizardWasteTypeSelected(wasteType));
  }
  
  // Step 2: Enter Quantity
  void enterQuantity(double quantity) {
    estimatedQuantity = quantity;
    emit(SellWizardQuantityEntered(quantity));
  }
  
  // Step 3: Add Photo (Optional)
  void addPhoto(String path) {
    photoPath = path;
    emit(SellWizardPhotoAdded(path));
  }
  
  void skipPhoto() {
    isPhotoRequired = false;
    emit(const SellWizardPhotoSkipped());
  }
  
  void removePhoto() {
    photoPath = null;
    emit(const SellWizardPhotoRemoved());
  }
  
  // Step 4: Confirm Location
  void updatePickupLocation({
    required String latitude,
    required String longitude,
    required String address,
  }) {
    pickupLat = latitude;
    pickupLng = longitude;
    pickupAddress = address;
    emit(SellWizardLocationUpdated(latitude, longitude, address));
  }
  
  // Select Pickup Type
  void selectPickupType(PickupType type) {
    pickupType = type;
    emit(SellWizardPickupTypeSelected(type));
  }
  
  // Add Notes
  void addNotes(String note) {
    notes = note;
    emit(SellWizardNotesAdded(note));
  }
  
  // Submit Listing
  Future<void> submitListing() async {
    // Validate all required fields
    if (selectedWasteType == null) {
      emit(const SellWizardError('Please select a waste type'));
      return;
    }
    
    if (estimatedQuantity == null || estimatedQuantity! <= 0) {
      emit(const SellWizardError('Please enter a valid quantity'));
      return;
    }
    
    if (pickupLat == null || pickupLng == null || pickupAddress == null) {
      emit(const SellWizardError('Please confirm your pickup location'));
      return;
    }
    
    if (pickupType == null) {
      emit(const SellWizardError('Please select pickup type (Routine or Manual)'));
      return;
    }
    
    emit(const SellWizardSubmitting());
    
    try {
      final listing = await _listingRepository.createListing(
        wasteType: selectedWasteType!,
        estimatedQuantity: estimatedQuantity!,
        pickupLat: pickupLat!,
        pickupLng: pickupLng!,
        pickupAddress: pickupAddress!,
        pickupType: pickupType!,
        photos: photoPath, // In production, you'd upload the photo first
        notes: notes,
        isPhotoRequired: isPhotoRequired,
      );
      
      emit(SellWizardSuccess(listing));
      
      // Reset wizard for next use
      resetWizard();
    } catch (e) {
      emit(SellWizardError('Failed to create listing: ${e.toString()}'));
    }
  }
  
  // Navigate to next step
  void nextStep() {
    final currentStep = state.currentStep;
    if (currentStep < 4) {
      emit(state.copyWith(currentStep: currentStep + 1));
    }
  }
  
  // Navigate to previous step
  void previousStep() {
    final currentStep = state.currentStep;
    if (currentStep > 0) {
      emit(state.copyWith(currentStep: currentStep - 1));
    }
  }
  
  // Go to specific step
  void goToStep(int step) {
    if (step >= 0 && step <= 4) {
      emit(state.copyWith(currentStep: step));
    }
  }
  
  // Reset wizard
  void resetWizard() {
    selectedWasteType = null;
    estimatedQuantity = null;
    photoPath = null;
    isPhotoRequired = true;
    pickupLat = null;
    pickupLng = null;
    pickupAddress = null;
    pickupType = null;
    notes = null;
    
    emit(const SellWizardInitial());
  }
  
  // Check if can proceed to next step
  bool canProceed() {
    final currentStep = state.currentStep;
    
    switch (currentStep) {
      case 0: // Waste Type
        return selectedWasteType != null;
      case 1: // Quantity
        return estimatedQuantity != null && estimatedQuantity! > 0;
      case 2: // Photo
        return true; // Photo is optional
      case 3: // Location & Pickup Type
        return pickupLat != null && 
               pickupLng != null && 
               pickupAddress != null && 
               pickupType != null;
      default:
        return false;
    }
  }
  
  // Get step title
  String getStepTitle(int step) {
    switch (step) {
      case 0:
        return 'Select Waste Type';
      case 1:
        return 'Enter Quantity';
      case 2:
        return 'Add Photo';
      case 3:
        return 'Confirm Location';
      case 4:
        return 'Review & Submit';
      default:
        return '';
    }
  }
  
  // Get step description
  String getStepDescription(int step) {
    switch (step) {
      case 0:
        return 'What type of agricultural waste do you have?';
      case 1:
        return 'How much waste do you have (estimated in kg)?';
      case 2:
        return 'Take a photo of your waste (optional)';
      case 3:
        return 'Confirm your pickup location and schedule';
      case 4:
        return 'Review your listing details';
      default:
        return '';
    }
  }
}
