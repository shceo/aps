// // lib/src/ui/screens/admin_panel/components/invoice_form_view.dart

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:aps/l10n/app_localizations.dart';

// /// Чистый, stateless-вид для формы счета без бизнес-логики и без сторонних виджетов.
// /// Всё передаётся через контроллеры, флаги и колбэки.
// class InvoiceFormView extends StatelessWidget {
//   final int invoiceId;
//   final bool isLoading;
//   final bool hasSelectedSection;
//   final String selectedSection;

//   final TextEditingController senderNameController;
//   final TextEditingController senderTelController;
//   final TextEditingController receiverNameController;
//   final TextEditingController receiverTelController;
//   final TextEditingController passportController;
//   final TextEditingController birthDateController;
//   final TextEditingController addressController;
//   final TextEditingController bruttoController;
//   final TextEditingController totalValueController;

//   final List<TextEditingController> productControllers;
//   final List<FocusNode> productFocusNodes;

//   final bool citySelected;
//   final bool districtSelected;
//   final String? totalValueError;
//   final bool isOverLimit;

//   final ValueChanged<String> onFieldChanged;
//   final void Function(int index, String value) onProductChanged;
//   final void Function(int index) onAddProduct;
//   final VoidCallback onSelectCity;
//   final VoidCallback onSelectDistrict;
//   final VoidCallback onBirthDateTap;
//   final VoidCallback onSave;
//   final VoidCallback onPrint;
//   final Future<bool> Function() onWillPop;

//   const InvoiceFormView({
//     Key? key,
//     required this.invoiceId,
//     required this.isLoading,
//     required this.hasSelectedSection,
//     required this.selectedSection,
//     required this.senderNameController,
//     required this.senderTelController,
//     required this.receiverNameController,
//     required this.receiverTelController,
//     required this.passportController,
//     required this.birthDateController,
//     required this.addressController,
//     required this.bruttoController,
//     required this.totalValueController,
//     required this.productControllers,
//     required this.productFocusNodes,
//     required this.citySelected,
//     required this.districtSelected,
//     this.totalValueError,
//     required this.isOverLimit,
//     required this.onFieldChanged,
//     required this.onProductChanged,
//     required this.onAddProduct,
//     required this.onSelectCity,
//     required this.onSelectDistrict,
//     required this.onBirthDateTap,
//     required this.onSave,
//     required this.onPrint,
//     required this.onWillPop,
//   }) : super(key: key);

//   TableRow _buildTableRow(
//     BuildContext ctx,
//     String label,
//     TextEditingController controller, {
//     TextInputType keyboardType = TextInputType.text,
//     IconData? icon,
//     String? errorText,
//   }) {
//     return TableRow(
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8),
//           child: Text(
//             label,
//             style: const TextStyle(fontWeight: FontWeight.bold),
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.symmetric(vertical: 4),
//           child: TextField(
//             controller: controller,
//             keyboardType: keyboardType,
//             inputFormatters:
//                 keyboardType == TextInputType.number
//                     ? [FilteringTextInputFormatter.digitsOnly]
//                     : null,
//             decoration: InputDecoration(
//               hintText: label,
//               prefixIcon: icon != null ? Icon(icon) : null,
//               filled: true,
//               fillColor: Colors.grey[100],
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//                 borderSide: BorderSide.none,
//               ),
//               errorText: errorText,
//             ),
//             onChanged: onFieldChanged,
//           ),
//         ),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final loc = AppLocalizations.of(context);

//     if (isLoading) {
//       return Scaffold(
//         appBar: AppBar(title: Text('${loc.invoice} № $invoiceId')),
//         body: const Center(child: CircularProgressIndicator()),
//       );
//     }

//     return WillPopScope(
//       onWillPop: onWillPop,
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text(
//             '${loc.invoice} № $invoiceId' +
//                 (hasSelectedSection
//                     ? ' — ${loc.selectedSection} $selectedSection'
//                     : ''),
//           ),
//         ),
//         body: SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             children: [
//               Card(
//                 elevation: 4,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Table(
//                     columnWidths: const {
//                       0: FlexColumnWidth(1),
//                       1: FlexColumnWidth(2),
//                     },
//                     children: [
//                       _buildTableRow(
//                         context,
//                         loc.senderName,
//                         senderNameController,
//                         icon: Icons.person,
//                       ),
//                       _buildTableRow(
//                         context,
//                         loc.senderTel,
//                         senderTelController,
//                         keyboardType: TextInputType.phone,
//                         icon: Icons.phone,
//                       ),
//                       _buildTableRow(
//                         context,
//                         loc.receiverName,
//                         receiverNameController,
//                         icon: Icons.person_outline,
//                       ),
//                       _buildTableRow(
//                         context,
//                         loc.receiverTel,
//                         receiverTelController,
//                         keyboardType: TextInputType.phone,
//                         icon: Icons.phone_android,
//                       ),

//                       // Паспорт
//                       TableRow(
//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 8),
//                             child: Text(
//                               loc.passportId,
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 4),
//                             child: TextField(
//                               controller: passportController,
//                               keyboardType: TextInputType.number,
//                               inputFormatters: [
//                                 FilteringTextInputFormatter.allow(
//                                   RegExp(r'[\d\.,]'),
//                                 ),
//                               ],
//                               decoration: InputDecoration(
//                                 hintText: loc.passportId,
//                                 prefixIcon: const Icon(Icons.badge),
//                                 filled: true,
//                                 fillColor: Colors.grey[100],
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(8),
//                                   borderSide: BorderSide.none,
//                                 ),
//                               ),
//                               onChanged: onFieldChanged,
//                             ),
//                           ),
//                         ],
//                       ),

//                       // Дата рождения
//                       TableRow(
//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 8),
//                             child: Text(
//                               loc.birthDate,
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 4),
//                             child: TextField(
//                               controller: birthDateController,
//                               readOnly: true,
//                               decoration: InputDecoration(
//                                 hintText: loc.selectDate,
//                                 prefixIcon: const Icon(Icons.calendar_today),
//                                 filled: true,
//                                 fillColor: Colors.grey[100],
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(8),
//                                   borderSide: BorderSide.none,
//                                 ),
//                               ),
//                               onTap: onBirthDateTap,
//                             ),
//                           ),
//                         ],
//                       ),

//                       // Адрес
//                       TableRow(
//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 8),
//                             child: Text(
//                               loc.addressFull,
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 4),
//                             child: TextField(
//                               controller: addressController,
//                               readOnly: false,
//                               decoration: InputDecoration(
//                                 hintText: loc.addressHint,
//                                 prefixIcon: const Icon(Icons.location_on),
//                                 suffixIcon: Row(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     IconButton(
//                                       icon: const Icon(Icons.location_city),
//                                       color: citySelected ? Colors.grey : null,
//                                       onPressed: onSelectCity,
//                                     ),
//                                     IconButton(
//                                       icon: const Icon(Icons.place),
//                                       color:
//                                           districtSelected ? Colors.grey : null,
//                                       onPressed:
//                                           citySelected
//                                               ? onSelectDistrict
//                                               : null,
//                                     ),
//                                   ],
//                                 ),
//                                 filled: true,
//                                 fillColor: Colors.grey[100],
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(8),
//                                   borderSide: BorderSide.none,
//                                 ),
//                               ),
//                               onChanged: onFieldChanged,
//                             ),
//                           ),
//                         ],
//                       ),

//                       // Товары
//                       TableRow(
//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 8),
//                             child: Text(
//                               loc.productDetails,
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 4),
//                             child: Column(
//                               children: List.generate(
//                                 productControllers.length,
//                                 (i) {
//                                   return Padding(
//                                     padding: const EdgeInsets.symmetric(
//                                       vertical: 4,
//                                     ),
//                                     child: TextField(
//                                       controller: productControllers[i],
//                                       focusNode: productFocusNodes[i],
//                                       decoration: InputDecoration(
//                                         hintText:
//                                             '${i + 1}. ${loc.productDetails}',
//                                         suffixIcon: IconButton(
//                                           icon: const Icon(
//                                             Icons.add,
//                                             color: Colors.green,
//                                           ),
//                                           onPressed: () => onAddProduct(i),
//                                         ),
//                                         filled: true,
//                                         fillColor: Colors.grey[100],
//                                         border: OutlineInputBorder(
//                                           borderRadius: BorderRadius.circular(
//                                             8,
//                                           ),
//                                           borderSide: BorderSide.none,
//                                         ),
//                                       ),
//                                       onChanged:
//                                           (value) => onProductChanged(i, value),
//                                     ),
//                                   );
//                                 },
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),

//                       _buildTableRow(
//                         context,
//                         loc.bruttoWeight,
//                         bruttoController,
//                         icon: Icons.line_weight,
//                       ),
//                       _buildTableRow(
//                         context,
//                         loc.totalValue,
//                         totalValueController,
//                         keyboardType: TextInputType.number,
//                         icon: Icons.attach_money,
//                         errorText: totalValueError,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 20),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   ElevatedButton(
//                     onPressed: isOverLimit ? null : onSave,
//                     child: Text(loc.save),
//                   ),
//                   ElevatedButton(onPressed: onPrint, child: Text(loc.print)),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
