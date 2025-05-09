// lib/src/core/di/injection.dart

import 'package:aps/src/features/admin_panel/data/datasources/exchange_rate_api.dart';
import 'package:aps/src/features/admin_panel/data/repository/exchange_rate_repository_impl.dart';
import 'package:aps/src/features/admin_panel/domain/repositories/exchange_rate_repository.dart';
import 'package:aps/src/features/admin_panel/domain/usecases/get_exchange_rates.dart';
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

Future<void> initDi() async {
  // 1) Core / external
  getIt.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );
  getIt.registerLazySingletonAsync<SharedPreferences>(
    () => SharedPreferences.getInstance(),
  );

  getIt.registerLazySingleton<ExchangeRateApi>(() => ExchangeRateApi());
  getIt.registerLazySingleton<ExchangeRateRepository>(
    () => ExchangeRateRepositoryImpl(getIt()),
  );

  // Юз-кейс
  getIt.registerLazySingleton<GetExchangeRates>(
    () => GetExchangeRates(getIt()),

    // getIt.registerFactory<InvoiceViewModel>(
    //   () => InvoiceViewModel(
    //     fetchRatesUseCase: getIt(),
    //     invoiceService: getIt())),
  );
}
