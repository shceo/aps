// lib/src/features/admin_panel/presentation/view_models/invoice_form_cubit.dart

import 'dart:math';
import 'package:aps/src/features/admin_panel/presentation/widgets/invoice_service.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart'; // для BuildContext, showDialog, showDatePicker
import 'package:intl/intl.dart'; // для форматирования даты
import 'package:aps/l10n/app_localizations.dart'; // для локализации
import 'package:aps/src/features/admin_panel/presentation/widgets/pdf_export.dart'; // для exportInvoicePdfByTemplate

part 'invoice_form_state.dart';

class InvoiceFormCubit extends Cubit<InvoiceFormState> {
  final InvoiceService _service;

  InvoiceFormCubit({InvoiceService? service})
    : _service = service ?? InvoiceService(),
      super(InvoiceFormState.initial());

  /// Загружает данные из Firestore
  Future<void> loadInvoice(int invoiceId) async {
    emit(state.copyWith(status: FormStatus.loading));
    try {
      final data = await _service.loadInvoice(invoiceId);
      if (data != null) {
        emit(
          state.copyWith(
            status: FormStatus.loaded,
            orderCode: data['order_code'] ?? '',
            senderName: data['sender_name'] ?? '',
            senderTel: data['sender_tel'] ?? '',
            receiverName: data['receiver_name'] ?? '',
            receiverTel: data['receiver_tel'] ?? '',
            passport: data['passport'] ?? '',
            birthDate: data['birth_date'] ?? '',
            address: data['address'] ?? '',
            brutto: data['brutto'] ?? '',
            totalValue: data['total_value'] ?? '',
            totalDeliverySum: data['total_delivery_sum'] ?? '',
            productDetails:
                (data['product_details'] as String? ?? '')
                    .split('\n')
                    .where((s) => s.isNotEmpty)
                    .toList(),
            selectedSection: data['section'] ?? '',
            isDirty: false,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: FormStatus.failure,
            errorMessage: 'Invoice not found',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(status: FormStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  /// Обновляет любое текстовое поле формы
  void updateField(FormField field, String value) {
    switch (field) {
      case FormField.orderCode:
        emit(state.copyWith(orderCode: value, isDirty: true));
        break;
      case FormField.senderName:
        emit(state.copyWith(senderName: value, isDirty: true));
        break;
      case FormField.senderTel:
        emit(state.copyWith(senderTel: value, isDirty: true));
        break;
      case FormField.receiverName:
        emit(state.copyWith(receiverName: value, isDirty: true));
        break;
      case FormField.receiverTel:
        emit(state.copyWith(receiverTel: value, isDirty: true));
        break;
      case FormField.passport:
        emit(state.copyWith(passport: value, isDirty: true));
        break;
      case FormField.birthDate:
        emit(state.copyWith(birthDate: value, isDirty: true));
        break;
      case FormField.address:
        emit(state.copyWith(address: value, isDirty: true));
        break;
      case FormField.brutto:
        emit(state.copyWith(brutto: value, isDirty: true));
        break;
      case FormField.totalValue:
        final error = _validateNumber(value) ? null : 'Digits only';
        emit(
          state.copyWith(
            totalValue: value,
            totalValueError: error,
            isDirty: true,
          ),
        );
        break;
      case FormField.totalDeliverySum:
        emit(state.copyWith(totalDeliverySum: value, isDirty: true));
        break;
    }
  }

  /// Генерирует шестизначный код и обновляет поле orderCode
  void generateSixDigit() {
    final code = Random().nextInt(1000000).toString().padLeft(6, '0');
    emit(state.copyWith(orderCode: code + state.cityCode, isDirty: true));
  }

  /// Сохраняет форму в Firestore через сервис
  Future<void> save(int invoiceId) async {
    if (!state.canSubmit) {
      emit(state.copyWith(status: FormStatus.validationError));
      return;
    }
    emit(state.copyWith(status: FormStatus.submitting));
    try {
      await _service.saveInvoice(invoiceId, {
        'order_code': state.orderCode,
        'sender_name': state.senderName,
        'sender_tel': state.senderTel,
        'receiver_name': state.receiverName,
        'receiver_tel': state.receiverTel,
        'passport': state.passport,
        'birth_date': state.birthDate,
        'address': state.address,
        'product_details': state.productDetails.join('\n'),
        'brutto': state.brutto,
        'total_value': state.totalValue,
        'total_delivery_sum': state.totalDeliverySum,
        'section': state.selectedSection,
      });
      emit(state.copyWith(status: FormStatus.success, isDirty: false));
    } catch (e) {
      emit(
        state.copyWith(status: FormStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  /// Добавляет новый пустой товар после index
  void addProduct(int index) {
    final list = List<String>.from(state.productDetails)..insert(index + 1, '');
    emit(state.copyWith(productDetails: list, isDirty: true));
  }

  /// Обновляет товар по индексу
  void updateProduct(int index, String value) {
    final list = List<String>.from(state.productDetails);
    list[index] = value;
    emit(state.copyWith(productDetails: list, isDirty: true));
  }

  /// Выбор секции/региона: диалог выбора города
  Future<void> selectCity(BuildContext context) async {
    final loc = AppLocalizations.of(context);
    final Map<String, String> cities = {
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

    final String? selected = await showDialog<String>(
      context: context,
      builder:
          (_) => SimpleDialog(
            title: Text(loc.chooseCity),
            children:
                cities.keys.map((city) {
                  return SimpleDialogOption(
                    onPressed: () => Navigator.pop(context, city),
                    child: Text(city),
                  );
                }).toList(),
          ),
    );

    if (selected != null) {
      final code = cities[selected]!;
      final newOrderCode =
          state.orderCode.length >= 6
              ? state.orderCode.substring(0, 6) + code
              : code;
      emit(
        state.copyWith(
          cityCode: code,
          orderCode: newOrderCode,
          address: selected,
          isDirty: true,
        ),
      );
    }
  }

  /// Диалог выбора района
  Future<void> selectDistrict(BuildContext context) async {
    final districts = await _service.fetchDistricts(state.address);
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
      emit(
        state.copyWith(address: '${state.address}, $selected', isDirty: true),
      );
    }
  }

  /// Диалог выбора даты рождения
  Future<void> selectBirthDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      emit(
        state.copyWith(
          birthDate: DateFormat('dd.MM.yyyy').format(picked),
          isDirty: true,
        ),
      );
    }
  }

  /// Экспорт/печать PDF
  Future<void> printInvoice(BuildContext context) async {
    await exportInvoicePdfByTemplate(
      context: context,
      senderName: state.senderName,
      senderTel: state.senderTel,
      receiverName: state.receiverName,
      receiverTel: state.receiverTel,
      cityAddress: state.address,
      tariff: 'От двери до двери',
      payment: double.tryParse(state.totalValue) ?? 0,
      weight: double.tryParse(state.brutto) ?? 0,
      invoiceNumber: state.orderCode,
      barcodeData: '1082260103',
      zoneText: 'ZONE 2',
      pvzText: 'ПВЗ [SPB33] На Звездной',
    );
  }

  /// Проверка перед выходом: можно ли покидать экран
  Future<bool> canLeave() async {
    return !state.isDirty;
  }

  bool _validateNumber(String v) => RegExp(r'^[\d\.,]+$').hasMatch(v);
}
