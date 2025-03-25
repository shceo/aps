import 'package:flutter/material.dart';

class NoFoundScreen extends StatelessWidget {
  const NoFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("404 Not Found"),
      ),
    );
  }
}
