import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/material.dart';

// Пример функции
Future<void> exportInvoicePdfByTemplate({
  required BuildContext context,
  // Данные, которые вы будете подставлять в шаблон
  required String senderName,
  required String senderTel,
  required String receiverName,
  required String receiverTel,
  required String cityAddress,
  // required String remarks,
  required String tariff,
  required double payment,
  // required int placeNumber,
  required double weight,
  required String invoiceNumber,
  required String barcodeData,
  required String zoneText,
  required String pvzText,
  // Дополнительно: если нужно передать дату или прочие данные
  // required String creationDateTime,
}) async {
  // --- Шаг 1. Загрузка шрифта, поддерживающего кириллицу (например, Roboto)
  final fontData = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
  final customFont = pw.Font.ttf(fontData);

  // --- Шаг 2. Создание PDF документа
  final pdf = pw.Document();

  // --- Шаг 3. Добавляем страницу, на которой воспроизводим нужный шаблон
  pdf.addPage(
    pw.Page(
      pageFormat:
          PdfPageFormat.a4, // Или другой формат, если у вас печать на стикере
      build: (pw.Context context) {
        // Вся страница – это, например, контейнер/колонка со строками
        return pw.Container(
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.black, width: 1),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // 1. Отправитель/Получатель
              _buildTwoLineBlock(
                // Передача кастомного шрифта в виджеты
                font: customFont,
                title1: "Отправитель:",
                value1:
                    senderName.isNotEmpty
                        ? "$senderName\n$senderTel"
                        : "[Не указано]",
                title2: "Получатель:",
                value2:
                    receiverName.isNotEmpty
                        ? "$receiverName\n$receiverTel"
                        : "[Не указано]",
              ),

              // 2. Адрес
              pw.SizedBox(height: 8),
              pw.Text(
                cityAddress,
                style: pw.TextStyle(
                  font: customFont,
                  fontSize: 10,
                  // При необходимости можно указать fallback-шрифты, если в будущем понадобится
                  // fontFallback: [другой шрифт]
                ),
              ),

              // 3. Особые отметки
              pw.SizedBox(height: 8),
              // pw.Text(
              //   "Особые отметки: $remarks",
              //   style: pw.TextStyle(font: customFont, fontSize: 10),
              // ),

              // Линия-разделитель
              pw.Divider(height: 15, color: PdfColors.black),

              // 4. Тариф, сумма, место, вес, габариты
              pw.Text(
                "Тариф: $tariff",
                style: pw.TextStyle(font: customFont, fontSize: 10),
              ),
              pw.Text(
                "Общяя стоимость посылки: $payment",
                style: pw.TextStyle(font: customFont, fontSize: 10),
              ),
              // pw.Text(
              //   "Место №: $placeNumber",
              //   style: pw.TextStyle(font: customFont, fontSize: 10),
              // ),
              pw.Text(
                "Вес: $weight",
                style: pw.TextStyle(font: customFont, fontSize: 10),
              ),
              pw.Divider(height: 18, color: PdfColors.black),

              pw.SizedBox(height: 6),
              // 5. Номер отправления и большой штрихкод
              pw.Text(
                invoiceNumber,
                style: pw.TextStyle(
                  font: customFont,
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 6),
              // Блок со штрихкодом
              pw.Center(
                child: pw.BarcodeWidget(
                  data: barcodeData, // данные для штрихкода
                  barcode: pw.Barcode.code128(),
                  width: 200,
                  height: 50,
                  drawText: false,
                ),
              ),
              pw.Divider(height: 15, color: PdfColors.black),

              // Ещё один отступ
              pw.SizedBox(height: 12),

              // 6. Подписи SPL, ПВЗ, ZONE
              pw.Text(
                "SPL",
                style: pw.TextStyle(
                  font: customFont,
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                pvzText, // Например: "ПВЗ [SPB33] На Звездной"
                style: pw.TextStyle(font: customFont, fontSize: 11),
              ),
              pw.Text(
                zoneText, // Например: "ZONE 2"
                style: pw.TextStyle(font: customFont, fontSize: 14),
              ),

              pw.SizedBox(height: 12),
            ],
          ),
        );
      },
    ),
  );

  // --- Шаг 4. Отображаем диалог печати / сохранения PDF
  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}

/// Вспомогательный виджет для вывода двух колонок типа:
/// "Отправитель: ..."     "Получатель: ..."
pw.Widget _buildTwoLineBlock({
  required pw.Font font,
  required String title1,
  required String value1,
  required String title2,
  required String value2,
}) {
  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      // Левая часть
      pw.Expanded(
        flex: 1,
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              title1,
              style: pw.TextStyle(
                font: font,
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text(value1, style: pw.TextStyle(font: font, fontSize: 10)),
          ],
        ),
      ),
      // Правая часть
      pw.SizedBox(width: 16),
      pw.Expanded(
        flex: 1,
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              title2,
              style: pw.TextStyle(
                font: font,
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text(value2, style: pw.TextStyle(font: font, fontSize: 10)),
          ],
        ),
      ),
    ],
  );
}
