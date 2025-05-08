import 'dart:ui';
import 'package:aps/main.dart' show AppRoutePath, AppRouterDelegate, MyApp;
import 'package:aps/src/core/routes.dart';
// import 'package:aps/src/ui/routes/app_navigator.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:aps/l10n/app_localizations.dart';
import 'package:aps/src/core/theme/text_u.dart';
import 'package:aps/src/core/constants/back_images.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  final int selectedIndex;
  // Callback, вызываемый при успешном логине, чтобы изменить состояние навигации.
  final VoidCallback onLoginSuccess;
  // Callback, вызываемый при переходе на RegisterScreen.
  final VoidCallback onRegisterTapped;

  const LoginScreen({
    super.key,
    required this.selectedIndex,
    required this.onLoginSuccess,
    required this.onRegisterTapped,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late int selectedIndex;
  bool showOption = false;
  bool _obscurePassword = true;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  final List<Locale> _supportedLocales = const [
    Locale('ru'),
    Locale('en'),
    Locale('uz'),
    Locale('zh'),
    Locale('tr'),
  ];

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.selectedIndex;
  }

  Future<void> _login() async {
    if (_isLoading) return; // ✅ Фикс двойного запроса

    setState(() {
      _isLoading = true;
    });

    print("🔵 Начало процесса входа...");
    print("📞 Введённый телефон: ${_phoneController.text}");
    print("🔑 Введённый пароль: ${_passwordController.text}");

    try {
      Dio dio = Dio();
      Response response = await dio.post(
        "https://khaledo.pythonanywhere.com/login/",
        data: {
          "phone": _phoneController.text,
          "password": _passwordController.text,
        },
      );

      print("🟢 Ответ сервера: ${response.data}");

      if (response.data["status"] == "ok") {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool("isLoggedIn", true);
        await prefs.setString("userPhone", _phoneController.text);

        print("✅ Логин успешен, переходим в MainScreen...");

        // ✅ Обновляем состояние в `AppRouterDelegate`
        final routerDelegate =
            Router.of(context).routerDelegate as AppRouterDelegate;
        routerDelegate.isUserLoggedIn = true; // ✅ Фикс
        routerDelegate.setNewRoutePath(AppRoutePath.home());
      } else {
        print("❌ Ошибка входа: ${response.data["message"]}");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(response.data["message"])));
      }
    } catch (e) {
      print("🚨 Ошибка запроса: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Ошибка входа")));
    }

    setState(() {
      _isLoading = false;
    });

    print("🔴 Завершение процесса входа.");
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      floatingActionButton: _buildThemeSwitcher(),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(bgList[selectedIndex]),
            fit: BoxFit.fill,
          ),
        ),
        alignment: Alignment.center,
        child: Container(
          height: 450,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(15),
            color: Colors.black.withOpacity(0.1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaY: 5, sigmaX: 5),
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: DropdownButton<Locale>(
                        value: Localizations.localeOf(context),
                        dropdownColor: Colors.black,
                        icon: const Icon(Icons.language, color: Colors.white),
                        underline: const SizedBox(),
                        items:
                            _supportedLocales.map((locale) {
                              return DropdownMenuItem(
                                value: locale,
                                child: Text(
                                  locale.languageCode.toUpperCase(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              );
                            }).toList(),
                        onChanged: (Locale? newLocale) {
                          if (newLocale != null) {
                            // Вызываем статический метод для смены локали.
                            MyApp.setLocale(
                              context,
                              newLocale,
                            ); //MyApp is from main.dart
                          }
                        },
                      ),
                    ),
                    const Spacer(),
                    Center(
                      child: TextUtil(text: loc.login, weight: true, size: 30),
                    ),
                    const Spacer(),
                    TextUtil(text: loc.phone),
                    _buildTextField(
                      controller: _phoneController,
                      icon: Icons.phone,
                      hintText: loc.phone_hint,
                      obscureText: false,
                    ),
                    const Spacer(),
                    TextUtil(text: loc.password),
                    _buildTextField(
                      controller: _passwordController,
                      icon: Icons.lock,
                      hintText: loc.password_hint,
                      obscureText: _obscurePassword,
                      isPassword: true,
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _isLoading ? null : _login,
                      child: Container(
                        height: 40,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        alignment: Alignment.center,
                        child:
                            _isLoading
                                ? const CircularProgressIndicator()
                                : TextUtil(
                                  text: loc.log_in,
                                  color: Colors.black,
                                ),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        print(
                          "🔄 Переход на RegisterScreen...",
                        ); // Лог в терминале
                        final routerDelegate =
                            Router.of(context).routerDelegate
                                as AppRouterDelegate;
                        routerDelegate.setNewRoutePath(AppRoutePath.register());
                      },
                      child: Center(
                        child: TextUtil(
                          text: loc.register,
                          size: 12,
                          weight: true,
                        ),
                      ),
                    ),

                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hintText,
    required bool obscureText,
    bool isPassword = false,
  }) {
    return Container(
      height: 45,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white)),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          suffixIcon:
              isPassword
                  ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  )
                  : Icon(icon, color: Colors.white),
          fillColor: Colors.white,
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildThemeSwitcher() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      height: 49,
      width: double.infinity,
      child: Row(
        children: [
          Expanded(
            child:
                showOption
                    ? ListView.builder(
                      shrinkWrap: true,
                      itemCount: bgList.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedIndex = index;
                            });
                          },
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor:
                                selectedIndex == index
                                    ? Colors.white
                                    : Colors.transparent,
                            child: Padding(
                              padding: const EdgeInsets.all(1),
                              child: CircleAvatar(
                                radius: 30,
                                backgroundImage: AssetImage(bgList[index]),
                              ),
                            ),
                          ),
                        );
                      },
                    )
                    : const SizedBox(),
          ),
          const SizedBox(width: 20),
          GestureDetector(
            onTap: () {
              setState(() {
                showOption = !showOption;
              });
            },
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(1),
                child: CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage(bgList[selectedIndex]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
