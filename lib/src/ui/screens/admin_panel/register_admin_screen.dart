import 'package:aps/src/data/auth_api.dart';
import 'package:aps/src/ui/screens/admin_panel/admin_screen.dart';
import 'package:flutter/material.dart';


class RegisterAdminScreen extends StatefulWidget {
  const RegisterAdminScreen({super.key});

  @override
  State<RegisterAdminScreen> createState() => _RegisterAdminScreenState();
}

class _RegisterAdminScreenState extends State<RegisterAdminScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool isLoading = false;

  final ApiService apiService = ApiService(); // ✅ Создаём экземпляр

  Future<void> _register() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Пароли не совпадают")),
      );
      return;
    }

    setState(() => isLoading = true);

    final response = await apiService.registerAdmin( // ✅ Вызываем метод через экземпляр
      nameController.text,
      phoneController.text,
      passwordController.text,
      confirmPasswordController.text,
    );

    setState(() => isLoading = false);

    if (response != null) {
      if (response.data?["status"] == "ok") {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AdminScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.data?["message"] ?? "Ошибка регистрации!")),
        );
      }
    }else{
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ошибка регистрации!")),
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
              const Text("Регистрация Админа", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(controller: nameController, decoration: const InputDecoration(labelText: "Имя")),
              const SizedBox(height: 10),
              TextField(controller: phoneController, decoration: const InputDecoration(labelText: "Телефон")),
              const SizedBox(height: 10),
              TextField(controller: passwordController, decoration: const InputDecoration(labelText: "Пароль"), obscureText: true),
              const SizedBox(height: 10),
              TextField(controller: confirmPasswordController, decoration: const InputDecoration(labelText: "Подтвердите пароль"), obscureText: true),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : _register,
                child: isLoading ? const CircularProgressIndicator() : const Text("Зарегистрироваться"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
