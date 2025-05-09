// import 'package:aps/src/features/admin_panel/domain/entities/exchange_rate.dart';
// import 'package:aps/src/features/admin_panel/domain/usecases/get_exchange_rates.dart';
// import 'package:aps/src/features/admin_panel/presentation/widgets/invoice_service.dart';
// import 'package:flutter/widgets.dart';

// class InvoiceViewModel extends ChangeNotifier {
//   final GetExchangeRates fetchRatesUseCase;
//   final InvoiceService invoiceService;

//   ExchangeRate? _rates;
//   bool _loadingRates = false;
//   String? _error;

//   InvoiceViewModel({
//     required this.fetchRatesUseCase,
//     required this.invoiceService,
//   });

//   ExchangeRate? get rates => _rates;
//   bool get loadingRates => _loadingRates;
//   String? get error => _error;

//   Future<void> loadExchangeRates() async {
//     _loadingRates = true;
//     _error = null;
//     notifyListeners();
//     try {
//       _rates = await fetchRatesUseCase();
//     } catch (e) {
//       _error = e.toString();
//     } finally {
//       _loadingRates = false;
//       notifyListeners();
//     }
//   }

//   // здесь же можете вынести логику выбора «оплачено/не оплачено» и флаг readOnly
// }
