// invoice_form_screen.dart
import 'dart:math';
import 'package:aps/src/ui/components/pdf_export.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Для фильтра ввода

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
  final TextEditingController _passportController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _productDetailsController =
      TextEditingController();
  final TextEditingController _bruttoController = TextEditingController();
  final TextEditingController _totalValueController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Переменные для генерации кода заказа (6-значный код + код города)
  String _sixDigit = "";
  String _cityCode = "";

  // Переменная для хранения ошибки поля стоимости
  String? _totalValueError;

  // Флаги состояния
  bool _isDataModified = false;
  bool _isOverLimit = false;
  bool _isLoading = true;
  bool _submitted = false;
  bool _warningShown = false;

  // Переменные для выбора раздела
  bool _hasSelectedSection = false;
  String _selectedSection = "";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Обновление значения кода заказа (без его показа в UI)
  void _updateOrderCode() {
    _orderCodeController.text = _sixDigit + _cityCode;
  }

  /// Генерация 6-значного кода; вызывается автоматически,
  /// если ранее сгенерированного кода нет.
  void _generateSixDigitCode() {
    String code = Random().nextInt(1000000).toString().padLeft(6, '0');
    _sixDigit = code;
    _updateOrderCode();
    setState(() {});
  }

  /// Выбор кода города из диалога
  void _selectCityCode() async {
    if (_sixDigit.isEmpty) {
      await showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text("Ошибка"),
              content: const Text("Сначала сгенерируйте код."),
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
            title: const Text("Выберите город"),
            children:
                cities.keys.map((city) {
                  return SimpleDialogOption(
                    onPressed: () => Navigator.pop(context, city),
                    child: Text(city),
                  );
                }).toList(),
          ),
    );
    if (selectedCity != null) {
      _cityCode = cities[selectedCity]!;
      _updateOrderCode();
      _addressController.text = selectedCity;
      setState(() {});
    }
  }

  /// Загрузка данных
  Future<void> _loadData() async {
    try {
      final doc =
          await _firestore
              .collection('invoices')
              .doc(widget.invoiceId.toString())
              .get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _orderCodeController.text = data['order_code'] ?? "";
        _senderNameController.text = data['sender_name'] ?? "";
        _senderTelController.text = data['sender_tel'] ?? "";
        _receiverNameController.text = data['receiver_name'] ?? "";
        _passportController.text = data['passport'] ?? "";
        _birthDateController.text = data['birth_date'] ?? "";
        _addressController.text = data['address'] ?? "";
        _productDetailsController.text = data['product_details'] ?? "";
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
      }
    } catch (e) {
      debugPrint("Ошибка загрузки данных: $e");
    }
    if (_orderCodeController.text.isEmpty) _generateSixDigitCode();
    setState(() => _isLoading = false);
  }

  /// Валидация полей
  bool _validateFields() {
    return _orderCodeController.text.trim().isNotEmpty &&
        _senderNameController.text.trim().isNotEmpty &&
        _senderTelController.text.trim().isNotEmpty &&
        _receiverNameController.text.trim().isNotEmpty &&
        _passportController.text.trim().isNotEmpty &&
        _birthDateController.text.trim().isNotEmpty &&
        _addressController.text.trim().isNotEmpty &&
        _productDetailsController.text.trim().isNotEmpty &&
        _bruttoController.text.trim().isNotEmpty &&
        _totalValueController.text.trim().isNotEmpty &&
        _totalValueError == null;
  }

  /// Сохранение данных
  Future<void> _saveData() async {
    setState(() => _submitted = true);
    if (!_validateFields()) {
      await showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text("Ошибка"),
              content: const Text(
                "Все поля обязательны для заполнения и должны быть корректны.",
              ),
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
    final totalValue = double.tryParse(_totalValueController.text) ?? 0;
    if (totalValue > 1000) {
      await showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text("Ошибка"),
              content: const Text(
                "Заказ более 1000 долларов. Сохранение невозможно.",
              ),
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
            'passport': _passportController.text,
            'birth_date': _birthDateController.text,
            'address': _addressController.text,
            'product_details': _productDetailsController.text,
            'brutto': _bruttoController.text,
            'total_value': _totalValueController.text,
            'section': _selectedSection,
          }, SetOptions(merge: true));
      setState(() => _isDataModified = false);
      await showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text("Успех"),
              content: const Text("Данные успешно сохранены!"),
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
              title: const Text("Ошибка"),
              content: Text("Ошибка при сохранении: $e"),
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

  /// Обработка изменения стоимости
  void _onTotalValueChanged(String value) {
    if (value.isNotEmpty && !RegExp(r'^\d+$').hasMatch(value)) {
      setState(() {
        _totalValueError = "Доступны для ввода только цифры";
      });
    } else {
      setState(() {
        _totalValueError = null;
      });
      double total = double.tryParse(value) ?? 0;

      // Предупреждение при достижении суммы больше 850 и меньше 1000
      if (total >= 850 && total < 1000 && !_warningShown) {
        _warningShown = true;
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text("Внимание"),
                content: const Text("Осталось немного до лимита \$1000"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("ОК"),
                  ),
                ],
              ),
        );
      } else if (total < 850) {
        _warningShown = false;
      }

      setState(() {
        _isOverLimit = total > 1000; // Проверка на превышение лимита
        _isDataModified = true;
      });
    }
  }

  /// Обновлённый декоратор для таблицы
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
    if (_isDataModified) {
      final result = await showDialog<bool>(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text("Внимание"),
              content: const Text("Данные не сохранены! Покинуть страницу?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Остаться"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("Выйти"),
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
    _passportController.dispose();
    _birthDateController.dispose();
    _addressController.dispose();
    _productDetailsController.dispose();
    _bruttoController.dispose();
    _totalValueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text("Invoice № ${widget.invoiceId}")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (!_hasSelectedSection) {
      return Scaffold(
        appBar: AppBar(title: const Text("Выбор раздела")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    _selectedSection = "Коммерция";
                    _hasSelectedSection = true;
                  });
                  await _firestore
                      .collection('invoices')
                      .doc(widget.invoiceId.toString())
                      .set({
                        'section': _selectedSection,
                      }, SetOptions(merge: true));
                },
                child: const Text("Коммерция"),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    _selectedSection = "Интернет магазин";
                    _hasSelectedSection = true;
                  });
                  await _firestore
                      .collection('invoices')
                      .doc(widget.invoiceId.toString())
                      .set({
                        'section': _selectedSection,
                      }, SetOptions(merge: true));
                },
                child: const Text("Интернет магазин"),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    _selectedSection = "Тест";
                    _hasSelectedSection = true;
                  });
                  await _firestore
                      .collection('invoices')
                      .doc(widget.invoiceId.toString())
                      .set({
                        'section': _selectedSection,
                      }, SetOptions(merge: true));
                },
                child: const Text("Тест"),
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
            "Invoice № ${widget.invoiceId} - Выбран: $_selectedSection",
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: _selectCityCode,
                child: const Text("Выбрать город"),
              ),
              const Divider(height: 32),
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
                        "Familya Ism (Jo'natuvchi)",
                        _senderNameController,
                        icon: Icons.person,
                      ),
                      _buildTableRow(
                        "Tel nomer (Jo'natuvchi)",
                        _senderTelController,
                        keyboardType: TextInputType.phone,
                        icon: Icons.phone,
                      ),
                      _buildTableRow(
                        "Familya Ism (Qabul qiluvchi)",
                        _receiverNameController,
                        icon: Icons.person_outline,
                      ),
                      _buildTableRow(
                        "Pasport/ID: AD 1234567",
                        _passportController,
                        icon: Icons.badge,
                      ),
                      _buildTableRow(
                        "Tug'ilgan sana: 11.12.2025",
                        _birthDateController,
                        icon: Icons.calendar_today,
                      ),
                      _buildTableRow(
                        "Adress (полный адрес)",
                        _addressController,
                        icon: Icons.location_on,
                      ),
                      _buildTableRow(
                        "Товарные позиции (например, 1-Tovar nomi-soni-qiymати(\$)-TNVED kodi)",
                        _productDetailsController,
                        maxLines: 5,
                        icon: Icons.inventory,
                      ),
                      _buildTableRow(
                        "Jo'nатманинг Brutto vazни (kg)",
                        _bruttoController,
                        keyboardType: TextInputType.number,
                        icon: Icons.line_weight,
                      ),
                      _buildTableRow(
                        "Jo'nатманинг jami йилимати (\$)",
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
                    child: const Text("Сохранить"),
                  ),

                  ElevatedButton(
                    onPressed: () {
                      exportInvoicePdfByTemplate(
                        context: context,
                        senderName: _senderNameController.text,
                        senderTel: _senderTelController.text,
                        receiverName: _receiverNameController.text,
                        receiverTel: '8 (495) ...',
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
                    child: const Text("Распечатать"),
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
