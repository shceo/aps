// lib/src/core/di/injection.dart

import 'package:aps/src/features/user_interface/presentation/cubit/order_code_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Datasources / APIs
// import '../../features/user/data/datasources/firestore_api.dart';
// import '../../features/user/data/datasources/prefs_api.dart';

// Repositories
// import '../../features/user/data/repositories/order_repository_impl.dart';
// import '../../features/user/domain/repositories/order_repository.dart';

// Use cases
// import '../../features/user/domain/usecases/verify_order_code_usecase.dart';

// ViewModels / Cubits
// import '../../features/user/presentation/cubit/order_code_cubit.dart';

final GetIt getIt = GetIt.instance;

Future<void> initDI() async {
  // 1) Core / external
  getIt.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );
  getIt.registerLazySingletonAsync<SharedPreferences>(
    () => SharedPreferences.getInstance(),
  );

  // // 2) Datasources
  // getIt.registerLazySingleton<FirestoreApi>(
  //   () => FirestoreApi(getIt<FirebaseFirestore>()),
  // );
  // getIt.registerLazySingleton<PrefsApi>(
  //   () => PrefsApi(getIt<SharedPreferences>()),
  // );

  // // 3) Repositories
  // getIt.registerLazySingleton<OrderRepository>(
  //   () => OrderRepositoryImpl(
  //     firestoreApi: getIt<FirestoreApi>(),
  //     prefsApi: getIt<PrefsApi>(),
  //   ),
  // );

  // // 4) Use cases
  // getIt.registerLazySingleton<VerifyOrderCodeUseCase>(
  //   () => VerifyOrderCodeUseCase(getIt<OrderRepository>()),
  // );

  // // 5) ViewModels / Cubits
  // getIt.registerFactory<OrderCodeCubit>(
  //   () => OrderCodeCubit(getIt<VerifyOrderCodeUseCase>()),
  // );
}
