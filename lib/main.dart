import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'core/services/navigation_service.dart';
import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';

import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/auth/presentation/screens/language_selection_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/farmer/presentation/screens/farmer_home_screen.dart';
import 'features/farmer/presentation/screens/sell_waste/waste_type_screen.dart';
import 'features/farmer/presentation/screens/sell_waste/quantity_screen.dart';
import 'features/farmer/presentation/screens/sell_waste/photo_screen.dart';
import 'features/farmer/presentation/screens/sell_waste/confirm_location_screen.dart';
import 'features/farmer/presentation/screens/sell_waste/success_screen.dart';
import 'features/farmer/presentation/screens/earnings_history_screen.dart';
import 'features/driver/presentation/screens/driver_login_screen.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Already initialized — safe to ignore on hot restart
  }

  try {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  } catch (e) {
    // Settings already applied
  }

  await Injection.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agri-Waste Connect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      navigatorKey: NavigationService.navigatorKey,
      initialRoute: '/splash',
      routes: {
        '/splash':               (context) => const SplashScreen(),
        '/language':             (context) => const LanguageSelectionScreen(),
        '/login':                (context) => const LoginScreen(),
        '/register':             (context) => const RegisterScreen(),
        '/farmer/home':          (context) => const FarmerHomeScreen(),
        '/farmer/sell/waste-type': (context) => const WasteTypeScreen(),
        '/farmer/sell/quantity': (context) => const QuantityScreen(),
        '/farmer/sell/photo':    (context) => const PhotoScreen(),
        '/farmer/sell/location': (context) => const ConfirmLocationScreen(),
        '/farmer/sell/success':  (context) => const SuccessScreen(),
        '/farmer/earnings':      (context) => const EarningsHistoryScreen(),
        '/driver/login':         (context) => const DriverLoginScreen(),
        '/driver/route':         (context) => const DriverRouteScreen(),
        '/driver/arrival':       (context) => const ArrivalScreen(collectionId: 'test123'),
        '/driver/weigh':         (context) => const WeighInScreen(collectionId: 'test123'),
        '/driver/quality':       (context) => const QualityCheckScreen(collectionId: 'test123'),
        '/driver/payment':       (context) => const PaymentConfirmationScreen(collectionId: 'test123'),
        '/driver/offline':       (context) => const OfflineModeScreen(),
        '/admin/login':          (context) => const AdminLoginScreen(),
        '/admin/dashboard':      (context) => const AdminDashboardScreen(),
        '/admin/fleet':          (context) => const FleetManagementScreen(),
        '/admin/pricing':        (context) => const PriceControllerScreen(),
        '/admin/inventory':      (context) => const InventoryTrackerScreen(),
        '/admin/farmer':         (context) => const FarmerProfileScreen(farmerId: 'farmer123'),
      },
    );
  }
}
