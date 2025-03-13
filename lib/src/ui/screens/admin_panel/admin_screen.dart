import 'package:flutter/material.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Добро пожаловать в Админ Панель!", style: TextStyle(fontSize: 24))),
    );
  }
}
