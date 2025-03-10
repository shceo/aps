import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:aps/l10n/app_localizations.dart';
import 'package:aps/main.dart';
import 'package:aps/src/ui/components/auth_anin.dart';
import 'package:aps/src/ui/components/text_u.dart';
import 'package:aps/src/ui/constants/back_images.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int selectedIndex = 0;
  bool showOption = false;
  int _selectedRole = 0;
  bool _obscurePassword = true;

  final List<Locale> _supportedLocales = const [
    Locale('ru'),
    Locale('en'),
    Locale('uz'),
    Locale('zh'),
    Locale('tr'),
  ];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      floatingActionButton: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        height: 49,
        width: double.infinity,
        child: Row(
          children: [
            Expanded(
              child:
                  showOption
                      ? ShowUpAnimation(
                        delay: 100,
                        child: ListView.builder(
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
                        ),
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
      ),
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
                    // Переключатель языка (изменяет локаль во всём приложении)
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

                    // Переключатель "Заказчик / Получатель"
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          _roleButton(loc.customer, 0),
                          _roleButton(loc.recipient, 1),
                        ],
                      ),
                    ),

                    const Spacer(),
                    Center(
                      child: TextUtil(text: loc.login, weight: true, size: 30),
                    ),
                    const Spacer(),

                    // Поле ввода (Email или Телефон)
                    TextUtil(text: _selectedRole == 0 ? loc.email : loc.phone),
                    _buildTextField(
                      icon: _selectedRole == 0 ? Icons.mail : Icons.phone,
                      hintText:
                          _selectedRole == 0 ? loc.email_hint : loc.phone_hint,
                      obscureText: false,
                    ),

                    const Spacer(),

                    // Поле ввода пароля
                    TextUtil(text: loc.password),
                    _buildTextField(
                      icon: Icons.lock,
                      hintText: loc.password_hint,
                      obscureText: _obscurePassword,
                      isPassword: true,
                    ),

                    const Spacer(),
                    Container(
                      height: 40,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      alignment: Alignment.center,
                      child: TextUtil(text: loc.log_in, color: Colors.black),
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

  Widget _roleButton(String text, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedRole = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            color:
                _selectedRole == index ? Colors.blueAccent : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: _selectedRole == index ? Colors.white : Colors.grey[300],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
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
}
