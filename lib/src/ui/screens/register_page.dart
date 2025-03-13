import 'dart:ui';
import 'package:aps/src/ui/screens/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:aps/l10n/app_localizations.dart';
import 'package:aps/src/ui/components/text_u.dart';
import 'package:aps/src/ui/constants/back_images.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aps/main.dart';
import 'package:aps/src/ui/screens/after_screen/main_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
    required this.selectedIndex,
    required this.onRegisterSuccess,
    required this.onSwitchToLogin,
  });

  final int selectedIndex;
  final VoidCallback onRegisterSuccess;
  final VoidCallback onSwitchToLogin;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late int selectedIndex;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;
  bool showOption = false;

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

  Future<void> _register() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Пароли не совпадают")));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      Dio dio = Dio();
      Response response = await dio.post(
        "https://khaledo.pythonanywhere.com/reg/",
        data: {
          "first_name": _nameController.text,
          "phone": _phoneController.text,
          "password": _passwordController.text,
          "password_confirm": _confirmPasswordController.text,
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.data["message"] ?? "Регистрация успешна"),
        ),
      );

      if (response.statusCode == 201) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool("isLoggedIn", true);
        await prefs.setBool("isUserLoggedIn", true);
        await prefs.setString("userPhone", _phoneController.text);

        // ✅ Правильный вызов функции
        widget.onRegisterSuccess();
      }
    } catch (e) {
      print("Ошибка регистрации: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Ошибка регистрации")));
    }

    setState(() {
      _isLoading = false;
    });
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
          height: 580,
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
                            MyApp.setLocale(context, newLocale);
                          }
                        },
                      ),
                    ),
                    const Spacer(),
                    Center(
                      child: TextUtil(
                        text: loc.register,
                        weight: true,
                        size: 30,
                      ),
                    ),
                    // const Spacer(),
                    // Поля ввода
                    _buildTextField(
                      loc.name,
                      _nameController,
                      Icons.person,
                      loc.name_hint,
                      false,
                    ),
                    _buildTextField(
                      loc.phone,
                      _phoneController,
                      Icons.phone,
                      loc.phone_hint,
                      false,
                    ),
                    _buildTextField(
                      loc.password,
                      _passwordController,
                      Icons.lock,
                      loc.password_hint,
                      _obscurePassword,
                      isPassword: true,
                    ),
                    _buildTextField(
                      loc.confirm_password,
                      _confirmPasswordController,
                      Icons.lock,
                      loc.confirm_password_hint,
                      _obscureConfirmPassword,
                      isPassword: true,
                      isConfirmPassword: true,
                    ),
                    const Spacer(),

                    GestureDetector(
                      onTap: _isLoading ? null : _register,
                      child: Container(
                        height: 35,
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
                                  text: loc.register,
                                  color: Colors.black,
                                ),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: widget.onSwitchToLogin,
                      child: Center(
                        child: TextUtil(
                          text: loc.already_have_account,
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

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon,
    String hintText,
    bool obscureText, {
    bool isPassword = false,
    bool isConfirmPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextUtil(text: label),
        Container(
          height: 50,
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
                  isPassword || isConfirmPassword
                      ? IconButton(
                        icon: Icon(
                          obscureText ? Icons.visibility_off : Icons.visibility,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            if (isConfirmPassword) {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            } else {
                              _obscurePassword = !_obscurePassword;
                            }
                          });
                        },
                      )
                      : Icon(icon, color: Colors.white),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
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
