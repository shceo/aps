import 'package:aps/firebase_options.dart';
import 'package:aps/src/ui/screens/admin_panel/admin_screen.dart';
import 'package:aps/src/ui/screens/admin_panel/login_admin_screen.dart';
import 'package:aps/src/ui/screens/after_screen/main_screen.dart';
import 'package:aps/src/ui/screens/auth_screen.dart';
import 'package:aps/src/ui/screens/register_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:aps/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool("isLoggedIn") ?? false;
  String savedLocale = prefs.getString("locale") ?? 'ru';
  runApp(MyApp(isLoggedIn: isLoggedIn, savedLocale: Locale(savedLocale)));
}

class AppRoutePath {
  final bool isUnknown;
  final bool isAdmin;
  final bool isLogin;
  final bool isHome;
  final bool isRegister;

  AppRoutePath.home()
    : isHome = true,
      isLogin = false,
      isAdmin = false,
      isRegister = false,
      isUnknown = false;

  AppRoutePath.login()
    : isHome = false,
      isLogin = true,
      isAdmin = false,
      isRegister = false,
      isUnknown = false;

  AppRoutePath.admin()
    : isHome = false,
      isLogin = false,
      isAdmin = true,
      isRegister = false,
      isUnknown = false;

  AppRoutePath.register()
    : isHome = false,
      isLogin = false,
      isAdmin = false,
      isRegister = true,
      isUnknown = false;

  AppRoutePath.unknown()
    : isHome = false,
      isLogin = false,
      isAdmin = false,
      isRegister = false,
      isUnknown = true;
}

class AppRouteInformationParser extends RouteInformationParser<AppRoutePath> {
  @override
  Future<AppRoutePath> parseRouteInformation(
    RouteInformation routeInformation,
  ) async {
    final uri = Uri.parse(routeInformation.location ?? '/');
    if (uri.pathSegments.isEmpty) return AppRoutePath.home();

    if (uri.pathSegments.length == 1) {
      final path = uri.pathSegments.first;
      if (path == 'aps-admins') return AppRoutePath.admin();
      if (path == 'login') return AppRoutePath.login();
      if (path == 'register') return AppRoutePath.register();
    }
    return AppRoutePath.unknown();
  }

  @override
  RouteInformation restoreRouteInformation(AppRoutePath configuration) {
    if (configuration.isHome) return const RouteInformation(location: '/');

    if (configuration.isAdmin)
      return const RouteInformation(location: '/aps-admins');

    if (configuration.isLogin)
      return const RouteInformation(location: '/login');
    if (configuration.isRegister)
      return const RouteInformation(location: '/register');

    return const RouteInformation(location: '/404');
  }
}

class AppRouterDelegate extends RouterDelegate<AppRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<AppRoutePath> {
  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  bool showAdmin = false;
  bool showRegister = false;
  bool isAdminLoggedIn = false;

  final bool isLoggedIn;
  final int selectedIndex;
  final VoidCallback onLoginSuccess;
  bool isUserLoggedIn = false;

  AppRouterDelegate({
    required this.isLoggedIn,
    required this.selectedIndex,
    required this.onLoginSuccess,
  });

  @override
  AppRoutePath get currentConfiguration {
    if (!isUserLoggedIn && !showRegister) return AppRoutePath.login();
    if (!isUserLoggedIn && showRegister) return AppRoutePath.register();
    if (showAdmin && isUserLoggedIn) return AppRoutePath.admin();
    return AppRoutePath.home();
  }

  @override
  Widget build(BuildContext context) {
    List<Page> pages = [];

    if (!isUserLoggedIn) {
      pages.add(
        MaterialPage(
          key: const ValueKey('LoginScreen'),
          child: LoginScreen(
            selectedIndex: selectedIndex,
            onLoginSuccess: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setBool("isLoggedIn", true);
              isUserLoggedIn = true;
              notifyListeners();
            },
            onRegisterTapped: () {
              showRegister = true;
              notifyListeners();
            },
          ),
        ),
      );
      if (showRegister) {
        pages.add(
          MaterialPage(
            key: const ValueKey('RegisterScreen'),
            child: RegisterScreen(
              selectedIndex: selectedIndex,
              onRegisterSuccess: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setBool("isLoggedIn", true);
                isUserLoggedIn = true;
                notifyListeners();
              },
              onSwitchToLogin: () {
                showRegister = false;
                notifyListeners();
              },
            ),
          ),
        );
      }
    } else {
      pages.add(
        MaterialPage(key: const ValueKey('MainScreen'), child: MainScreen()),
      );
      if (showAdmin) {
        if (!isAdminLoggedIn) {
          pages.add(
            MaterialPage(
              key: const ValueKey('AdminAuthScreen'),
              child: AdminAuthScreen(
                onAdminAuthSuccess: () async {
                  // После успешного входа/регистрации админа:
                  isAdminLoggedIn = true;
                  notifyListeners();
                },
              ),
            ),
          );
        } else {
          pages.add(
            MaterialPage(
              key: const ValueKey('AdminScreen'),
              child: AdminScreen(),
            ),
          );
        }
      }
    }

    return Navigator(
      key: navigatorKey,
      pages: pages,
      onPopPage: (route, result) {
        if (!route.didPop(result)) return false;
        if (showRegister) showRegister = false;
        notifyListeners();
        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(AppRoutePath configuration) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isUserLoggedIn = prefs.getBool("isLoggedIn") ?? false;

    if (configuration.isUnknown) {
      showAdmin = false;
      showRegister = false;
    } else if (configuration.isRegister) {
      showRegister = true;
      showAdmin = false;
    } else if (configuration.isAdmin) {
      if (isUserLoggedIn) {
        showAdmin = true;
        showRegister = false;
      } else {
        showAdmin = false;
        showRegister = false;
      }
    } else {
      showAdmin = false;
      showRegister = false;
    }
    notifyListeners();
  }
}

class UnknownScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("404")),
      body: const Center(child: Text("Страница не найдена")),
    );
  }
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
