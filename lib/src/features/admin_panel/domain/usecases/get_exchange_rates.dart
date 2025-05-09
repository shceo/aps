import '../entities/exchange_rate.dart';
import '../repositories/exchange_rate_repository.dart';

class GetExchangeRates {
  final ExchangeRateRepository repo;
  GetExchangeRates(this.repo);

  Future<ExchangeRate> call() => repo.getExchangeRates();
}
