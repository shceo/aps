// // lib/src/features/admin_panel/presentation/screens/invoice_form_screen.dart

// import 'package:aps/src/features/admin_panel/presentation/widgets/invoice_form_view.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:aps/src/features/admin_panel/presentation/view_models/invoice_form_cubit.dart';

// class InvoiceFormScreen extends StatelessWidget {
//   final int invoiceId;
//   const InvoiceFormScreen({Key? key, required this.invoiceId})
//     : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider<InvoiceFormCubit>(
//       create: (_) => InvoiceFormCubit()..loadInvoice(invoiceId),
//       child: BlocConsumer<InvoiceFormCubit, InvoiceFormState>(
//         listener: (context, state) {
//           if (state.status == FormStatus.success) {
//             Navigator.of(context).pop();
//           } else if (state.status == FormStatus.failure) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text(state.errorMessage ?? 'Error')),
//             );
//           }
//         },
//         builder: (context, state) {
//           final cubit = context.read<InvoiceFormCubit>();

//           return InvoiceFormView(
//             invoiceId: invoiceId,
//             isLoading: state.status == FormStatus.loading,
//             hasSelectedSection: state.selectedSection.isNotEmpty,
//             selectedSection: state.selectedSection,

//             senderNameController: TextEditingController(text: state.senderName),
//             senderTelController: TextEditingController(text: state.senderTel),
//             receiverNameController: TextEditingController(
//               text: state.receiverName,
//             ),
//             receiverTelController: TextEditingController(
//               text: state.receiverTel,
//             ),
//             passportController: TextEditingController(text: state.passport),
//             birthDateController: TextEditingController(text: state.birthDate),
//             addressController: TextEditingController(text: state.address),
//             bruttoController: TextEditingController(text: state.brutto),
//             totalValueController: TextEditingController(text: state.totalValue),

//             productControllers:
//                 state.productDetails
//                     .map((d) => TextEditingController(text: d))
//                     .toList(),
//             productFocusNodes: List.generate(
//               state.productDetails.length,
//               (_) => FocusNode(),
//             ),

//             citySelected: state.cityCode.isNotEmpty,
//             districtSelected: false,
//             totalValueError: state.totalValueError,
//             isOverLimit: false,

//             onFieldChanged: (field, value) => cubit.updateField(field, value),
//             onProductChanged:
//                 (index, value) => cubit.updateProduct(index, value),
//             onAddProduct: (index) => cubit.addProduct(index),

//             // Передаём context в Cubit, чтобы он мог показать диалог:
//             onSelectCity: () => cubit.selectCity(context),
//             onSelectDistrict: () => cubit.selectDistrict(context),
//             onBirthDateTap: () => cubit.selectBirthDate(context),

//             onSave: () => cubit.save(invoiceId),
//             onPrint: () => cubit.printInvoice(context),
//             onWillPop: () => cubit.canLeave(),
//           );
//         },
//       ),
//     );
//   }
// }
