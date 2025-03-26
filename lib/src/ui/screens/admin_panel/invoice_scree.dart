import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class InvoiceFormScreen extends StatefulWidget {
  final int invoiceId;
  const InvoiceFormScreen({Key? key, required this.invoiceId}) : super(key: key);

  @override
  _InvoiceFormScreenState createState() => _InvoiceFormScreenState();
}

class _InvoiceFormScreenState extends State<InvoiceFormScreen> {
  // Контроллеры для обязательных полей
  final TextEditingController _senderNameController = TextEditingController(); // Familya Ism (Jo'natuvchi)
  final TextEditingController _senderTelController = TextEditingController(); // Tel nomer (Jo'natuvchi)
  final TextEditingController _receiverNameController = TextEditingController(); // Familya Ism (Qabul qiluvchi)
  final TextEditingController _passportController = TextEditingController(); // Pasport/ID: AD 1234567
  final TextEditingController _birthDateController = TextEditingController(); // Tug'ilgan sana: 11.12.2025
  final TextEditingController _addressController = TextEditingController(); // Adress
  final TextEditingController _productDetailsController = TextEditingController(); // Товарные позиции (1,2,...40)
  final TextEditingController _bruttoController = TextEditingController(); // Jo'natmaning Brutto vazni (kg)
  final TextEditingController _totalValueController = TextEditingController(); // Jo'natmaning jami qiymati ($)

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isDataModified = false;
  bool _isOverLimit = false; // Флаг превышения лимита по стоимости
  bool _isLoading = true;    // Флаг загрузки данных из БД
  bool _submitted = false;   // Флаг попытки сохранения, для показа ошибок в полях
  bool _warningShown = false; // Флаг, чтобы предупреждение о достижении лимита показывалось один раз

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Загружает данные из Firestore, если документ существует.
  Future<void> _loadData() async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('invoices')
          .doc(widget.invoiceId.toString())
          .get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        _senderNameController.text = data['sender_name'] ?? "";
        _senderTelController.text = data['sender_tel'] ?? "";
        _receiverNameController.text = data['receiver_name'] ?? "";
        _passportController.text = data['passport'] ?? "";
        _birthDateController.text = data['birth_date'] ?? "";
        _addressController.text = data['address'] ?? "";
        _productDetailsController.text = data['product_details'] ?? "";
        _bruttoController.text = data['brutto'] ?? "";
        _totalValueController.text = data['total_value'] ?? "";
      }
    } catch (e) {
      debugPrint("Ошибка загрузки данных: $e");
    }
    setState(() {
      _isLoading = false;
    });
  }

  /// Проверка всех обязательных полей
  bool _validateFields() {
    return _senderNameController.text.trim().isNotEmpty &&
        _senderTelController.text.trim().isNotEmpty &&
        _receiverNameController.text.trim().isNotEmpty &&
        _passportController.text.trim().isNotEmpty &&
        _birthDateController.text.trim().isNotEmpty &&
        _addressController.text.trim().isNotEmpty &&
        _productDetailsController.text.trim().isNotEmpty &&
        _bruttoController.text.trim().isNotEmpty &&
        _totalValueController.text.trim().isNotEmpty;
  }

  /// Сохранение данных в Firestore с проверками
  Future<void> _saveData() async {
    setState(() {
      _submitted = true;
    });
    if (!_validateFields()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Ошибка"),
          content: const Text("Все поля обязательны для заполнения."),
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
        builder: (context) => AlertDialog(
          title: const Text("Ошибка"),
          content:
              const Text("Заказ более 1000 долларов. Сохранение невозможно."),
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
        'sender_name': _senderNameController.text,
        'sender_tel': _senderTelController.text,
        'receiver_name': _receiverNameController.text,
        'passport': _passportController.text,
        'birth_date': _birthDateController.text,
        'address': _addressController.text,
        'product_details': _productDetailsController.text,
        'brutto': _bruttoController.text,
        'total_value': _totalValueController.text,
      });
      setState(() {
        _isDataModified = false;
      });
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
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
        builder: (context) => AlertDialog(
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

  /// Экспорт данных в PDF по шаблону (таблица)
  Future<void> _exportPdf() async {
    // Если не все поля заполнены, выводим предупреждение
    if (!_validateFields()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Ошибка экспорта"),
          content: const Text(
              "Для экспорта в PDF все поля должны быть заполнены."),
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

    // Формируем PDF-документ с использованием пакета pdf
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Table.fromTextArray(
            context: context,
            border: pw.TableBorder.all(),
            cellAlignment: pw.Alignment.centerLeft,
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 12,
            ),
            cellStyle: pw.TextStyle(fontSize: 10),
            data: <List<String>>[
              <String>['Поля', 'Значения'],
              <String>['Familya Ism (Jo\'natuvchi)', _senderNameController.text],
              <String>['Tel nomer (Jo\'natuvchi)', _senderTelController.text],
              <String>['Familya Ism (Qabul qiluvchi)', _receiverNameController.text],
              <String>['Pasport/ID', _passportController.text],
              <String>['Tug\'ilgan sana', _birthDateController.text],
              <String>['Adress', _addressController.text],
              <String>['Товарные позиции', _productDetailsController.text],
              <String>['Brutto (kg)', _bruttoController.text],
              <String>['Общая стоимость (\$)', _totalValueController.text],
            ],
          );
        },
      ),
    );

    // Экспортируем PDF (например, для мобильных устройств откроется диалог печати/скачивания)
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  /// Обработка изменений в поле общей стоимости
  void _onTotalValueChanged(String value) {
    double total = double.tryParse(value) ?? 0;
    if (total >= 850 && total < 1000 && !_warningShown) {
      _warningShown = true;
      // Показываем предупреждение в виде диалога
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
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

  /// Функция для построения InputDecoration с проверкой обязательности
  InputDecoration _buildDecoration(String label, TextEditingController controller) {
    return InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
      errorText: (_submitted && controller.text.trim().isEmpty) ? "Обязательное поле" : null,
    );
  }

  /// Предупреждение при попытке покинуть страницу без сохранения
  Future<bool> _onWillPop() async {
    if (_isDataModified) {
      return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
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
          ) ??
          false;
    }
    return true;
  }

  @override
  void dispose() {
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
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(title: Text("Invoice № ${widget.invoiceId}")),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Familya Ism (Jo'natuvchi)
              TextField(
                controller: _senderNameController,
                decoration: _buildDecoration("Familya Ism (Jo'natuvchi)", _senderNameController),
                onChanged: (_) => _isDataModified = true,
              ),
              const SizedBox(height: 12),
              // Tel nomer (Jo'natuvchi)
              TextField(
                controller: _senderTelController,
                decoration: _buildDecoration("Tel nomer (Jo'natuvchi)", _senderTelController),
                keyboardType: TextInputType.phone,
                onChanged: (_) => _isDataModified = true,
              ),
              const SizedBox(height: 12),
              // Familya Ism (Qabul qiluvchi)
              TextField(
                controller: _receiverNameController,
                decoration: _buildDecoration("Familya Ism (Qabul qiluvchi)", _receiverNameController),
                onChanged: (_) => _isDataModified = true,
              ),
              const SizedBox(height: 12),
              // Pasport/ID: AD 1234567
              TextField(
                controller: _passportController,
                decoration: _buildDecoration("Pasport/ID: AD 1234567", _passportController),
                onChanged: (_) => _isDataModified = true,
              ),
              const SizedBox(height: 12),
              // Tug'ilgan sana: 11.12.2025
              TextField(
                controller: _birthDateController,
                decoration: _buildDecoration("Tug'ilgan sana: 11.12.2025", _birthDateController),
                onChanged: (_) => _isDataModified = true,
              ),
              const SizedBox(height: 12),
              // Adress
              TextField(
                controller: _addressController,
                decoration: _buildDecoration("Adress (полный адрес)", _addressController),
                onChanged: (_) => _isDataModified = true,
              ),
              const SizedBox(height: 12),
              // Товарные позиции (многострочный ввод)
              TextField(
                controller: _productDetailsController,
                decoration: _buildDecoration("Товарные позиции (например, 1-Tovar nomi-soni-qiymati(\$)-TNVED kodi - pozitsiyasi и т.д.)", _productDetailsController),
                maxLines: 5,
                onChanged: (_) => _isDataModified = true,
              ),
              const SizedBox(height: 12),
              // Jo'natmaning Brutto vazni (kg)
              TextField(
                controller: _bruttoController,
                decoration: _buildDecoration("Jo'natmaning Brutto vazni (kg)", _bruttoController),
                keyboardType: TextInputType.number,
                onChanged: (_) => _isDataModified = true,
              ),
              const SizedBox(height: 12),
              // Jo'natmaning jami qiymati ($)
              TextField(
                controller: _totalValueController,
                decoration: InputDecoration(
                  labelText: "Jo'natmaning jami qiymati (\$)",
                  border: const OutlineInputBorder(),
                  errorText: (_submitted && _totalValueController.text.trim().isEmpty)
                      ? "Обязательное поле"
                      : null,
                  fillColor: _isOverLimit ? Colors.red[100] : null,
                  filled: _isOverLimit,
                ),
                keyboardType: TextInputType.number,
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
                    onPressed: _exportPdf,
                    child: const Text("Экспорт в PDF"),
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
