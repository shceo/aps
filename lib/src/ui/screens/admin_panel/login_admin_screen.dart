import 'package:aps/src/data/auth_api.dart';
import 'package:aps/src/ui/screens/admin_panel/register_admin_screen.dart';
import 'package:aps/src/ui/screens/admin_panel/admin_screen.dart';
import 'package:flutter/material.dart';

class LoginAdminScreen extends StatefulWidget {
  const LoginAdminScreen({super.key, required Future<Null> Function() onAdminLoginSuccess});

  @override
  State<LoginAdminScreen> createState() => _LoginAdminScreenState();
}

class _LoginAdminScreenState extends State<LoginAdminScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  final ApiService apiService = ApiService();

  Future<void> _login() async {
    setState(() => isLoading = true);

    final response = await apiService.loginAdmin(
      phoneController.text,
      passwordController.text,
    );

    setState(() => isLoading = false);

    if (response != null && response.statusCode == 200) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AdminScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response!.data?["message"] ?? "Ошибка входа!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Админ Логин",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: "Телефон"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: "Пароль"),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : _login,
                child: isLoading ? const CircularProgressIndicator() : const Text("Войти"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RegisterAdminScreen()),
                ),
                child: const Text("Регистрация"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
