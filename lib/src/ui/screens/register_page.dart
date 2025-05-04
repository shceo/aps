import 'dart:async';
import 'dart:ui';
import 'package:aps/src/data/auth_api.dart'; // Здесь находится ApiService с методом registerWithOtp
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:aps/l10n/app_localizations.dart';
import 'package:aps/src/ui/widgets/text_u.dart';
import 'package:aps/src/ui/constants/back_images.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aps/main.dart';

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
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool _isLoading = false;
  bool showOption = false;

  // Логика OTP
  bool _otpSent = false; // Флаг, что первичный запрос (с OTP = "") уже выполнен
  Duration _otpRemaining = const Duration(minutes: 15);
  Timer? _otpTimer;
  String _otpErrorMessage = '';

  final ApiService _apiService = ApiService();

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

  @override
  void dispose() {
    _otpTimer?.cancel();
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  /// Метод для отправки OTP запроса (через объединённый метод регистрации с пустым OTP)
  Future<void> _requestOtp() async {
    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Введите номер телефона")),
      );
      return;
    }

    // Если уже отправляли код и ограничение не истекло, не отправляем повторно
    if (_otpSent) {
      // Здесь можно добавить дополнительную проверку оставшегося времени, если нужно
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Код уже отправлен. Повторная отправка через 15 минут")),
      );
      return;
    }

    // Отправляем запрос регистрации с пустым OTP,
    // что инициирует отправку кода на указанный номер
    Response<Map<String, dynamic>>? response = await _apiService.registerWithOtp(
      _nameController.text,
      _phoneController.text,
      _passwordController.text,
      _confirmPasswordController.text,
      "",
    );

    if (response != null &&
        response.data != null &&
        response.data!["message"] == "Verification code sent successfully.") {
      setState(() {
        _otpSent = true;
      });
      _startOtpTimer();
      await _showOtpDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response?.data?["error"] ?? "Ошибка запроса OTP")),
      );
    }
  }

  /// Запуск таймера обратного отсчёта 15 минут для OTP
  void _startOtpTimer() {
    _otpTimer?.cancel();
    setState(() {
      _otpRemaining = const Duration(minutes: 15);
    });
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final diff = const Duration(minutes: 15) - Duration(seconds: timer.tick);
      if (diff.inSeconds <= 0) {
        timer.cancel();
        setState(() {
          _otpRemaining = Duration.zero;
        });
      } else {
        setState(() {
          _otpRemaining = diff;
        });
      }
    });
  }

  /// Диалоговое окно для ввода OTP.
  /// Возвращает true, если регистрация прошла успешно, иначе false.
  Future<bool> _showOtpDialog() async {
    _otpController.clear();
    _otpErrorMessage = '';

    bool registrationSuccess = false;
    await showDialog(
      context: context,
      barrierDismissible: false, // окно нельзя закрыть тапом вне его
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              backgroundColor: Colors.black.withOpacity(0.5),
              insetPadding: const EdgeInsets.all(20),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Отображение таймера
                    Text(
                      _otpRemaining.inSeconds > 0
                          ? "Действует: ${_otpRemaining.inMinutes.toString().padLeft(2, '0')}:${(_otpRemaining.inSeconds % 60).toString().padLeft(2, '0')}"
                          : "Код устарел, отправьте новый",
                      style: TextStyle(
                        color: _otpRemaining.inSeconds > 0 ? Colors.white : Colors.red,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Поле ввода кода
                    TextField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Введите код",
                        hintStyle: const TextStyle(color: Colors.grey),
                        errorText: _otpErrorMessage.isNotEmpty ? _otpErrorMessage : null,
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.8)),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Кнопка "Отправить" для финального запроса с OTP
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                      ),
                      onPressed: _otpRemaining.inSeconds > 0
                          ? () async {
                              // Вызываем регистрацию с введённым OTP
                              Response<Map<String, dynamic>>? response =
                                  await _apiService.registerWithOtp(
                                _nameController.text,
                                _phoneController.text,
                                _passwordController.text,
                                _confirmPasswordController.text,
                                _otpController.text,
                              );
                              if (response != null &&
                                  response.data != null &&
                                  response.data!.containsKey("error")) {
                                setStateDialog(() {
                                  _otpErrorMessage = response.data!["error"];
                                });
                              } else if (response != null && response.data != null) {
                                registrationSuccess = true;
                                Navigator.of(context).pop(); // закрыть диалог
                              } else {
                                setStateDialog(() {
                                  _otpErrorMessage = "Ошибка запроса";
                                });
                              }
                            }
                          : null,
                      child: const Text("Отправить"),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    return registrationSuccess;
  }

  /// Метод регистрации, объединяющий первичный запрос и подтверждение OTP.
  /// Если OTP не был подтверждён, выводится уведомление.
  Future<void> _register() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Пароли не совпадают")));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Если OTP ещё не отправлен или не подтвержден, выводим предупреждение.
    if (!_otpSent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Подтвердите номер телефона, нажав 'Получить код'")),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Если OTP не пройден, выдаём диалоговое уведомление.
    // Можно заменить эту логику на дополнительную проверку, если нужно.
    if (_otpController.text.trim().isEmpty) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.black.withOpacity(0.8),
          title: const Text(
            "Подтвердите номер телефона",
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Если регистрация уже проходила через _requestOtp, завершаем её успешным результатом.
    // Здесь можно добавить финальную логику по окончательному подтверждению регистрации,
    // например, сохранение данных, переход в другой экран и т.д.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Регистрация успешно завершена!")),
    );
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isLoggedIn", true);
    await prefs.setBool("isUserLoggedIn", true);
    await prefs.setString("userPhone", _phoneController.text);
    widget.onRegisterSuccess();

    setState(() {
      _isLoading = false;
    });
  }

  // Поле ввода номера телефона с кнопкой "Получить код"
  Widget _buildPhoneField(AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextUtil(text: loc.phone),
        Row(
          children: [
            // Поле ввода телефона
            Expanded(
              child: Container(
                height: 50,
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.white)),
                ),
                child: TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: loc.phone_hint,
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                  ),
                  onChanged: (_) {
                    setState(() {}); // обновление состояния для смены активности кнопки
                  },
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Кнопка "Получить код" неактивна, если номер не введён или идет загрузка
            GestureDetector(
              onTap: _phoneController.text.trim().isEmpty || _isLoading
                  ? null
                  : _requestOtp,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: _phoneController.text.trim().isEmpty
                      ? Colors.grey.withOpacity(0.5)
                      : Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "Получить код",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
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
              suffixIcon: isPassword || isConfirmPassword
                  ? IconButton(
                      icon: Icon(
                        obscureText ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          if (isConfirmPassword) {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
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
            child: showOption
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
                          backgroundColor: selectedIndex == index
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
                        items: _supportedLocales.map((locale) {
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
                    _buildTextField(
                      loc.name,
                      _nameController,
                      Icons.person,
                      loc.name_hint,
                      false,
                    ),
                    // Используем кастомное поле для номера телефона с кнопкой "Получить код"
                    _buildPhoneField(loc),
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
                        child: _isLoading
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
}
