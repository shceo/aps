// lib/src/core/routes.dart

import 'package:aps/src/core/constants/screen_exports.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Экраны, которые уже используются в навигации:
import 'package:aps/src/features/auth/presentation/screens/auth_screen.dart';
import 'package:aps/src/features/auth/presentation/screens/register_page.dart';

import 'package:aps/src/features/admin_panel/presentation/screens/admin_screen.dart';
import 'package:aps/src/features/user_interface/presentation/screens/main_screen.dart';

/// Описывает «куда» мы навигируем
class AppRoutePath {
  final bool isUnknown;
  final bool isAdmin;
  final bool isLogin;
  final bool isHome;
  final bool isRegister;

  const AppRoutePath._({
    required this.isHome,
    required this.isLogin,
    required this.isAdmin,
    required this.isRegister,
    required this.isUnknown,
  });

  factory AppRoutePath.home() => const AppRoutePath._(
    isHome: true,
    isLogin: false,
    isAdmin: false,
    isRegister: false,
    isUnknown: false,
  );

  factory AppRoutePath.login() => const AppRoutePath._(
    isHome: false,
    isLogin: true,
    isAdmin: false,
    isRegister: false,
    isUnknown: false,
  );

  factory AppRoutePath.admin() => const AppRoutePath._(
    isHome: false,
    isLogin: false,
    isAdmin: true,
    isRegister: false,
    isUnknown: false,
  );

  factory AppRoutePath.register() => const AppRoutePath._(
    isHome: false,
    isLogin: false,
    isAdmin: false,
    isRegister: true,
    isUnknown: false,
  );

  factory AppRoutePath.unknown() => const AppRoutePath._(
    isHome: false,
    isLogin: false,
    isAdmin: false,
    isRegister: false,
    isUnknown: true,
  );
}

/// Преобразует URL в AppRoutePath и обратно
class AppRouteInformationParser extends RouteInformationParser<AppRoutePath> {
  @override
  Future<AppRoutePath> parseRouteInformation(
    RouteInformation routeInformation,
  ) async {
    final uri = Uri.parse(routeInformation.location ?? '');
    if (uri.pathSegments.isEmpty) return AppRoutePath.home();

    if (uri.pathSegments.length == 1) {
      switch (uri.pathSegments.first) {
        case 'aps-admins':
          return AppRoutePath.admin();
        case 'login':
          return AppRoutePath.login();
        case 'register':
          return AppRoutePath.register();
      }
    }
    return AppRoutePath.unknown();
  }

  @override
  RouteInformation restoreRouteInformation(AppRoutePath config) {
    if (config.isHome) return const RouteInformation(location: '/');
    if (config.isAdmin) return const RouteInformation(location: '/aps-admins');
    if (config.isLogin) return const RouteInformation(location: '/login');
    if (config.isRegister) return const RouteInformation(location: '/register');
    return const RouteInformation(location: '/404');
  }
}

/// Главный делегат, строит стек страниц на основе AppRoutePath
class AppRouterDelegate extends RouterDelegate<AppRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<AppRoutePath> {
  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  bool showAdmin = false;
  bool showRegister = false;
  bool isAdminLoggedIn = false;
  bool isUserLoggedIn = false;

  final bool isLoggedIn;
  final int selectedIndex;
  final VoidCallback onLoginSuccess;

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
    final List<Page> pages = [];

    if (!isUserLoggedIn) {
      // Экран логина
      pages.add(
        MaterialPage(
          key: const ValueKey('LoginScreen'),
          child: LoginScreen(
            selectedIndex: selectedIndex,
            onLoginSuccess: () async {
              final prefs = await SharedPreferences.getInstance();
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
        // Экран регистрации
        pages.add(
          MaterialPage(
            key: const ValueKey('RegisterScreen'),
            child: RegisterScreen(
              selectedIndex: selectedIndex,
              onRegisterSuccess: () async {
                final prefs = await SharedPreferences.getInstance();
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
      // Основной пользовательский экран
      pages.add(
        MaterialPage(key: const ValueKey('MainScreen'), child: MainScreen()),
      );
      if (showAdmin) {
        // Админ-логика
        if (!isAdminLoggedIn) {
          pages.add(
            MaterialPage(
              key: const ValueKey('AdminAuthScreen'),
              child: AdminAuthScreen(
                onAdminAuthSuccess: () async {
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
    final prefs = await SharedPreferences.getInstance();
    isUserLoggedIn = prefs.getBool("isLoggedIn") ?? false;

    if (configuration.isUnknown) {
      showAdmin = showRegister = false;
    } else if (configuration.isRegister) {
      showRegister = true;
      showAdmin = false;
    } else if (configuration.isAdmin) {
      if (isUserLoggedIn) {
        showAdmin = true;
        showRegister = false;
      }
    } else {
      showAdmin = showRegister = false;
    }
    notifyListeners();
  }
}

/// Экран «404»
class UnknownScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text("404")),
    body: const Center(child: Text("Страница не найдена")),
  );
}
