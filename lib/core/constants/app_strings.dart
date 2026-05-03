// lib/core/constants/app_strings.dart
class AppStrings {
  // App name
  static const String appName = 'Agri-Waste Connect';
  
  // Auth screens
  static const String loginTitle = 'Welcome Back';
  static const String loginSubtitle = 'Sign in to continue';
  static const String registerTitle = 'Create Account';
  static const String registerSubtitle = 'Join the agricultural waste revolution';
  static const String phoneNumber = 'Phone Number';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String fullName = 'Full Name';
  static const String login = 'Login';
  static const String register = 'Register';
  static const String forgotPassword = 'Forgot Password?';
  static const String dontHaveAccount = 'Don\'t have an account? ';
  static const String alreadyHaveAccount = 'Already have an account? ';
  static const String signUp = 'Sign Up';
  
  // Role strings
  static const String roleFarmer = 'Farmer';
  static const String roleDriver = 'Driver';
  static const String roleAdmin = 'Administrator';
  
  // Waste types
  static const String cropResidue = 'Crop Residue';
  static const String fruitWaste = 'Fruit Waste';
  static const String vegetableWaste = 'Vegetable Waste';
  static const String livestockManure = 'Livestock Manure';
  static const String coffeeHusks = 'Coffee Husks';
  static const String riceHulls = 'Rice Hulls';
  static const String cornStover = 'Corn Stover';
  static const String other = 'Other';
  
  // Units
  static const String kg = 'kg';
  static const String ton = 'ton';
  static const String tons = 'tons';
  
  // Common actions
  static const String submit = 'Submit';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String back = 'Back';
  static const String next = 'Next';
  static const String save = 'Save';
  static const String edit = 'Edit';
  static const String delete = 'Delete';
  static const String close = 'Close';
  
  // Error messages
  static const String networkError = 'Network connection error';
  static const String serverError = 'Server error occurred';
  static const String authError = 'Authentication failed';
  static const String invalidPhone = 'Please enter a valid phone number';
  static const String invalidPassword = 'Password must be at least 6 characters';
  static const String passwordsDoNotMatch = 'Passwords do not match';
  static const String requiredField = 'This field is required';
  static const String somethingWentWrong = 'Something went wrong. Please try again.';
  
  // Success messages
  static const String loginSuccess = 'Login successful!';
  static const String registerSuccess = 'Registration successful!';
  static const String listingCreated = 'Waste listing created successfully';
  static const String paymentProcessed = 'Payment processed successfully';
  
  // Farmer screens
  static const String farmerHome = 'Farmer Dashboard';
  static const String sellWaste = 'Sell Waste';
  static const String myEarnings = 'My Earnings';
  static const String mySchedule = 'My Schedule';
  static const String totalEarned = 'Total Earned';
  static const String activeListings = 'Active Listings';
  static const String completedSales = 'Completed Sales';
  static const String consistencyScore = 'Consistency Score';
  
  // Sell wizard
  static const String selectWasteType = 'Select Waste Type';
  static const String enterQuantity = 'Enter Quantity';
  static const String estimatedWeight = 'Estimated Weight';
  static const String addPhotos = 'Add Photos (Optional)';
  static const String confirmPickupLocation = 'Confirm Pickup Location';
  static const String listingSuccess = 'Listing Created!';
  static const String driverWillContact = 'A driver will contact you shortly';
  
  // Driver screens
  static const String driverHome = 'Driver Dashboard';
  static const String assignedCollections = 'Assigned Collections';
  static const String completePickup = 'Complete Pickup';
  static const String weighWaste = 'Weigh Waste';
  static const String qualityCheck = 'Quality Check';
  static const String confirmPayment = 'Confirm Payment';
  static const String routineEvaluation = 'Routine Evaluation';
  
  // Admin screens
  static const String adminDashboard = 'Admin Dashboard';
  static const String fleetManagement = 'Fleet Management';
  static const String pricingManagement = 'Pricing Management';
  static const String inventoryManagement = 'Inventory Management';
  static const String routeManagement = 'Route Management';
  
  // M-Pesa
  static const String mpesaPayment = 'M-Pesa Payment';
  static const String paymentConfirmation = 'Payment Confirmation';
  static const String paymentSuccessful = 'Payment Successful!';
  static const String transactionId = 'Transaction ID';
  
  // USSD
  static const String ussdCode = '*384*50#';
  static const String ussdMessage = 'Dial $ussdCode to access our USSD service';
  
  // Offline
  static const String offlineMode = 'You are offline';
  static const String syncing = 'Syncing data...';
  static const String syncComplete = 'Sync complete';

  static const String rememberMe = 'Remember Me';
}
