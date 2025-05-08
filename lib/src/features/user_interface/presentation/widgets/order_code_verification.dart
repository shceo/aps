
import 'package:aps/l10n/app_localizations.dart';

import 'package:aps/src/core/constants/app_colors.dart';
import 'package:aps/src/features/user_interface/presentation/cubit/order_code_cubit.dart';
import 'package:aps/src/features/user_interface/presentation/cubit/order_code_cubit_state.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

  
class OrderCodeVerification extends StatelessWidget {
  final Function(bool) onVerified;
  final TextEditingController _controller = TextEditingController();

  OrderCodeVerification({Key? key, required this.onVerified})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OrderCodeCubit(),
      child: BlocConsumer<OrderCodeCubit, OrderCodeState>(
        listener: (context, state) {
          if (state is OrderCodeSuccess) {
            onVerified(true);
          } else if (state is OrderCodeFailure) {
            _showErrorDialog(context);
          }
        },
        builder: (context, state) {
          final loc = AppLocalizations.of(context);
          final isLoading = state is OrderCodeLoading;
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    loc.enter_order_code,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: loc.order_code_hint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ApsColors.bwhite,
                          ),
                          onPressed: () => context
                              .read<OrderCodeCubit>()
                              .verifyCode(_controller.text.trim()),
                          child: Text(loc.confirm_order_code),
                        ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showErrorDialog(BuildContext context) {
    final loc = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: const Color(0xFFFFFFFF),
          content: Container(
            width: 400,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/icons/error.png'),
                const SizedBox(height: 18),
                Text(
                  loc.invalid_order_code,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
                ),
                Text(
                  loc.invalid_order_code_des,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
          actions: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: 28),
                decoration: BoxDecoration(
                  color: ApsColors.photoBlue,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 130, vertical: 13),
                    child: Text("OK", style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ),
            ),
          ],
          actionsPadding: EdgeInsets.zero,
        );
      },
    );
  }
}
