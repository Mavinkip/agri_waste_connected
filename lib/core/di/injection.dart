
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/farmer/data/repositories/farmer_repository.dart';
import '../../features/farmer/data/repositories/listing_repository.dart';
import '../../features/farmer/data/repositories/wallet_repository.dart';
import '../../features/farmer/presentation/bloc/farmer_bloc.dart';
import '../../features/farmer/presentation/bloc/sell_wizard_cubit.dart';
import '../../features/driver/data/repositories/collection_repository.dart';
import '../../features/driver/presentation/bloc/driver_bloc.dart';
import '../../features/admin/data/repositories/admin_repositories.dart';
import '../../features/admin/presentation/bloc/admin_bloc.dart';
import '../network/api_client.dart';
import '../services/connectivity_service.dart';
import '../../shared/services/offline_sync_repository.dart';

final GetIt sl = GetIt.instance;

class Injection {
  static Future<void> init() async {
    // Core
    sl.registerLazySingleton<ApiClient>(() => ApiClient());
    sl.registerLazySingleton<ConnectivityService>(() => ConnectivityService());
    sl.registerLazySingleton<OfflineSyncRepository>(() => OfflineSyncRepository());
    
    // Shared Preferences
    final sharedPreferences = await SharedPreferences.getInstance();
    sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
    
    // Repositories - Auth
    sl.registerLazySingleton<AuthRepository>(() => AuthRepository(apiClient: sl()));
    
    // Repositories - Farmer
    sl.registerLazySingleton<FarmerRepository>(() => FarmerRepository(apiClient: sl()));
    sl.registerLazySingleton<ListingRepository>(() => ListingRepository(
      apiClient: sl(),
      offlineSync: sl(),
    ));
    sl.registerLazySingleton<WalletRepository>(() => WalletRepository(apiClient: sl()));
    
    // Repositories - Driver
    sl.registerLazySingleton<CollectionRepository>(() => CollectionRepository(
      apiClient: sl(),
      offlineSync: sl(),
    ));
    
    // Repositories - Admin
    sl.registerLazySingleton<AdminRepository>(() => AdminRepository(apiClient: sl()));
    
    // BLoCs - Auth
    sl.registerFactory<AuthBloc>(() => AuthBloc(authRepository: sl()));
    
    // BLoCs - Farmer
    sl.registerFactory<FarmerBloc>(() => FarmerBloc(
      farmerRepository: sl(),
      listingRepository: sl(),
      walletRepository: sl(),
    ));
    sl.registerFactory<SellWizardCubit>(() => SellWizardCubit(
      listingRepository: sl(),
    ));
    
    // BLoCs - Driver
    sl.registerFactory<DriverBloc>(() => DriverBloc(
      collectionRepository: sl(),
    ));
    
    // BLoCs - Admin
    sl.registerFactory<AdminBloc>(() => AdminBloc(
      adminRepository: sl(),
    ));
  }
  
  // Helper method to dispose all registered instances if needed
  static Future<void> dispose() async {
    await sl.reset();
  }
}
