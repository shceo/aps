
import 'package:aps/src/features/admin_panel/data/datasources/exchange_rate_api.dart';
import 'package:aps/src/features/admin_panel/domain/entities/exchange_rate.dart';
import 'package:aps/src/features/admin_panel/domain/repositories/exchange_rate_repository.dart';

class ExchangeRateRepositoryImpl implements ExchangeRateRepository {
  final ExchangeRateApi api;
  ExchangeRateRepositoryImpl(this.api);

  @override
  Future<ExchangeRate> getExchangeRates() {
    return api.fetchRates();
  }
}
