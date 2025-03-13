// import 'package:aps/src/ui/screens/admin_panel/admin_screen.dart';
// import 'package:aps/src/ui/screens/after_screen/main_screen.dart';
// import 'package:aps/src/ui/screens/auth_screen.dart';
// import 'package:aps/src/ui/screens/register_page.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   bool isLoggedIn = prefs.getBool("isLoggedIn") ?? false;
//   runApp(MyApp(isLoggedIn: isLoggedIn));
// }

// class AppRoutePath {
//   final bool isUnknown;
//   final bool isAdmin;
//   final bool isLogin;
//   final bool isHome;
//   final bool isRegister;

//   AppRoutePath.home()
//       : isHome = true,
//         isLogin = false,
//         isAdmin = false,
//         isRegister = false,
//         isUnknown = false;

//   AppRoutePath.login()
//       : isHome = false,
//         isLogin = true,
//         isAdmin = false,
//         isRegister = false,
//         isUnknown = false;

//   AppRoutePath.admin()
//       : isHome = false,
//         isLogin = false,
//         isAdmin = true,
//         isRegister = false,
//         isUnknown = false;

//   AppRoutePath.register()
//       : isHome = false,
//         isLogin = false,
//         isAdmin = false,
//         isRegister = true,
//         isUnknown = false;

//   AppRoutePath.unknown()
//       : isHome = false,
//         isLogin = false,
//         isAdmin = false,
//         isRegister = false,
//         isUnknown = true;
// }

// class AppRouteInformationParser extends RouteInformationParser<AppRoutePath> {
//   @override
//   Future<AppRoutePath> parseRouteInformation(RouteInformation routeInformation) async {
//     final uri = Uri.parse(routeInformation.location ?? '/');
//     if (uri.pathSegments.isEmpty) return AppRoutePath.home();

//     if (uri.pathSegments.length == 1) {
//       final path = uri.pathSegments.first;
//       if (path == 'aps-admins') return AppRoutePath.admin();
//       if (path == 'login') return AppRoutePath.login();
//       if (path == 'register') return AppRoutePath.register();
//     }
//     return AppRoutePath.unknown();
//   }

//   @override
//   RouteInformation restoreRouteInformation(AppRoutePath configuration) {
//     if (configuration.isHome) return const RouteInformation(location: '/');
//     if (configuration.isAdmin) return const RouteInformation(location: '/aps-admins');
//     if (configuration.isLogin) return const RouteInformation(location: '/login');
//     if (configuration.isRegister) return const RouteInformation(location: '/register');
//     return const RouteInformation(location: '/404');
//   }
// }

// class AppRouterDelegate extends RouterDelegate<AppRoutePath>
//     with ChangeNotifier, PopNavigatorRouterDelegateMixin<AppRoutePath> {
//   final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

//   bool isUserLoggedIn = false;
//   bool showRegister = false;
//   bool showAdmin = false;

//   AppRouterDelegate({required bool isLoggedIn, required Future<Null> Function() onLoginSuccess, required int selectedIndex}) {
//     isUserLoggedIn = isLoggedIn;
//   }

//   @override
//   AppRoutePath get currentConfiguration {
//     if (!isUserLoggedIn && !showRegister) return AppRoutePath.login();
//     if (!isUserLoggedIn && showRegister) return AppRoutePath.register();
//     if (showAdmin && isUserLoggedIn) return AppRoutePath.admin();
//     return AppRoutePath.home();
//   }

//   @override
//   Widget build(BuildContext context) {
//     List<Page> pages = [];

//     if (!isUserLoggedIn) {
//       pages.add(MaterialPage(
//         key: const ValueKey('LoginScreen'),
//         child: LoginScreen(
//           onLoginSuccess: () async {
//             SharedPreferences prefs = await SharedPreferences.getInstance();
//             await prefs.setBool("isLoggedIn", true);
//             isUserLoggedIn = true;
//             notifyListeners();
//           },
//           onRegisterTapped: () {
//             showRegister = true;
//             notifyListeners();
//           }, selectedIndex: 0,
//         ),
//       ));
//       if (showRegister) {
//         pages.add(MaterialPage(
//           key: const ValueKey('RegisterScreen'),
//           child: RegisterScreen(
//             onRegisterSuccess: () async {
//               SharedPreferences prefs = await SharedPreferences.getInstance();
//               await prefs.setBool("isLoggedIn", true);
//               isUserLoggedIn = true;
//               showRegister = false;
//               notifyListeners();
//             },
//             onSwitchToLogin: () {
//               showRegister = false;
//               notifyListeners();
//             }, selectedIndex: 0,
//           ),
//         ));
//       }
//     } else {
//       pages.add(MaterialPage(
//         key: const ValueKey('MainScreen'),
//         child: MainScreen(),
//       ));
//       if (showAdmin) {
//         pages.add(MaterialPage(
//           key: const ValueKey('AdminScreen'),
//           child: AdminScreen(),
//         ));
//       }
//     }

//     return Navigator(
//       key: navigatorKey,
//       pages: pages,
//       onPopPage: (route, result) {
//         if (!route.didPop(result)) return false;
//         if (showRegister) showRegister = false;
//         notifyListeners();
//         return true;
//       },
//     );
//   }

//   @override
//   Future<void> setNewRoutePath(AppRoutePath configuration) async {
//     if (configuration.isUnknown) {
//       showAdmin = false;
//       showRegister = false;
//     } else if (configuration.isRegister) {
//       showRegister = true;
//       showAdmin = false;
//     } else if (configuration.isAdmin) {
//       if (isUserLoggedIn) {
//         showAdmin = true;
//         showRegister = false;
//       } else {
//         showRegister = false;
//         showAdmin = false;
//       }
//     } else if (configuration.isHome) {
//       print("🏠 Переход на главный экран");
//     }
//     notifyListeners();
//   }
// }

// class MyApp extends StatelessWidget {
//   final bool isLoggedIn;

//   const MyApp({super.key, required this.isLoggedIn});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp.router(
//       debugShowCheckedModeBanner: false,
//       routerDelegate: AppRouterDelegate(isLoggedIn: isLoggedIn, onLoginSuccess: () {  }, selectedIndex: 0),
//       routeInformationParser: AppRouteInformationParser(),
//       title: 'Aps Express',
//     );
//   }
// }
