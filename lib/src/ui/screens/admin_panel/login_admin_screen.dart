import 'package:aps/src/data/auth_api.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminAuthScreen extends StatefulWidget {
  final Future<void> Function() onAdminAuthSuccess;
  const AdminAuthScreen({Key? key, required this.onAdminAuthSuccess})
      : super(key: key);

  @override
  State<AdminAuthScreen> createState() => _AdminAuthScreenState();
}

class _AdminAuthScreenState extends State<AdminAuthScreen> {
  // Флаг, определяющий, в каком режиме экран (логин или регистрация)
  bool isLoginMode = true;
  
  // Общие поля
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  // Поля, используемые только в режиме регистрации
  final TextEditingController nameController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isLoading = false;
  final ApiService apiService = ApiService();

 Future<void> _submit() async {
  // Если режим регистрации, проверяем, совпадают ли пароли
  if (!isLoginMode &&
      passwordController.text != confirmPasswordController.text) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Пароли не совпадают")),
    );
    return;
  }
  
  setState(() => isLoading = true);
  dynamic response;
  if (isLoginMode) {
    // Режим логина
    response = await apiService.loginAdmin(
      phoneController.text,
      passwordController.text,
    );
  } else {
    // Режим регистрации
    response = await apiService.registerAdmin(
      nameController.text,
      phoneController.text,
      passwordController.text,
      confirmPasswordController.text,
    );
  }
  setState(() => isLoading = false);

  if (response != null &&
      ((isLoginMode && response.statusCode == 200) ||
       (!isLoginMode && response.data?["status"] == "ok"))) {
    // // Сохраняем состояние логина администратора в SharedPreferences
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setBool("adminLoggedIn", true);
    // // Можно также сохранить время логина, чтобы задать срок действия (например, 1 час)
    // await prefs.setInt("adminLoginTime", DateTime.now().millisecondsSinceEpoch);
    
    // После успешного логина/регистрации вызываем callback
    await widget.onAdminAuthSuccess();
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(response?.data?["message"] ?? "Ошибка!"),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Можно добавить AppBar, если нужно
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(isLoginMode ? "Админ Логин" : "Регистрация админа"),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isLoginMode)
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Имя"),
                ),
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
              const SizedBox(height: 10),
              if (!isLoginMode)
                TextField(
                  controller: confirmPasswordController,
                  decoration: const InputDecoration(labelText: "Подтвердите пароль"),
                  obscureText: true,
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : _submit,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : Text(isLoginMode ? "Войти" : "Зарегистрироваться"),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    // Переключаем режим между логином и регистрацией
                    isLoginMode = !isLoginMode;
                  });
                },
                child: Text(isLoginMode
                    ? "Нет аккаунта? Зарегистрируйтесь"
                    : "Уже есть аккаунт? Войти"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
