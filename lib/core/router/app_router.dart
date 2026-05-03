import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/farm_location_screen.dart';
import '../../features/auth/presentation/screens/waste_profile_screen.dart';
import '../../features/farmer/presentation/screens/farmer_home_screen.dart';
import '../../features/farmer/presentation/screens/earnings_history_screen.dart';
import '../../features/farmer/presentation/screens/schedule_screen.dart';
import '../../features/farmer/presentation/screens/sell_waste/waste_type_screen.dart';
import '../../features/farmer/presentation/screens/sell_waste/quantity_screen.dart';
import '../../features/farmer/presentation/screens/sell_waste/photo_screen.dart';
import '../../features/farmer/presentation/screens/sell_waste/confirm_location_screen.dart';
import '../../features/farmer/presentation/screens/sell_waste/success_screen.dart';
import '../../features/driver/presentation/screens/driver_home_screen.dart';
import '../../features/driver/presentation/screens/arrival_screen.dart';
import '../../features/driver/presentation/screens/routine_evaluation_screen.dart';
import '../../features/driver/presentation/screens/weigh_in_screen.dart';
import '../../features/driver/presentation/screens/quality_check_screen.dart';
import '../../features/driver/presentation/screens/payment_confirm_screen.dart';
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/admin/presentation/screens/fleet_screen.dart';
import '../../features/admin/presentation/screens/pricing_screen.dart';
import '../../features/admin/presentation/screens/inventory_screen.dart';
import '../../features/admin/presentation/screens/routine_management_screen.dart';
import '../../features/admin/presentation/screens/farmer_profile_screen.dart';
import '../../shared/models/user_model.dart';
import '../di/injection.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      // Don't redirect on splash screen
      if (state.matchedLocation == '/splash') {
        return null;
      }
      
      // Check if AuthBloc is registered
      if (!sl.isRegistered<AuthBloc>()) {
        return null;
      }
      
      final authBloc = sl<AuthBloc>();
      final isAuthenticated = authBloc.state is AuthAuthenticated;
      final isLogin = state.matchedLocation == '/login';
      final isRegister = state.matchedLocation == '/register';
      
      // If not authenticated and not on auth screens, redirect to login
      if (!isAuthenticated && !isLogin && !isRegister) {
        return '/login';
      }
      
      // If authenticated and on auth screens, redirect based on role
      if (isAuthenticated && (isLogin || isRegister)) {
        final authState = authBloc.state as AuthAuthenticated;
        final role = authState.user.role;
        
        switch (role) {
          case UserRole.farmer:
            return '/farmer/home';
          case UserRole.driver:
            return '/driver/home';
          case UserRole.admin:
            return '/admin/dashboard';
        }
      }
      
      return null;
    },
    routes: [
      // Auth Routes
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/farm-location',
        name: 'farm-location',
        builder: (context, state) => const FarmLocationScreen(),
      ),
      GoRoute(
        path: '/waste-profile',
        name: 'waste-profile',
        builder: (context, state) => const WasteProfileScreen(),
      ),
      
      // Farmer Routes
      GoRoute(
        path: '/farmer/home',
        name: 'farmer-home',
        builder: (context, state) => const FarmerHomeScreen(),
      ),
      GoRoute(
        path: '/farmer/earnings',
        name: 'farmer-earnings',
        builder: (context, state) => const EarningsHistoryScreen(),
      ),
      GoRoute(
        path: '/farmer/schedule',
        name: 'farmer-schedule',
        builder: (context, state) => const ScheduleScreen(),
      ),
      
      // Farmer Sell Wizard Routes
      GoRoute(
        path: '/farmer/sell/waste-type',
        name: 'sell-waste-type',
        builder: (context, state) => const WasteTypeScreen(),
      ),
      GoRoute(
        path: '/farmer/sell/quantity',
        name: 'sell-quantity',
        builder: (context, state) => const QuantityScreen(),
      ),
      GoRoute(
        path: '/farmer/sell/photo',
        name: 'sell-photo',
        builder: (context, state) => const PhotoScreen(),
      ),
      GoRoute(
        path: '/farmer/sell/location',
        name: 'sell-location',
        builder: (context, state) => const ConfirmLocationScreen(),
      ),
      GoRoute(
        path: '/farmer/sell/success',
        name: 'sell-success',
        builder: (context, state) => const SuccessScreen(),
      ),
      
      // Driver Routes
      GoRoute(
        path: '/driver/home',
        name: 'driver-home',
        builder: (context, state) => const DriverHomeScreen(),
      ),
      GoRoute(
        path: '/driver/arrival/:collectionId',
        name: 'driver-arrival',
        builder: (context, state) {
          final collectionId = state.pathParameters['collectionId']!;
          return ArrivalScreen(collectionId: collectionId);
        },
      ),
      GoRoute(
        path: '/driver/evaluate/:collectionId',
        name: 'driver-evaluate',
        builder: (context, state) {
          final collectionId = state.pathParameters['collectionId']!;
          return RoutineEvaluationScreen(collectionId: collectionId);
        },
      ),
      GoRoute(
        path: '/driver/weigh/:collectionId',
        name: 'driver-weigh',
        builder: (context, state) {
          final collectionId = state.pathParameters['collectionId']!;
          return WeighInScreen(collectionId: collectionId);
        },
      ),
      GoRoute(
        path: '/driver/quality/:collectionId',
        name: 'driver-quality',
        builder: (context, state) {
          final collectionId = state.pathParameters['collectionId']!;
          return QualityCheckScreen(collectionId: collectionId);
        },
      ),
      GoRoute(
        path: '/driver/payment/:collectionId',
        name: 'driver-payment',
        builder: (context, state) {
          final collectionId = state.pathParameters['collectionId']!;
          return PaymentConfirmScreen(collectionId: collectionId);
        },
      ),
      
      // Admin Routes
      GoRoute(
        path: '/admin/dashboard',
        name: 'admin-dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/fleet',
        name: 'admin-fleet',
        builder: (context, state) => const FleetScreen(),
      ),
      GoRoute(
        path: '/admin/pricing',
        name: 'admin-pricing',
        builder: (context, state) => const PricingScreen(),
      ),
      GoRoute(
        path: '/admin/inventory',
        name: 'admin-inventory',
        builder: (context, state) => const InventoryScreen(),
      ),
      GoRoute(
        path: '/admin/routines',
        name: 'admin-routines',
        builder: (context, state) => const RoutineManagementScreen(),
      ),
      GoRoute(
        path: '/admin/farmer/:farmerId',
        name: 'admin-farmer',
        builder: (context, state) {
          final farmerId = state.pathParameters['farmerId']!;
          return FarmerProfileScreen(farmerId: farmerId);
        },
      ),
    ],
  );
}
