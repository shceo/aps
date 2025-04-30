import 'dart:convert';
import 'dart:math';
import 'package:aps/l10n/app_localizations.dart';
import 'package:aps/src/ui/components/pdf_export.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Для фильтра ввода
import 'package:intl/intl.dart'; // Для форматирования даты
import 'package:http/http.dart' as http;

class InvoiceFormScreen extends StatefulWidget {
  final int invoiceId;
  const InvoiceFormScreen({super.key, required this.invoiceId});

  @override
  _InvoiceFormScreenState createState() => _InvoiceFormScreenState();
}

class _InvoiceFormScreenState extends State<InvoiceFormScreen> {
  // Контроллеры для ввода данных
  final TextEditingController _orderCodeController = TextEditingController();
  final TextEditingController _senderNameController = TextEditingController();
  final TextEditingController _senderTelController = TextEditingController();
  final TextEditingController _receiverNameController = TextEditingController();
  final TextEditingController _receiverTelController =
      TextEditingController(); // Новое поле
  final TextEditingController _passportController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _productDetailsController =
      TextEditingController();
  final TextEditingController _bruttoController = TextEditingController();
  final TextEditingController _totalValueController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Флаги состояния
  bool _isDataModified = false;
  bool _isOverLimit = false;
  bool _isLoading = true;
  bool _submitted = false;
  bool _warningShown = false;
  bool _citySelected = false; // для кнопки выбора города

  // Генерация кода заказа
  String _sixDigit = "";
  String _cityCode = "";

  // Ошибка стоимости
  String? _totalValueError;

  // Раздел
  bool _hasSelectedSection = false;
  String _selectedSection = "";

  @override
  void initState() {
    super.initState();
    _loadData();
    for (var i = 0; i < _productFocusNodes.length; i++) {
      _productFocusNodes[i].addListener(() {
        if (_productFocusNodes[i].hasFocus) {
          _showSuggestions(i);
        }
      });
    }
  }

  Future<void> _loadData() async {
    try {
      final doc =
          await _firestore
              .collection('invoices')
              .doc(widget.invoiceId.toString())
              .get();

      if (doc.exists) {
        final data = doc.data()!;

        // Заполняем основные поля
        _orderCodeController.text = data['order_code'] ?? "";
        _senderNameController.text = data['sender_name'] ?? "";
        _senderTelController.text = data['sender_tel'] ?? "";
        _receiverNameController.text = data['receiver_name'] ?? "";
        _receiverTelController.text = data['receiver_tel'] ?? "";
        _passportController.text = data['passport'] ?? "";
        _birthDateController.text = data['birth_date'] ?? "";
        _addressController.text = data['address'] ?? "";
        _citySelected = _addressController.text.isNotEmpty;
        _bruttoController.text = data['brutto'] ?? "";
        _totalValueController.text = data['total_value'] ?? "";

        if (_orderCodeController.text.length >= 6) {
          _sixDigit = _orderCodeController.text.substring(0, 6);
          _cityCode = _orderCodeController.text.substring(6);
        }
        if (data['section'] != null) {
          _selectedSection = data['section'];
          _hasSelectedSection = true;
        }

        // Обработка product_details
        final pd = data['product_details'] as String? ?? '';
        final lines = pd.split('\n').where((s) => s.trim().isNotEmpty).toList();

        // Удаляем старые контроллеры и фокусы
        for (var c in _productControllers) {
          c.dispose();
        }
        for (var f in _productFocusNodes) {
          f.dispose();
        }
        _productControllers.clear();
        _productFocusNodes.clear();

        // Создаём новые контроллеры и фокусы
        for (var i = 0; i < lines.length; i++) {
          final ctrl = TextEditingController(text: lines[i]);
          final fn = FocusNode();
          fn.addListener(() {
            if (fn.hasFocus) {
              _showSuggestions(_productFocusNodes.indexOf(fn));
            }
          });

          _productControllers.add(ctrl);
          _productFocusNodes.add(fn);
        }

        // Если не было записей — добавляем одно пустое поле
        if (_productControllers.isEmpty) {
          final ctrl = TextEditingController();
          final fn = FocusNode();
          fn.addListener(() {
            if (fn.hasFocus) {
              _showSuggestions(_productFocusNodes.indexOf(fn));
            }
          });
          _productControllers.add(ctrl);
          _productFocusNodes.add(fn);
        }
      }
    } catch (e) {
      debugPrint("Ошибка загрузки данных: $e");
    }

    if (_orderCodeController.text.isEmpty) {
      _generateSixDigitCode();
    }
    setState(() => _isLoading = false);
  }

  void _generateSixDigitCode() {
    _sixDigit = Random().nextInt(1000000).toString().padLeft(6, '0');
    _updateOrderCode();
    setState(() {});
  }

  void _updateOrderCode() {
    _orderCodeController.text = _sixDigit + _cityCode;
  }

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
      setState(() {});
    }
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
        // _productDetailsController.text.trim().isNotEmpty &&
        _productControllers.every((c) => c.text.trim().isNotEmpty) &&
        _bruttoController.text.trim().isNotEmpty &&
        _totalValueController.text.trim().isNotEmpty &&
        _totalValueError == null;
  }

  Future<void> _saveData() async {
    final loc = AppLocalizations.of(context);
    setState(() => _submitted = true);
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
    double total = double.tryParse(_totalValueController.text) ?? 0;
    if (total > 1000) {
      await showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: Text(loc.errorTitle),
              content: Text(loc.overLimitError),
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
    try {
      await _firestore
          .collection('invoices')
          .doc(widget.invoiceId.toString())
          .set({
            'invoice_no': widget.invoiceId,
            'order_code': _orderCodeController.text,
            'sender_name': _senderNameController.text,
            'sender_tel': _senderTelController.text,
            'receiver_name': _receiverNameController.text,
            'receiver_tel': _receiverTelController.text, // сохранение
            'passport': _passportController.text,
            'birth_date': _birthDateController.text,
            'address': _addressController.text,
            'product_details': _productControllers
                .map((c) => c.text.trim())
                .join('\n'),

            'brutto': _bruttoController.text,
            'total_value': _totalValueController.text,
            'section': _selectedSection,
          }, SetOptions(merge: true));
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

  void _onTotalValueChanged(String value) {
    final loc = AppLocalizations.of(context);
    if (value.isNotEmpty && !RegExp(r'^\d+\$').hasMatch(value)) {
      setState(() => _totalValueError = loc.digitsOnlyError);
    } else {
      setState(() => _totalValueError = null);
      double total = double.tryParse(value) ?? 0;
      if (total >= 850 && total < 1000 && !_warningShown) {
        _warningShown = true;
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text(loc.warningTitle),
                content: Text(loc.closeToLimit),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("ОК"),
                  ),
                ],
              ),
        );
      } else if (total < 850) {
        _warningShown = false;
      }
      setState(() {
        _isOverLimit = total > 1000;
        _isDataModified = true;
      });
    }
  }

  TableRow _buildTableRow(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    IconData? icon,
    int maxLines = 1,
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
            readOnly: false,
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
          ),
        ),
      ],
    );
  }

  /// Предупреждение при покидании страницы
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
    _productDetailsController.dispose();
    _bruttoController.dispose();
    _totalValueController.dispose();
    for (var c in _productControllers) c.dispose();
    for (var f in _productFocusNodes) f.dispose();
    super.dispose();
  }

  List<TextEditingController> _productControllers = [TextEditingController()];
  List<FocusNode> _productFocusNodes = [FocusNode()];
  int _maxProducts = 40;

  OverlayEntry? _suggestionsEntry;

  // Метод удаления:
  void _removeSuggestions() {
    _suggestionsEntry?.remove();
    _suggestionsEntry = null;
  }

  void _showSuggestions(int index) async {
    final term = _productControllers[index].text.trim();
    if (term.isEmpty) {
      _removeSuggestions();
      return;
    }

    _removeSuggestions();

    final overlay = Overlay.of(context);
    final fieldBox =
        _productFocusNodes[index].context!.findRenderObject() as RenderBox;
    final fieldPos = fieldBox.localToGlobal(Offset.zero);
    final fieldSize = fieldBox.size;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) {
        return Positioned(
          left: fieldPos.dx,
          top: fieldPos.dy + fieldSize.height,
          width: fieldSize.width,
          child: Material(
            elevation: 4,
            child: FutureBuilder<http.Response>(
              future: http.get(
                Uri.parse('https://khaledo.pythonanywhere.com/products/lists/'),
              ),
              builder: (ctx, snap) {
                if (!snap.hasData) {
                  return const SizedBox(
                    height: 100,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final List products = json.decode(snap.data!.body);
                final matches =
                    products.where((p) {
                      final name = (p['english'] ?? '') as String;
                      return name.toLowerCase().contains(term.toLowerCase());
                    }).toList();

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: _removeSuggestions,
                      ),
                    ),
                    if (matches.isEmpty)
                      const Padding(
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
                              final name = (p['english'] ?? '') as String;
                              return ListTile(
                                title: Text(name),
                                onTap: () {
                                  _productControllers[index].text =
                                      '${index + 1}. $name';
                                  _productControllers[index]
                                      .selection = TextSelection.fromPosition(
                                    TextPosition(
                                      offset:
                                          _productControllers[index]
                                              .text
                                              .length,
                                    ),
                                  );
                                  _removeSuggestions();
                                  if (index + 1 < _productControllers.length) {
                                    FocusScope.of(context).requestFocus(
                                      _productFocusNodes[index + 1],
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
    String _passportPrefix = '';

    final loc = AppLocalizations.of(context);
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('${loc.invoice} № ${widget.invoiceId}')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (!_hasSelectedSection) {}

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
                                      _passportPrefix = prefix;
                                      _passportController.text =
                                          '$_passportPrefix${_passportController.text.replaceAll(RegExp(r'[^0-9\.,]'), '')}';
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
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.location_city),
                                  color: _citySelected ? Colors.grey : null,
                                  onPressed: _selectCityCode,
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
                              loc.productDetails,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Column(
                              children: [
                                ...List.generate(_productControllers.length, (
                                  i,
                                ) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    child: TextField(
                                      controller: _productControllers[i],
                                      focusNode: _productFocusNodes[i],
                                      decoration: InputDecoration(
                                        hintText:
                                            '${i + 1}. ${loc.productDetails}',
                                        suffixIcon: IconButton(
                                          icon: const Icon(
                                            Icons.add,
                                            color: Colors.green,
                                          ),
                                          onPressed: () {
                                            if (_productControllers[i].text
                                                .trim()
                                                .isEmpty)
                                              return;
                                            if (_productControllers.length <
                                                _maxProducts) {
                                              _productControllers.add(
                                                TextEditingController(),
                                              );
                                              _productFocusNodes.add(
                                                FocusNode(),
                                              );
                                              setState(() {});
                                              FocusScope.of(
                                                context,
                                              ).requestFocus(
                                                _productFocusNodes.last,
                                              );
                                            }
                                          },
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
                                      // Заменили onChanged:
                                      onChanged: (_) => _showSuggestions(i),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),

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
                        loc.totalValue,
                        _totalValueController,
                        keyboardType: TextInputType.number,
                        icon: Icons.attach_money,
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
