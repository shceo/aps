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

  /// Выбор кода города из диалога; после выбора кода:
  /// 1. К сгенерированному коду добавляется код города;
  /// 2. В поле адреса подставляется полное название выбранного города.
  void _selectCityCode() async {
    if (_sixDigit.isEmpty) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
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
          (context) => SimpleDialog(
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
      // Обновляем код заказа
      _cityCode = cities[selectedCity]!;
      _updateOrderCode();
      // Подставляем полное название выбранного города в поле адреса
      _addressController.text = selectedCity;
      setState(() {});
    }
  }

  /// Загружает данные из Firestore, если документ существует.
  Future<void> _loadData() async {
    try {
      DocumentSnapshot doc =
          await _firestore
              .collection('invoices')
              .doc(widget.invoiceId.toString())
              .get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
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
        // Если ранее сохранённый код заказа существует, разбиваем его
        if (_orderCodeController.text.isNotEmpty &&
            _orderCodeController.text.length >= 6) {
          _sixDigit = _orderCodeController.text.substring(0, 6);
          _cityCode = _orderCodeController.text.substring(6);
        }
      }
    } catch (e) {
      debugPrint("Ошибка загрузки данных: $e");
    }
    // Если кода заказа ещё нет, генерируем его автоматически
    if (_orderCodeController.text.isEmpty) {
      _generateSixDigitCode();
    }
    setState(() {
      _isLoading = false;
    });
  }

  /// Проверка всех обязательных полей.
  /// Заметим, что теперь код заказа не показывается, но используется при сохранении.
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

  /// Сохранение данных в Firestore с проверками.
  Future<void> _saveData() async {
    setState(() {
      _submitted = true;
    });
    if (!_validateFields()) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
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

    double totalValue = double.tryParse(_totalValueController.text) ?? 0;
    if (totalValue > 1000) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
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
          }, SetOptions(merge: true));
      setState(() {
        _isDataModified = false;
      });
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
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
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
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

  /// Обработка изменений в поле стоимости.
  /// Проверка: если введённое значение содержит символы, отличные от цифр,
  /// то устанавливается ошибка.
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
        _isOverLimit = total > 1000;
        _isDataModified = true;
      });
    }
  }

  /// Функция для построения InputDecoration с проверкой обязательности.
  InputDecoration _buildDecoration(
    String label,
    TextEditingController controller,
  ) {
    return InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
      errorText:
          (_submitted && controller.text.trim().isEmpty)
              ? "Обязательное поле"
              : null,
    );
  }

  /// Предупреждение при попытке покинуть страницу без сохранения.
  Future<bool> _onWillPop() async {
    if (_isDataModified) {
      return await showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text("Внимание"),
                  content: const Text(
                    "Данные не сохранены! Покинуть страницу?",
                  ),
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
          ) ??
          false;
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
    // Если данные ещё грузятся, показываем индикатор загрузки.
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text("Invoice № ${widget.invoiceId}")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Если раздел ещё не выбран, показываем экран выбора.
    if (!_hasSelectedSection) {
      return Scaffold(
        appBar: AppBar(title: const Text("Выбор раздела")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedSection = "Коммерция";
                    _hasSelectedSection = true;
                  });
                },
                child: const Text("Коммерция"),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedSection = "Интернет магазин";
                    _hasSelectedSection = true;
                  });
                },
                child: const Text("Интернет магазин"),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedSection = "Тест";
                    _hasSelectedSection = true;
                  });
                },
                child: const Text("Тест"),
              ),
            ],
          ),
        ),
      );
    }

    // Если раздел выбран, показываем основную форму с полями ввода.
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
              // Кнопка выбора города (код заказа генерируется автоматически в фоне)
              ElevatedButton(
                onPressed: _selectCityCode,
                child: const Text("Выбрать город"),
              ),
              const Divider(height: 32),
              TextField(
                controller: _senderNameController,
                decoration: _buildDecoration(
                  "Familya Ism (Jo'natuvchi)",
                  _senderNameController,
                ),
                onChanged: (_) => _isDataModified = true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _senderTelController,
                decoration: _buildDecoration(
                  "Tel nomer (Jo'natuvchi)",
                  _senderTelController,
                ),
                keyboardType: TextInputType.phone,
                onChanged: (_) => _isDataModified = true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _receiverNameController,
                decoration: _buildDecoration(
                  "Familya Ism (Qabul qiluvchi)",
                  _receiverNameController,
                ),
                onChanged: (_) => _isDataModified = true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passportController,
                decoration: _buildDecoration(
                  "Pasport/ID: AD 1234567",
                  _passportController,
                ),
                onChanged: (_) => _isDataModified = true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _birthDateController,
                decoration: _buildDecoration(
                  "Tug'ilgan sana: 11.12.2025",
                  _birthDateController,
                ),
                onChanged: (_) => _isDataModified = true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _addressController,
                decoration: _buildDecoration(
                  "Adress (полный адрес)",
                  _addressController,
                ),
                onChanged: (_) => _isDataModified = true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _productDetailsController,
                decoration: _buildDecoration(
                  "Товарные позиции (например, 1-Tovar nomi-soni-qiymати(\$)-TNVED kodi - позицией и т.д.)",
                  _productDetailsController,
                ),
                maxLines: 5,
                onChanged: (_) => _isDataModified = true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _bruttoController,
                decoration: _buildDecoration(
                  "Jo'natmaning Brutto vazni (kg)",
                  _bruttoController,
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => _isDataModified = true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _totalValueController,
                decoration: InputDecoration(
                  labelText: "Jo'natmaning jami qiymati (\$)",
                  border: const OutlineInputBorder(),
                  errorText:
                      _totalValueError ??
                      ((_submitted && _totalValueController.text.trim().isEmpty)
                          ? "Обязательное поле"
                          : null),
                  fillColor: _isOverLimit ? Colors.red[100] : null,
                  filled: _isOverLimit,
                ),
                keyboardType: TextInputType.number,
                // Ограничиваем ввод только цифрами с помощью фильтра
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: _onTotalValueChanged,
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
                        receiverTel:
                            '8 (495) ...', // или у вас есть отдельный input
                        cityAddress: _addressController.text,
                        remarks: 'нет особых отметок', // либо берёте из input
                        tariff: 'От двери до двери',
                        payment:
                            double.tryParse(_totalValueController.text) ?? 0,
                        // placeNumber: 1, // или у вас где-то хранится число места
                        weight: double.tryParse(_bruttoController.text) ?? 0,
                        invoiceNumber: _orderCodeController.text,
                        barcodeData:
                            '1082260103', // какие данные хотите зашить в штрихкод
                        zoneText: 'ZONE 2', // в примере указывается зона
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
