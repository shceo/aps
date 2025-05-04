import 'package:aps/l10n/app_localizations.dart';
import 'package:aps/src/ui/constants/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderCodeVerification extends StatefulWidget {
  final Function(bool) onVerified;

  const OrderCodeVerification({super.key, required this.onVerified});

  @override
  State<OrderCodeVerification> createState() => _OrderCodeVerificationState();
}

class _OrderCodeVerificationState extends State<OrderCodeVerification> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  Future<void> _verifyCode() async {
    setState(() {
      _isLoading = true;
    });
    final enteredCode = _controller.text.trim();
    // Поиск документа с данным order_code
    QuerySnapshot snapshot =
        await _firestore
            .collection('invoices')
            .where('order_code', isEqualTo: enteredCode)
            .get();

    setState(() {
      _isLoading = false;
    });
    if (snapshot.docs.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isOrderCodeVerified', true);
      widget.onVerified(true);
    } else {
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
                    AppLocalizations.of(context).invalid_order_code,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context).invalid_order_code_des,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, color: Colors.black),
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
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 130,
                        vertical: 13,
                      ),
                      child: Text(
                        "OK",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
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

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
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
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ApsColors.bwhite,
                  ),
                  onPressed: _verifyCode,
                  child: Text(loc.confirm_order_code),
                ),
          ],
        ),
      ),
    );
  }
}
