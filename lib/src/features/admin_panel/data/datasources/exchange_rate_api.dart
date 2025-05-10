import 'dart:convert';
import 'package:aps/src/features/admin_panel/domain/entities/exchange_rate.dart';
import 'package:http/http.dart' as http;

class ExchangeRateApi {
  /// Базовый URL теперь возвращает объект вида:
  /// {
  ///   "1_usd_in_uzs": 12900.09,
  ///   "1_usd_in_TL": 38.74
  /// }
  final String baseUrl;
  ExchangeRateApi({
    this.baseUrl = 'https://khaledo.pythonanywhere.com/convert/',
  });

  Future<ExchangeRate> fetchRates() async {
    final resp = await http.get(Uri.parse(baseUrl));
    if (resp.statusCode != 200) {
      throw Exception(
        'Failed to load exchange rates (status ${resp.statusCode})',
      );
    }
    // Парсим JSON как Map, а не List
    final Map<String, dynamic> data =
        json.decode(resp.body) as Map<String, dynamic>;

    // Извлекаем по новым ключам
    final usdRate = (data['1_usd_in_uzs'] as num).toDouble();
    final tryRate = (data['1_usd_in_TL'] as num).toDouble();

    return ExchangeRate(usd: usdRate, tryRate: tryRate);
  }
}
