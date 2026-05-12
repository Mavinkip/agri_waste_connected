import 'package:flutter/material.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/farmer/presentation/screens/farmer_home_screen.dart';
import '../../features/farmer/presentation/screens/join_community_screen.dart';

class AppRoutes {
  static const splash             = '/splash';
  static const login              = '/login';
  static const register           = '/register';
  static const farmerHome         = '/farmer/home';
  static const farmerCommunities  = '/farmer/communities';
  static const farmerSellWasteType= '/farmer/sell/waste-type';
  static const farmerEarnings     = '/farmer/earnings';
  static const farmerSchedule     = '/farmer/schedule';
  static const farmerProfile      = '/farmer/profile';
  static const farmerNotifications= '/farmer/notifications';
  static const farmerHelp         = '/farmer/help';
  static const adminDashboard     = '/admin/dashboard';
  static const driverHome         = '/driver/home';
  static const companyDashboard   = '/company/dashboard';

  static Map<String, WidgetBuilder> get routes => {
    splash:            (_) => const SplashScreen(),
    login:             (_) => const LoginScreen(),
    farmerHome:        (_) => const FarmerHomeScreen(),
    farmerCommunities: (_) => const JoinCommunityScreen(),
  };
}
