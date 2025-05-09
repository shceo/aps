import 'dart:async';

import 'package:aps/src/core/di/injection.dart' as di;
import 'package:aps/src/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:aps/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aps/src/core/routes.dart';

Future<void> main() async {
  // Оборачиваем запуск приложения в зону с обработкой ошибок
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await di.initDi();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool isLoggedIn = prefs.getBool("isLoggedIn") ?? false;
      String savedLocale = prefs.getString("locale") ?? 'ru';
      runApp(MyApp(isLoggedIn: isLoggedIn, savedLocale: Locale(savedLocale)));
    },
    (error, stack) {
      debugPrint('Caught error in runZonedGuarded: \$error');
      debugPrintStack(stackTrace: stack);
    },
  );
}

class MyApp extends StatefulWidget {
  final bool isLoggedIn;
  final Locale savedLocale;

  const MyApp({super.key, required this.isLoggedIn, required this.savedLocale});

  static void setLocale(BuildContext context, Locale newLocale) async {
    final state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("locale", newLocale.languageCode);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Locale _locale;
  late AppRouterDelegate _routerDelegate;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _locale = widget.savedLocale;
    _routerDelegate = AppRouterDelegate(
      isLoggedIn: widget.isLoggedIn,
      selectedIndex: selectedIndex,
      onLoginSuccess: () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool("isLoggedIn", true);
        setState(() {
          _routerDelegate.isUserLoggedIn = true;
        });
        _routerDelegate.notifyListeners();
      },
    );
    loadSelectedIndex();
  }

  Future<void> loadSelectedIndex() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedIndex = prefs.getInt("selectedIndex") ?? 0;
    });
  }

  void setLocale(Locale newLocale) {
    setState(() {
      _locale = newLocale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerDelegate: _routerDelegate,
      routeInformationParser: AppRouteInformationParser(),
      locale: _locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      title: 'Aps Express',
    );
  }
}

// Пример placeholder‑страниц для маршрутов:

class FlightsPage extends StatelessWidget {
  const FlightsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Рейсы")),
      body: const Center(child: Text("Страница Рейсы")),
    );
  }
}

class CargoPage extends StatelessWidget {
  const CargoPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Груз")),
      body: const Center(child: Text("Страница Груз")),
    );
  }
}

class ContractorsPage extends StatelessWidget {
  const ContractorsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Подрядчики")),
      body: const Center(child: Text("Страница Подрядчики")),
    );
  }
}

class AccountingPage extends StatelessWidget {
  const AccountingPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Бухгалтерия")),
      body: const Center(child: Text("Страница Бухгалтерия")),
    );
  }
}

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Отчёты")),
      body: const Center(child: Text("Страница Отчёты")),
    );
  }
}

class SetupPage extends StatelessWidget {
  const SetupPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Настройка")),
      body: const Center(child: Text("Страница Настройка")),
    );
  }
}
