import 'dart:convert';
import 'dart:math';
import 'package:aps/l10n/app_localizations.dart';
import 'package:aps/src/core/di/injection.dart';
import 'package:aps/src/features/admin_panel/data/datasources/exchange_rate_api.dart';
import 'package:aps/src/features/admin_panel/data/repository/exchange_rate_repository_impl.dart';
import 'package:aps/src/features/admin_panel/domain/entities/exchange_rate.dart';
import 'package:aps/src/features/admin_panel/domain/usecases/get_exchange_rates.dart';
import 'package:aps/src/features/admin_panel/presentation/widgets/invoice_service.dart';
import 'package:aps/src/features/admin_panel/presentation/widgets/pdf_export.dart';
import 'package:aps/src/features/admin_panel/presentation/widgets/product_input.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class InvoiceFormScreen extends StatefulWidget {
  final int invoiceId;
  const InvoiceFormScreen({super.key, required this.invoiceId});

  @override
  _InvoiceFormScreenState createState() => _InvoiceFormScreenState();
}

class _InvoiceFormScreenState extends State<InvoiceFormScreen> {
  final TextEditingController _orderCodeController = TextEditingController();
  final TextEditingController _senderNameController = TextEditingController();
  final TextEditingController _senderTelController = TextEditingController();
  final TextEditingController _receiverNameController = TextEditingController();
  final TextEditingController _receiverTelController = TextEditingController();
  final TextEditingController _passportController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _bruttoController = TextEditingController();
  final TextEditingController _totalValueController = TextEditingController();
  final TextEditingController _totalDeliverySumController =
      TextEditingController();
  List<TextEditingController> _productNameControllers = [
    TextEditingController(),
  ];
  List<FocusNode> _productNameFocusNodes = [FocusNode()];
  List<TextEditingController> _productQtyControllers = [
    TextEditingController(),
  ];
  List<TextEditingController> _productPriceControllers = [
    TextEditingController(),
  ];

  late final InvoiceService _service;

  bool _isDataModified = false;
  bool _isOverLimit = false;
  bool _isLoading = true;
  bool _submitted = false;
  // bool _warningShown = false;
  bool _citySelected = false;
  String _sixDigit = "";
  String _cityCode = "";
  String? _totalValueError;
  bool _hasSelectedSection = false;
  String _selectedSection = "";
  OverlayEntry? _suggestionsEntry;
  late final GetExchangeRates getRatesUsecase;

  // late final ExchangeRateApi _api;
  // late final ExchangeRateRepositoryImpl _repo;
  // late final GetExchangeRates getRates;

  @override
  void initState() {
    super.initState();
    _service = InvoiceService();

    // _api = ExchangeRateApi();
    // _repo = ExchangeRateRepositoryImpl(_api);
    // getRates = GetExchangeRates(_repo);
    getRatesUsecase = getIt<GetExchangeRates>();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _service.loadInvoice(widget.invoiceId);

      if (data != null) {
        // ——————————————————————————————————————————————
        // 1) Генерируем или парсим order_code
        final dbCode = data['order_code'] as String? ?? '';
        if (dbCode.trim().isEmpty) {
          _generateSixDigitCode();
        } else {
          _orderCodeController.text = dbCode;
          if (dbCode.length >= 6) {
            _sixDigit = dbCode.substring(0, 6);
            _cityCode = dbCode.substring(6);
          }
        }

        // 2) Заполняем остальные простые поля
        _senderNameController.text = data['sender_name'] ?? '';
        _senderTelController.text = data['sender_tel'] ?? '';
        _receiverNameController.text = data['receiver_name'] ?? '';
        _receiverTelController.text = data['receiver_tel'] ?? '';
        _passportController.text = data['passport'] ?? '';
        _birthDateController.text = data['birth_date'] ?? '';
        _addressController.text = data['address'] ?? '';
        _bruttoController.text = data['brutto'] ?? '';
        _totalValueController.text = data['total_value'] ?? '';
        _totalDeliverySumController.text = data['total_delivery_sum'] ?? '';
        if (data['section'] != null) {
          _selectedSection = data['section'];
          _hasSelectedSection = true;
        }

        // 3) Разбираем product_details
        final pd = data['product_details'] as String? ?? '';
        final rawLines =
            pd.split('\n').where((s) => s.trim().isNotEmpty).toList();

        // 4) Очистка старых контроллеров и фокусов для трёх списков
        for (final c in _productNameControllers) c.dispose();
        for (final c in _productQtyControllers) c.dispose();
        for (final c in _productPriceControllers) c.dispose();
        for (final f in _productNameFocusNodes) f.dispose();
        _productNameControllers.clear();
        _productQtyControllers.clear();
        _productPriceControllers.clear();
        _productNameFocusNodes.clear();

        // 5) Наполнение новыми строками
        if (rawLines.isEmpty) {
          _addEmptyProductRow();
        } else {
          for (final line in rawLines) {
            final parts = line.split('|').map((s) => s.trim()).toList();
            _addProductRow(
              name: parts.isNotEmpty ? parts[0] : '',
              qty: parts.length > 1 ? parts[1] : '',
              price: parts.length > 2 ? parts[2] : '',
            );
          }
        }
      } else {
        // Нет данных в БД — генерируем код и одну пустую строку
        _generateSixDigitCode();
        _addEmptyProductRow();
      }
    } catch (e) {
      debugPrint('Ошибка загрузки invoice #${widget.invoiceId}: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Добавляет одну пустую строку
  void _addEmptyProductRow() {
    _addProductRow(name: '', qty: '', price: '');
  }

  /// Добавляет строку с переданными значениями в три поля + создаёт FocusNode для первого поля
  void _addProductRow({
    required String name,
    required String qty,
    required String price,
  }) {
    final nameCtrl = TextEditingController(text: name);
    final qtyCtrl = TextEditingController(text: qty);
    final priceCtrl = TextEditingController(text: price);
    final fn = FocusNode();
    fn.addListener(() {
      if (fn.hasFocus) {
        _showSuggestions(_productNameFocusNodes.indexOf(fn));
      }
    });
    _productNameFocusNodes.add(fn);

    _productNameControllers.add(nameCtrl);
    _productQtyControllers.add(qtyCtrl);
    _productPriceControllers.add(priceCtrl);

    // if (_orderCodeController.text.isEmpty) {
    //   _generateSixDigitCode();
    // }
    // setState(() => _isLoading = false);
  }

  // void _generateSixDigitCode() {
  //   _sixDigit = Random().nextInt(1000000).toString().padLeft(6, '0');
  //   _updateOrderCode();
  // }

  // void _updateOrderCode() {
  //   _orderCodeController.text = _sixDigit + _cityCode;
  // }

  void _generateSixDigitCode() {
    _sixDigit = Random().nextInt(1000000).toString().padLeft(6, '0');
    _updateOrderCode();
    setState(() {});
  }

  void _updateOrderCode() {
    _orderCodeController.text = _sixDigit + _cityCode;
  }

  bool _districtSelected = false;
  Future<void> _selectCityCode() async {
    final loc = AppLocalizations.of(context);
    Map<String, String> cities = {
      "Andijon": "AND",
      "Farg'ona": "FNA",
      "Namangan": "NAM",
      "Navoi": "NVI",
      "Buhoro": "BXR",
      "Samarqand": "SMK",
      "Jizzax": "JZX",
      "Sirdaryo": "SIR",
      "Surxondaryo": "SUR",
      "Qashqadaryo": "QDR",
      "Xorazm": "XRZ",
      "Qoraqalpoq": "QQP",
      "Toshkent": "TSH",
      "Toshkent viloyati": "TSV",
    };
    String? selectedCity = await showDialog<String>(
      context: context,
      builder:
          (_) => SimpleDialog(
            title: Text(loc.chooseCity),
            children:
                cities.keys
                    .map(
                      (city) => SimpleDialogOption(
                        onPressed: () => Navigator.pop(context, city),
                        child: Text(city),
                      ),
                    )
                    .toList(),
          ),
    );
    if (selectedCity != null) {
      _cityCode = cities[selectedCity]!;
      _updateOrderCode();
      _addressController.text = selectedCity;
      _citySelected = true;
      _districtSelected = false;
      setState(() {});
    }
  }

  Future<void> _selectDistrict() async {
    final districts = await _service.fetchDistricts(_addressController.text);

    // if (response.statusCode != 200) return;

    // final List districts = json.decode(response.body) as List;
    final selected = await showDialog<String>(
      context: context,
      builder:
          (_) => SimpleDialog(
            title: Text("Choose district"),
            children:
                districts.map((d) {
                  return SimpleDialogOption(
                    onPressed: () => Navigator.pop(context, d),
                    child: Text(d),
                  );
                }).toList(),
          ),
    );

    if (selected != null) {
      _addressController.text = '${_addressController.text}, $selected';
      _districtSelected = true;
      setState(() => _isDataModified = true);
    }
  }

  void _recalculateTotal() {
    double sum = 0;
    for (var i = 0; i < _productQtyControllers.length; i++) {
      final q = double.tryParse(_productQtyControllers[i].text) ?? 0;
      final p = double.tryParse(_productPriceControllers[i].text) ?? 0;
      sum += q * p;
    }
    setState(() => _totalValueController.text = sum.toStringAsFixed(2));
  }

  bool _validateFields() {
    return _orderCodeController.text.trim().isNotEmpty &&
        _senderNameController.text.trim().isNotEmpty &&
        _senderTelController.text.trim().isNotEmpty &&
        _receiverNameController.text.trim().isNotEmpty &&
        _receiverTelController.text.trim().isNotEmpty &&
        _passportController.text.trim().isNotEmpty &&
        _birthDateController.text.trim().isNotEmpty &&
        _addressController.text.trim().isNotEmpty &&
        // _productControllers.every((c) => c.text.trim().isNotEmpty) &&
        //**************************************************************
        _productNameControllers.every((c) => c.text.trim().isNotEmpty) &&
        _productQtyControllers.every((c) => c.text.trim().isNotEmpty) &&
        _productPriceControllers.every((c) => c.text.trim().isNotEmpty) &&
        //******************************************************************
        _bruttoController.text.trim().isNotEmpty &&
        _totalValueController.text.trim().isNotEmpty &&
        _totalDeliverySumController.text.trim().isNotEmpty &&
        _totalValueError == null;
  }

  Future<void> _saveData() async {
    final loc = AppLocalizations.of(context);
    setState(() => _submitted = true);
    final lines = <String>[];
    for (var i = 0; i < _productNameControllers.length; i++) {
      final name = _productNameControllers[i].text.trim();
      final qty = _productQtyControllers[i].text.trim();
      final price = _productPriceControllers[i].text.trim();
      lines.add('$name | $qty | $price');
    }
    if (!_validateFields()) {
      await showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: Text(loc.errorTitle),
              content: Text(loc.fieldsRequired),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("ОК"),
                ),
              ],
            ),
      );
      return;
    }

    final double total = double.tryParse(_totalValueController.text) ?? 0;
    final sumThisMonth = await _service.sumThisMonth(_passportController.text);

    if (sumThisMonth + total > 200) {
      await showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: Text(loc.errorTitle),
              content: Text(loc.monthlyLimitExceeded),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(loc.ok),
                ),
              ],
            ),
      );
      return;
    }
    try {
      await _service.saveInvoice(widget.invoiceId, {
        'invoice_no': widget.invoiceId,
        'order_code': _orderCodeController.text,
        'sender_name': _senderNameController.text,
        'sender_tel': _senderTelController.text,
        'receiver_name': _receiverNameController.text,
        'receiver_tel': _receiverTelController.text,
        'passport': _passportController.text,
        'birth_date': _birthDateController.text,
        'address': _addressController.text,
        // 'product_details': _productControllers
        //     .map((c) => c.text.trim())
        //     .join('\n'),
        'product_details': lines.join('\n'),

        'brutto': _bruttoController.text,
        'total_value': _totalValueController.text,
        'total_delivery_sum': _totalDeliverySumController.text,
        'created_at': FieldValue.serverTimestamp(),
        'section': _selectedSection,
      });
      SetOptions(merge: true);
      setState(() => _isDataModified = false);
      await showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: Text(loc.successTitle),
              content: Text(loc.successMessage),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text("ОК"),
                ),
              ],
            ),
      );
    } catch (e) {
      await showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: Text(loc.errorTitle),
              content: Text("${loc.saveError}: $e"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("ОК"),
                ),
              ],
            ),
      );
    }
  }

  TableRow _buildTableRow(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    IconData? icon,
    int maxLines = 1,
    bool readOnly = false,
  }) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            // readOnly: false,
            readOnly: readOnly,
            inputFormatters:
                keyboardType == TextInputType.number
                    ? [FilteringTextInputFormatter.digitsOnly]
                    : null,
            decoration: InputDecoration(
              hintText: label,
              prefixIcon: icon != null ? Icon(icon) : null,
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              errorText:
                  controller == _totalValueController ? _totalValueError : null,
            ),
            onChanged: (_) => setState(() => _isDataModified = true),

            //   onChanged: readOnly ? null : (value) => onFieldChanged(field, value),
            //         onChanged: readOnly
            // ? null
            // : (value) {
            //     // 1. отметить, что данные изменились
            //     setState(() => _isDataModified = true);
            //     // 2. передать новое значение наверх
            //     onFieldChanged(field, value);
            //   },
          ),
        ),
      ],
    );
  }

  Future<bool> _onWillPop() async {
    final loc = AppLocalizations.of(context);
    if (_isDataModified) {
      final result = await showDialog<bool>(
        context: context,
        builder:
            (_) => AlertDialog(
              title: Text(loc.warningTitle),
              content: Text(loc.unsavedDataWarning),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(loc.stay),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(loc.leave),
                ),
              ],
            ),
      );
      return result ?? false;
    }
    return true;
  }

  @override
  void dispose() {
    _orderCodeController.dispose();
    _senderNameController.dispose();
    _senderTelController.dispose();
    _receiverNameController.dispose();
    _receiverTelController.dispose();
    _passportController.dispose();
    _birthDateController.dispose();
    _addressController.dispose();
    _bruttoController.dispose();
    _totalValueController.dispose();
    _totalDeliverySumController.dispose();
    for (var c in _productNameControllers) c.dispose();
    for (var c in _productQtyControllers) c.dispose();
    for (var c in _productPriceControllers) c.dispose();
    for (var f in _productNameFocusNodes) f.dispose();

    super.dispose();
  }

  // final List<TextEditingController> _productControllers = [
  //   TextEditingController(),
  // ];
  // final List<FocusNode> _productFocusNodes = [FocusNode()];
  // final int _maxProducts = 40;

  // OverlayEntry? _suggestionsEntry;
  void _removeSuggestions() {
    _suggestionsEntry?.remove();
    _suggestionsEntry = null;
  }

  void _showSuggestions(int index) async {
    // 1. Берём текст из нужного контроллера
    final term = _productNameControllers[index].text.trim();
    // 2. Если пусто — убираем попап и выходим
    if (term.isEmpty) {
      _removeSuggestions();
      return;
    }
    // 3. Ставим фокус на то же поле (если нужно)
    FocusScope.of(context).requestFocus(_productNameFocusNodes[index]);
    // 4. Далее строим и показываем _suggestionsEntry по тому же индексу
    _removeSuggestions();
    final overlay = Overlay.of(context);
    final fieldBox =
        _productNameFocusNodes[index].context!.findRenderObject() as RenderBox;
    final fieldPos = fieldBox.localToGlobal(Offset.zero);
    final fieldSize = fieldBox.size;

    final entry = OverlayEntry(
      builder: (_) {
        return Positioned(
          left: fieldPos.dx,
          top: fieldPos.dy + fieldSize.height,
          width: fieldSize.width,
          child: Material(
            elevation: 4,
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _service.fetchProductList(),
              builder: (ctx, snap) {
                if (!snap.hasData)
                  return SizedBox(
                    height: 100,
                    child: Center(child: CircularProgressIndicator()),
                  );
                final matches =
                    snap.data!
                        .where(
                          (p) => ((p['russian'] ?? '') as String)
                              .toLowerCase()
                              .contains(term.toLowerCase()),
                        )
                        .toList();
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: Icon(Icons.close),
                        onPressed: _removeSuggestions,
                      ),
                    ),
                    if (matches.isEmpty)
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          'No items found',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    Flexible(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        children:
                            matches.map((p) {
                              final name = (p['russian'] ?? '') as String;
                              return ListTile(
                                title: Text(name),
                                onTap: () {
                                  _productNameControllers[index].text = name;
                                  _removeSuggestions();
                                  // при необходимости: перевести фокус дальше
                                  if (index + 1 <
                                      _productNameFocusNodes.length) {
                                    FocusScope.of(context).requestFocus(
                                      _productNameFocusNodes[index + 1],
                                    );
                                  }
                                },
                              );
                            }).toList(),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );

    overlay.insert(entry);
    _suggestionsEntry = entry;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    String passportPrefix = '';

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('${loc.invoice} № ${widget.invoiceId}')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (!_hasSelectedSection) {
      return Scaffold(
        appBar: AppBar(title: Text(loc.chooseSectionTitle), centerTitle: true),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedSection = loc.sectionMail; // например «Почта»
                    _hasSelectedSection = true;
                  });
                },
                child: Text(loc.sectionMail),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedSection =
                        loc.sectionShop; // например «Интернет-магазин»
                    _hasSelectedSection = true;
                  });
                },
                child: Text(loc.sectionShop),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedSection = loc.sectionOther; // «Прочее»
                    _hasSelectedSection = true;
                  });
                },
                child: Text(loc.sectionOther),
              ),
            ],
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '${loc.invoice} № ${widget.invoiceId} - ${loc.selectedSection} $_selectedSection',
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Table(
                    columnWidths: const {
                      0: FlexColumnWidth(1),
                      1: FlexColumnWidth(2),
                    },
                    children: [
                      _buildTableRow(
                        loc.senderName,
                        _senderNameController,
                        icon: Icons.person,
                      ),
                      _buildTableRow(
                        loc.senderTel,
                        _senderTelController,
                        keyboardType: TextInputType.phone,
                        icon: Icons.phone,
                      ),
                      _buildTableRow(
                        loc.receiverName,
                        _receiverNameController,
                        icon: Icons.person_outline,
                      ),
                      _buildTableRow(
                        loc.receiverTel,
                        _receiverTelController,
                        keyboardType: TextInputType.phone,
                        icon: Icons.phone_android,
                      ),

                      TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              loc.passportId,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: TextField(
                              controller: _passportController,
                              keyboardType: TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[\d\.,]'),
                                ),
                              ],
                              decoration: InputDecoration(
                                hintText: loc.passportId,
                                prefixIcon: const Icon(Icons.badge),
                                suffixIcon: IconButton(
                                  icon: const Icon(
                                    Icons.add,
                                    color: Colors.red,
                                  ),
                                  onPressed: () async {
                                    final prefix = await showDialog<String>(
                                      context: context,
                                      builder:
                                          (_) => SimpleDialog(
                                            title: Text(
                                              "loc.choosePassportPrefix",
                                            ),
                                            children:
                                                ['AA', 'AB', 'AC', 'AD', 'AE']
                                                    .map(
                                                      (
                                                        val,
                                                      ) => SimpleDialogOption(
                                                        onPressed:
                                                            () => Navigator.pop(
                                                              context,
                                                              val,
                                                            ),
                                                        child: Text(val),
                                                      ),
                                                    )
                                                    .toList(),
                                          ),
                                    );
                                    if (prefix != null) {
                                      passportPrefix = prefix;
                                      _passportController.text =
                                          '$passportPrefix${_passportController.text.replaceAll(RegExp(r'[^0-9\.,]'), '')}';
                                      _passportController.selection =
                                          TextSelection.fromPosition(
                                            TextPosition(
                                              offset:
                                                  _passportController
                                                      .text
                                                      .length,
                                            ),
                                          );
                                      setState(() {});
                                    }
                                  },
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              onChanged:
                                  (_) => setState(() => _isDataModified = true),
                            ),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              loc.birthDate,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: TextField(
                              controller: _birthDateController,
                              readOnly: true,
                              decoration: InputDecoration(
                                hintText: loc.selectDate,
                                prefixIcon: const Icon(Icons.calendar_today),
                                filled: true,
                                fillColor: Colors.grey[100],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              onTap: () async {
                                DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime.now(),
                                );
                                if (picked != null) {
                                  _birthDateController.text = DateFormat(
                                    'dd.MM.yyyy',
                                  ).format(picked);
                                  setState(() => _isDataModified = true);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              loc.addressFull,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: TextField(
                              controller: _addressController,
                              readOnly: false,
                              decoration: InputDecoration(
                                hintText: loc.addressHint,
                                prefixIcon: const Icon(Icons.location_on),
                                suffixIcon: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.location_city),
                                      color: _citySelected ? Colors.grey : null,
                                      onPressed: _selectCityCode,
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.place),
                                      color:
                                          _districtSelected
                                              ? Colors.grey
                                              : null,
                                      onPressed:
                                          _citySelected
                                              ? _selectDistrict
                                              : null,
                                    ),
                                  ],
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              onChanged:
                                  (_) => setState(() => _isDataModified = true),
                            ),
                          ),
                        ],
                      ),
                      //***************************************************************************************************
                      TableRow(
                        children: [
                          // Левый столбец: «Товары»
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              loc.productDetails,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          // Правый столбец: наш новый виджет
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: ProductInput(
                              nameControllers: _productNameControllers,
                              nameFocusNodes: _productNameFocusNodes,
                              qtyControllers: _productQtyControllers,
                              priceControllers: _productPriceControllers,
                              service: InvoiceService(),

                              // Название само сохраняется в контроллере, колбэк можно оставить пустым
                              onNameChanged: (i, v) {},

                              // При изменении кол-ва или цены — просто пересчитываем сумму
                              onQtyChanged: (i, v) {
                                setState(() {
                                  _recalculateTotal();
                                });
                              },
                              onPriceChanged: (i, v) {
                                setState(() {
                                  _recalculateTotal();
                                });
                              },

                              // Добавляем новую «строку» из трёх контроллеров + FocusNode
                              onAddRow: (i) {
                                setState(() {
                                  _productNameControllers.add(
                                    TextEditingController(),
                                  );
                                  _productNameFocusNodes.add(
                                    FocusNode()..addListener(() {
                                      if (_productNameFocusNodes.last.hasFocus)
                                        context // или используйте метод из ProductInput
                                            .read<InvoiceService>()
                                            .fetchProductList();
                                    }),
                                  );
                                  _productQtyControllers.add(
                                    TextEditingController(),
                                  );
                                  _productPriceControllers.add(
                                    TextEditingController(),
                                  );
                                });
                              },
                            ),
                          ),
                        ],
                      ),

                      // ********************************************************************************************************
                      TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              loc.bruttoWeight,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: TextField(
                              controller: _bruttoController,
                              keyboardType: TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[\d\.,]'),
                                ),
                              ],
                              decoration: InputDecoration(
                                hintText: loc.bruttoWeight,
                                prefixIcon: const Icon(Icons.line_weight),
                                filled: true,
                                fillColor: Colors.grey[100],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                errorText:
                                    _bruttoController.text.isNotEmpty &&
                                            !RegExp(
                                              r'^[\d\.,]+$',
                                            ).hasMatch(_bruttoController.text)
                                        ? loc.digitsOnlyError
                                        : null,
                              ),
                              onChanged:
                                  (_) => setState(() => _isDataModified = true),
                            ),
                          ),
                        ],
                      ),
                      _buildTableRow(
                        readOnly: true,
                        loc.totalValue,
                        _totalValueController,
                        keyboardType: TextInputType.number,
                        icon: Icons.attach_money,
                      ),
                      TableRow(
                        children: [
                          // Левый столбец: метка
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              loc.totalDeliverySum,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // Правый столбец: наш новый виджет
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: FutureBuilder<ExchangeRate>(
                              future: getRatesUsecase(),
                              builder: (_, snap) {
                                final ratesText =
                                    snap.hasData
                                        ? '1 USD = ${snap.data!.usd.toStringAsFixed(2)} сум, '
                                            '1 TRY = ${snap.data!.tryRate.toStringAsFixed(2)} сум'
                                        : 'Загрузка курсов…';
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ratesText,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    GestureDetector(
                                      onTap: () async {
                                        final choice = await showDialog<String>(
                                          context: context,
                                          builder:
                                              (_) => SimpleDialog(
                                                title: Text(
                                                  'Выберите статус доставки',
                                                ),
                                                children: [
                                                  SimpleDialogOption(
                                                    onPressed:
                                                        () => Navigator.pop(
                                                          context,
                                                          'Оплачено',
                                                        ),
                                                    child: Text('Оплачено'),
                                                  ),
                                                  SimpleDialogOption(
                                                    onPressed:
                                                        () => Navigator.pop(
                                                          context,
                                                          'Не оплачено',
                                                        ),
                                                    child: Text('Не оплачено'),
                                                  ),
                                                ],
                                              ),
                                        );
                                        if (choice != null) {
                                          if (choice == 'Оплачено') {
                                            _totalDeliverySumController.text =
                                                choice;
                                          } else {
                                            _totalDeliverySumController.clear();
                                          }
                                          setState(
                                            () => _isDataModified = true,
                                          );
                                        }
                                      },
                                      child: TextField(
                                        controller: _totalDeliverySumController,
                                        readOnly:
                                            _totalDeliverySumController.text ==
                                            'Оплачено',
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          hintText: loc.totalDeliverySum,
                                          prefixIcon: const Icon(
                                            Icons.attach_money,
                                          ),
                                          filled: true,
                                          fillColor: Colors.grey[100],
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                        onChanged:
                                            (_) => setState(
                                              () => _isDataModified = true,
                                            ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _isOverLimit ? null : _saveData,
                    child: Text(loc.save),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      exportInvoicePdfByTemplate(
                        context: context,
                        senderName: _senderNameController.text,
                        senderTel: _senderTelController.text,
                        receiverName: _receiverNameController.text,
                        receiverTel: _receiverTelController.text,
                        cityAddress: _addressController.text,
                        tariff: 'От двери до двери',
                        payment:
                            double.tryParse(_totalValueController.text) ?? 0,
                        weight: double.tryParse(_bruttoController.text) ?? 0,
                        invoiceNumber: _orderCodeController.text,
                        barcodeData: '1082260103',
                        zoneText: 'ZONE 2',
                        pvzText: 'ПВЗ [SPB33] На Звездной',
                      );
                    },
                    child: Text(loc.print),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
