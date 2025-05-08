
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'order_code_cubit_state.dart';

class OrderCodeCubit extends Cubit<OrderCodeState> {
  final FirebaseFirestore _firestore;

  OrderCodeCubit({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        super(OrderCodeInitial());

  Future<void> verifyCode(String enteredCode) async {
    emit(OrderCodeLoading());
    try {
      final snapshot = await _firestore
          .collection('invoices')
          .where('order_code', isEqualTo: enteredCode)
          .get();
      if (snapshot.docs.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isOrderCodeVerified', true);
        emit(OrderCodeSuccess());
      } else {
        emit(const OrderCodeFailure('invalid_order_code'));
      }
    } catch (e) {
      emit(OrderCodeFailure(e.toString()));
    }
  }
}
