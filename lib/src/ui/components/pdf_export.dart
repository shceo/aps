// pdf_exporter.dart
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<void> exportInvoicePdf({
  required BuildContext context,
  required String orderCode,
  required String senderName,
  required String senderTel,
  required String receiverName,
  required String passport,
  required String birthDate,
  required String address,
  required String productDetails,
  required String brutto,
  required String totalValue,
}) async {
  // Проверка заполненности всех полей
  if (orderCode.trim().isEmpty ||
      senderName.trim().isEmpty ||
      senderTel.trim().isEmpty ||
      receiverName.trim().isEmpty ||
      passport.trim().isEmpty ||
      birthDate.trim().isEmpty ||
      address.trim().isEmpty ||
      productDetails.trim().isEmpty ||
      brutto.trim().isEmpty ||
      totalValue.trim().isEmpty) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Ошибка экспорта"),
        content:
            const Text("Для экспорта в PDF все поля, включая Код заказа, должны быть заполнены."),
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

  // Формирование PDF-документа
  final pdf = pw.Document();
  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Table.fromTextArray(
          border: pw.TableBorder.all(),
          cellAlignment: pw.Alignment.centerLeft,
          headerStyle: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 12,
          ),
          cellStyle: pw.TextStyle(fontSize: 10),
          data: <List<String>>[
            <String>['Поля', 'Значения'],
            <String>['Код заказа', orderCode],
            <String>['Familya Ism (Jo\'natuvchi)', senderName],
            <String>['Tel nomer (Jo\'natuvchi)', senderTel],
            <String>['Familya Ism (Qabul qiluvchi)', receiverName],
            <String>['Pasport/ID', passport],
            <String>['Tug\'ilgan sana', birthDate],
            <String>['Adress', address],
            <String>['Товарные позиции', productDetails],
            <String>['Brutto (kg)', brutto],
            <String>['Общая стоимость (\$)', totalValue],
          ],
        );
      },
    ),
  );

  // Вызов диалога печати/скачивания PDF
  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}
