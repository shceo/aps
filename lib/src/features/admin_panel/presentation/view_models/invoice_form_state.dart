// lib/src/features/admin_panel/presentation/view_models/invoice_form_state.dart

part of 'invoice_form_cubit.dart';

/// Статусы формы
enum FormStatus {
  initial,
  loading,
  loaded,
  submitting,
  success,
  failure,
  validationError,
}

/// Поля формы для динамического обновления
enum FormField {
  orderCode,
  senderName,
  senderTel,
  receiverName,
  receiverTel,
  passport,
  birthDate,
  address,
  brutto,
  totalValue,
  totalDeliverySum,
}

class InvoiceFormState extends Equatable {
  final FormStatus status;
  final String orderCode;
  final String senderName;
  final String senderTel;
  final String receiverName;
  final String receiverTel;
  final String passport;
  final String birthDate;
  final String address;
  final String brutto;
  final String totalValue;
  final String totalDeliverySum;
  final String? totalValueError;
  final String? errorMessage;
  final List<String> productDetails;
  final String selectedSection;
  final String cityCode;

  /// **Новые поля:**
  /// true, если пользователь что-то поменял и ещё не сохранил
  final bool isDirty;

  /// true, если сумма превысила месячный лимит (если хотите)
  final bool isOverLimit;

  const InvoiceFormState({
    required this.status,
    required this.orderCode,
    required this.senderName,
    required this.senderTel,
    required this.receiverName,
    required this.receiverTel,
    required this.passport,
    required this.birthDate,
    required this.address,
    required this.brutto,
    required this.totalValue,
    required this.totalDeliverySum,
    this.totalValueError,
    this.errorMessage,
    required this.productDetails,
    required this.selectedSection,
    required this.cityCode,
    this.isDirty = false,
    this.isOverLimit = false,
  });

  factory InvoiceFormState.initial() => const InvoiceFormState(
    status: FormStatus.initial,
    orderCode: '',
    senderName: '',
    senderTel: '',
    receiverName: '',
    receiverTel: '',
    passport: '',
    birthDate: '',
    address: '',
    brutto: '',
    totalValue: '',
    totalDeliverySum: '',
    productDetails: [''],
    selectedSection: '',
    cityCode: '',
    isDirty: false,
    isOverLimit: false,
  );

  InvoiceFormState copyWith({
    FormStatus? status,
    String? orderCode,
    String? senderName,
    String? senderTel,
    String? receiverName,
    String? receiverTel,
    String? passport,
    String? birthDate,
    String? address,
    String? brutto,
    String? totalValue,
    String? totalDeliverySum,
    String? totalValueError,
    String? errorMessage,
    List<String>? productDetails,
    String? selectedSection,
    String? cityCode,
    bool? isDirty,
    bool? isOverLimit,
  }) {
    return InvoiceFormState(
      status: status ?? this.status,
      orderCode: orderCode ?? this.orderCode,
      senderName: senderName ?? this.senderName,
      senderTel: senderTel ?? this.senderTel,
      receiverName: receiverName ?? this.receiverName,
      receiverTel: receiverTel ?? this.receiverTel,
      passport: passport ?? this.passport,
      birthDate: birthDate ?? this.birthDate,
      address: address ?? this.address,
      brutto: brutto ?? this.brutto,
      totalValue: totalValue ?? this.totalValue,
      totalDeliverySum: totalDeliverySum ?? this.totalDeliverySum,
      totalValueError: totalValueError ?? this.totalValueError,
      errorMessage: errorMessage ?? this.errorMessage,
      productDetails: productDetails ?? this.productDetails,
      selectedSection: selectedSection ?? this.selectedSection,
      cityCode: cityCode ?? this.cityCode,
      isDirty: isDirty ?? this.isDirty,
      isOverLimit: isOverLimit ?? this.isOverLimit,
    );
  }

  /// Можно сабмитить, если форма загружена, нет ошибок и не превышен лимит
  bool get canSubmit =>
      status == FormStatus.loaded &&
      orderCode.isNotEmpty &&
      senderName.isNotEmpty &&
      senderTel.isNotEmpty &&
      receiverName.isNotEmpty &&
      receiverTel.isNotEmpty &&
      passport.isNotEmpty &&
      birthDate.isNotEmpty &&
      address.isNotEmpty &&
      brutto.isNotEmpty &&
      totalValue.isNotEmpty &&
      totalDeliverySum.isNotEmpty &&
      totalValueError == null &&
      !isOverLimit;

  @override
  List<Object?> get props => [
    status,
    orderCode,
    senderName,
    senderTel,
    receiverName,
    receiverTel,
    passport,
    birthDate,
    address,
    brutto,
    totalValue,
    totalDeliverySum,
    totalValueError,
    errorMessage,
    productDetails,
    selectedSection,
    cityCode,
    isDirty,
    isOverLimit,
  ];
}
