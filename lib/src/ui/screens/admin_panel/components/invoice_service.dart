import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

/// Сервис для работы со счетами и внешними API
class InvoiceService {
  final FirebaseFirestore _firestore;
  InvoiceService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Загружает данные счета по [invoiceId]
  Future<Map<String, dynamic>?> loadInvoice(int invoiceId) async {
    final doc =
        await _firestore.collection('invoices').doc(invoiceId.toString()).get();
    return doc.exists ? doc.data() : null;
  }

  /// Сохраняет данные счета [data] под [invoiceId]
  Future<void> saveInvoice(int invoiceId, Map<String, dynamic> data) async {
    await _firestore
        .collection('invoices')
        .doc(invoiceId.toString())
        .set(data, SetOptions(merge: true));
  }

  /// Подсчитывает сумму всех польских счетов за текущий месяц по [passport]
  Future<double> sumThisMonth(String passport) async {
    final now = DateTime.now();
    final firstOfMonth = DateTime(now.year, now.month, 1);
    final firstOfNextMonth = DateTime(now.year, now.month + 1, 1);

    final qs =
        await _firestore
            .collection('invoices')
            .where('passport', isEqualTo: passport)
            .where(
              'created_at',
              isGreaterThanOrEqualTo: Timestamp.fromDate(firstOfMonth),
            )
            .where(
              'created_at',
              isLessThan: Timestamp.fromDate(firstOfNextMonth),
            )
            .get();

    double sum = 0;
    for (var doc in qs.docs) {
      final data = doc.data();
      final tv = (data['total_value'] as String?) ?? '0';
      sum += double.tryParse(tv) ?? 0;
    }
    return sum;
  }

  /// Запрашивает список районов для региона [region]
  Future<List<String>> fetchDistricts(String region) async {
    final response = await http.post(
      Uri.parse('https://khaledo.pythonanywhere.com/districts/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'region': region}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to load districts');
    }
    final List<dynamic> list = json.decode(response.body);
    return list.cast<String>();
  }

  /// Получает полный список продуктов для автодополнения
  Future<List<Map<String, dynamic>>> fetchProductList() async {
    final response = await http.get(
      Uri.parse('https://khaledo.pythonanywhere.com/products/lists/'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to load product list');
    }
    final List<dynamic> list = json.decode(response.body);
    return list.cast<Map<String, dynamic>>();
  }
}
