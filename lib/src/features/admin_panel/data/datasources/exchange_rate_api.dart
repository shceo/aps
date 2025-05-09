import 'dart:convert';
import 'package:aps/src/features/admin_panel/domain/entities/exchange_rate.dart';
import 'package:http/http.dart' as http;

class ExchangeRateApi {
  final String baseUrl;
  ExchangeRateApi({this.baseUrl = 'https://nbu.uz/uz/exchange-rates/json/'});

  Future<ExchangeRate> fetchRates() async {
    final resp = await http.get(Uri.parse(baseUrl));
    if (resp.statusCode != 200) {
      throw Exception('Failed to load exchange rates');
    }
    final List data = json.decode(resp.body) as List;
    final usd = (data.firstWhere((e) => e['code']=='USD')['rate'] as num).toDouble();
    final tryRate = (data.firstWhere((e) => e['code']=='TRY')['rate'] as num).toDouble();
    return ExchangeRate(usd: usd, tryRate: tryRate);
  }
}
