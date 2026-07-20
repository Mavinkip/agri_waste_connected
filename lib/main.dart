import 'core/services/local_storage_service.dart';
import 'core/services/connectivity_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'features/admin/presentation/screens/company_management_screen.dart';
import 'features/admin/presentation/screens/pickup_management_screen.dart';
import 'features/company/presentation/screens/company_dashboard_screen.dart';
import 'firebase_options.dart';
import 'core/services/navigation_service.dart';
import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';

import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/auth/presentation/screens/language_selection_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/auth/presentation/screens/forgot_password_screen.dart';
import 'features/farmer/presentation/screens/profile_screen.dart';
import 'features/farmer/presentation/screens/notifications_screen.dart';
import 'features/farmer/presentation/screens/help_screen.dart';
import 'features/farmer/presentation/screens/farmer_home_screen.dart';
import 'features/farmer/presentation/screens/sell_waste/waste_type_screen.dart';
import 'features/farmer/presentation/screens/sell_waste/quantity_screen.dart';
import 'features/farmer/presentation/screens/sell_waste/photo_screen.dart';
import 'features/farmer/presentation/screens/sell_waste/confirm_location_screen.dart';
import 'features/farmer/presentation/screens/sell_waste/success_screen.dart';
import 'features/farmer/presentation/screens/earnings_history_screen.dart';
import 'features/farmer/presentation/screens/schedule_screen.dart';
import 'features/farmer/presentation/screens/join_community_screen.dart';
import 'features/farmer/presentation/bloc/farmer_bloc.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/farmer/presentation/bloc/sell_wizard_cubit.dart';
import 'features/driver/presentation/screens/driver_login_screen.dart';
import 'features/driver/presentation/screens/driver_home_screen.dart';
import 'features/driver/presentation/screens/driver_route_screen.dart';
import 'features/driver/presentation/screens/arrival_screen.dart';
import 'features/driver/presentation/screens/weigh_in_screen.dart';
import 'features/driver/presentation/screens/quality_check_screen.dart';
import 'features/driver/presentation/screens/payment_confirmation_screen.dart';
import 'features/driver/presentation/screens/offline_mode_screen.dart';
import 'features/admin/presentation/screens/admin_login_screen.dart';
import 'features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'features/admin/presentation/screens/fleet_management_screen.dart';
import 'features/admin/presentation/screens/price_controller_screen.dart';
import 'features/admin/presentation/screens/inventory_tracker_screen.dart';
import 'features/admin/presentation/screens/farmer_profile_screen.dart';
import 'features/auth/presentation/screens/register_driver_screen.dart';

import 'features/admin/presentation/screens/community_management_screen.dart';
import 'features/admin/presentation/screens/community_detail_screen.dart';
import 'features/admin/presentation/screens/companies_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ─── Show splash screen immediately ───
  runApp(const MyApp());

  // ─── Initialize Firebase in the background ───
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized');
  } catch (e) {
    debugPrint('Firebase already initialized: $e');
  }

  // ─── Initialize Firestore settings ───
  try {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  } catch (e) {
    debugPrint('Firestore settings error: $e');
  }

  // ─── Initialize Dependency Injection ───
  try {
    await Injection.init();
  } catch (e) {
    debugPrint('Injection init error: $e');
  }

  // ─── Initialize Local Storage ───
  try {
    await LocalStorageService.init();
  } catch (e) {
    debugPrint('LocalStorage init error: $e');
  }

  // ─── Initialize Connectivity ───
  try {
    final connectivity = ConnectivityService();
    await connectivity.checkConnection();
  } catch (e) {
    debugPrint('Connectivity init error: $e');
  }

  print('✅ All services initialized');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<FarmerBloc>(
          create: (context) => sl<FarmerBloc>(),
        ),
        BlocProvider<AuthBloc>(
          create: (context) => sl<AuthBloc>(),
        ),
        BlocProvider<SellWizardCubit>(
          create: (context) => sl<SellWizardCubit>(),
        ),
      ],
      child: MaterialApp(
        title: 'Agri Cycle',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        navigatorKey: NavigationService.navigatorKey,
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/language': (context) => const LanguageSelectionScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/forgot-password': (context) => ForgotPasswordScreen(),
          '/farmer/home': (context) => const FarmerHomeScreen(),
          '/farmer/profile': (context) => const ProfileScreen(),
          '/farmer/notifications': (context) => const NotificationsScreen(),
          '/farmer/help': (context) => const HelpScreen(),
          '/farmer/sell/waste-type': (context) => const WasteTypeScreen(),
          '/farmer/sell/quantity': (context) => const QuantityScreen(),
          '/farmer/sell/photo': (context) => const PhotoScreen(),
          '/farmer/sell/location': (context) => const ConfirmLocationScreen(),
          '/farmer/sell/success': (context) => const SuccessScreen(),
          '/farmer/earnings': (context) => const EarningsHistoryScreen(),
          '/farmer/schedule': (context) => const ScheduleScreen(),
          '/farmer/communities': (context) => const JoinCommunityScreen(),
          '/register-driver': (context) => const RegisterDriverScreen(),
          '/driver/home': (context) => const DriverHomeScreen(),
          '/driver/login': (context) => const DriverLoginScreen(),
          '/driver/route': (context) => const DriverRouteScreen(),
          '/driver/arrival': (context) =>
          const ArrivalScreen(collectionId: 'test123'),
          '/driver/weigh': (context) =>
          const WeighInScreen(collectionId: 'test123'),
          '/driver/quality': (context) =>
          const QualityCheckScreen(collectionId: 'test123'),
          '/driver/payment': (context) =>
          const PaymentConfirmationScreen(collectionId: 'test123'),
          '/driver/offline': (context) => const OfflineModeScreen(),
          '/admin/login': (context) => const AdminLoginScreen(),
          '/admin/dashboard': (context) => const AdminDashboardScreen(),
          '/admin/fleet': (context) => const FleetManagementScreen(),
          '/admin/pricing': (context) => const PriceControllerScreen(),
          '/admin/inventory': (context) => const InventoryTrackerScreen(),
          '/admin/communities': (context) => const CommunityManagementScreen(),
          '/admin/companies': (context) => const CompaniesScreen(),
          '/admin/companies': (context) => const CompanyManagementScreen(),
          '/company/dashboard': (context) => const CompanyDashboardScreen(),
          '/admin/pickups': (context) => const PickupManagementScreen(),
          '/admin/farmer': (context) =>
          const FarmerProfileScreen(farmerId: 'farmer123'),
        },
      ),
    );
  }
}