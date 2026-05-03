import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

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

final GetIt sl = GetIt.instance;

class Injection {
  static Future<void> init() async {
    // Firebase instances
    sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
    sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
    sl.registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);

    // Shared Preferences
    final sharedPreferences = await SharedPreferences.getInstance();
    sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

    // Repositories
    sl.registerLazySingleton<AuthRepository>(() => AuthRepository(
          auth: sl(),
          firestore: sl(),
        ));

    sl.registerLazySingleton<FarmerRepository>(() => FarmerRepository(
          firestore: sl(),
          auth: sl(),
        ));

    sl.registerLazySingleton<ListingRepository>(() => ListingRepository(
          firestore: sl(),
          storage: sl(),
          auth: sl(),
        ));

    sl.registerLazySingleton<WalletRepository>(() => WalletRepository(
          firestore: sl(),
          auth: sl(),
        ));

    sl.registerLazySingleton<CollectionRepository>(() => CollectionRepository(
          firestore: sl(),
          storage: sl(),
          auth: sl(),
        ));

    sl.registerLazySingleton<AdminRepository>(() => AdminRepository(
          firestore: sl(),
          auth: sl(),
        ));

    // BLoCs
    sl.registerFactory<AuthBloc>(() => AuthBloc(authRepository: sl()));

    sl.registerFactory<FarmerBloc>(() => FarmerBloc(
          farmerRepository: sl(),
          listingRepository: sl(),
          walletRepository: sl(),
        ));

    sl.registerFactory<SellWizardCubit>(() => SellWizardCubit(
          listingRepository: sl(),
        ));

    sl.registerFactory<DriverBloc>(() => DriverBloc(
          collectionRepository: sl(),
        ));

    sl.registerFactory<AdminBloc>(() => AdminBloc(
          adminRepository: sl(),
        ));
  }

  static Future<void> dispose() async {
    await sl.reset();
  }
}
