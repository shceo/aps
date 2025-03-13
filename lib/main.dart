import 'package:aps/src/ui/screens/admin_panel/admin_screen.dart';
import 'package:aps/src/ui/screens/after_screen/main_screen.dart';
import 'package:aps/src/ui/screens/after_screen/notfoundscreen.dart';
import 'package:aps/src/ui/screens/auth_screen.dart';
import 'package:aps/src/ui/screens/register_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:aps/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

/// Преобразователь URL в объект AppRoutePath и обратно.
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

/// RouterDelegate для управления навигацией.
class AppRouterDelegate extends RouterDelegate<AppRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<AppRoutePath> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  bool showAdmin = false;
  bool showRegister = false;

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
    return AppRoutePath.home(); // ✅ Теперь MainScreen показывается
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
                isUserLoggedIn = true; // ✅ Теперь флаг обновляется
                notifyListeners(); // ✅ Обновляем навигацию
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
        pages.add(
          MaterialPage(
            key: const ValueKey('AdminScreen'),
            child: AdminScreen(),
          ),
        );
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
    isUserLoggedIn =
        prefs.getBool("isLoggedIn") ?? false; // ✅ Теперь проверяет логин

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
        showRegister = false;
        showAdmin = false;
      }
    } else {
      showAdmin = false;
      showRegister = false;
    }

    notifyListeners(); // ✅ Теперь обновляет UI
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
        _routerDelegate.notifyListeners(); // ✅ Обновляет UI после логина
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

  /// ✅ Добавлен метод для смены языка
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
