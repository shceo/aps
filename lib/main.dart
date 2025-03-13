import 'package:aps/src/ui/screens/after_screen/main_screen.dart';
import 'package:aps/src/ui/screens/auth_screen.dart'; // Предполагается, что LoginScreen здесь
import 'package:aps/src/ui/screens/admin_screen.dart';
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

/// Модель маршрута приложения
class AppRoutePath {
  final bool isUnknown;
  final bool isAdmin;
  final bool isLogin;
  final bool isHome;

  AppRoutePath.home()
    : isHome = true,
      isLogin = false,
      isAdmin = false,
      isUnknown = false;

  AppRoutePath.login()
    : isHome = false,
      isLogin = true,
      isAdmin = false,
      isUnknown = false;

  AppRoutePath.admin()
    : isHome = false,
      isLogin = false,
      isAdmin = true,
      isUnknown = false;

  AppRoutePath.unknown()
    : isHome = false,
      isLogin = false,
      isAdmin = false,
      isUnknown = true;
}

/// Преобразователь URL в объект AppRoutePath и обратно.
class AppRouteInformationParser extends RouteInformationParser<AppRoutePath> {
  @override
  Future<AppRoutePath> parseRouteInformation(
    RouteInformation routeInformation,
  ) async {
    final uri = Uri.parse(routeInformation.location);
    if (uri.pathSegments.isEmpty) {
      return AppRoutePath.home();
    }
    if (uri.pathSegments.length == 1) {
      final path = uri.pathSegments.first;
      if (path == '/aps-admins') {
        return AppRoutePath.admin();
      }
      if (path == '/login') {
        return AppRoutePath.login();
      }
    }
    return AppRoutePath.unknown();
  }

  @override
  RouteInformation restoreRouteInformation(AppRoutePath configuration) {
    if (configuration.isHome) {
      return const RouteInformation(location: '/');
    }
    if (configuration.isAdmin) {
      return const RouteInformation(location: '/aps-admins');
    }
    if (configuration.isLogin) {
      return const RouteInformation(location: '/login');
    }
    return const RouteInformation(location: '/404');
  }
}

/// RouterDelegate для управления навигационным стеком.
class AppRouterDelegate extends RouterDelegate<AppRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<AppRoutePath> {
  final GlobalKey<NavigatorState> navigatorKey;
  // Флаги для управления стеком.
  bool showAdmin = true;
  bool showUnknown = false;

  // Логика авторизации передаётся извне.
  final bool isLoggedIn;
  // Используется для передачи параметра в LoginScreen.
  final int selectedIndex;

  AppRouterDelegate({required this.isLoggedIn, required this.selectedIndex})
    : navigatorKey = GlobalKey<NavigatorState>();

  @override
  AppRoutePath get currentConfiguration {
    if (showUnknown) return AppRoutePath.unknown();
    if (showAdmin && isLoggedIn) return AppRoutePath.admin();
    return isLoggedIn ? AppRoutePath.home() : AppRoutePath.login();
  }

  @override
  Widget build(BuildContext context) {
    List<Page> pages = [];
    if (!isLoggedIn) {
      pages.add(
        MaterialPage(
          key: const ValueKey('LoginScreen'),
          child: LoginScreen(
            selectedIndex: selectedIndex,
            onLoginSuccess: () {},
            onRegisterTapped: () {},
          ),
        ),
      );
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
    if (showUnknown) {
      pages.add(
        MaterialPage(
          key: const ValueKey('UnknownScreen'),
          child: UnknownScreen(),
        ),
      );
    }
    return Navigator(
      key: navigatorKey,
      pages: pages,
      onPopPage: (route, result) {
        if (!route.didPop(result)) return false;
        if (showAdmin) {
          showAdmin = false;
        }
        if (showUnknown) {
          showUnknown = false;
        }
        notifyListeners();
        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(AppRoutePath configuration) async {
    if (configuration.isUnknown) {
      showUnknown = true;
      showAdmin = true;
      return;
    }
    if (configuration.isAdmin) {
      if (isLoggedIn) {
        showAdmin = true;
        showUnknown = false;
      } else {
        showAdmin = false;
        showUnknown = false;
      }
      return;
    }
    if (configuration.isLogin) {
      showAdmin = false;
      showUnknown = false;
      return;
    }
    showAdmin = false;
    showUnknown = false;
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
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _locale = widget.savedLocale;
  }

  void setLocale(Locale newLocale) {
    setState(() {
      _locale = newLocale;
    });
  }

  Future<void> loadSelectedIndex() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedIndex = prefs.getInt("selectedIndex") ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final routerDelegate = AppRouterDelegate(
      isLoggedIn: widget.isLoggedIn,
      selectedIndex: selectedIndex,
    );
    final routeInformationParser = AppRouteInformationParser();

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerDelegate: routerDelegate,
      routeInformationParser: routeInformationParser,
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
