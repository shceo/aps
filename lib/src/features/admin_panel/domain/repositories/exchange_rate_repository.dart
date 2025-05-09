import '../entities/exchange_rate.dart';

abstract class ExchangeRateRepository {
  Future<ExchangeRate> getExchangeRates();
}
