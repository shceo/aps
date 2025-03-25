// import 'package:flutter/material.dart';
// import 'package:aps/src/ui/screens/admin_panel/admin_screen.dart';
// import 'package:aps/src/ui/screens/admin_panel/login_admin_screen.dart';
// import 'package:aps/src/ui/screens/after_screen/main_screen.dart';
// import 'package:aps/src/ui/screens/auth_screen.dart';
// import 'package:aps/src/ui/screens/register_page.dart';

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
//     if (configuration.isAdmin)
//       return const RouteInformation(location: '/aps-admins');
//     if (configuration.isLogin)
//       return const RouteInformation(location: '/login');
//     if (configuration.isRegister)
//       return const RouteInformation(location: '/register');
//     return const RouteInformation(location: '/404');
//   }
// }

// class AppRouterDelegate extends RouterDelegate<AppRoutePath>
//     with ChangeNotifier, PopNavigatorRouterDelegateMixin<AppRoutePath> {
//   final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

//   bool showAdmin = false;
//   bool showRegister = false;
//   bool isAdminLoggedIn = false;

//   final bool isLoggedIn;
//   final int selectedIndex;
//   final VoidCallback onLoginSuccess;
//   bool isUserLoggedIn = false;

//   AppRouterDelegate({
//     required this.isLoggedIn,
//     required this.selectedIndex,
//     required this.onLoginSuccess,
//   });

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
//       pages.add(
//         MaterialPage(
//           key: const ValueKey('LoginScreen'),
//           child: LoginScreen(
//             selectedIndex: selectedIndex,
//             onLoginSuccess: () async {
//               // Пример сохранения состояния
//               // После успешного входа, обновите состояние
//               isUserLoggedIn = true;
//               notifyListeners();
//             },
//             onRegisterTapped: () {
//               showRegister = true;
//               notifyListeners();
//             },
//           ),
//         ),
//       );
//       if (showRegister) {
//         pages.add(
//           MaterialPage(
//             key: const ValueKey('RegisterScreen'),
//             child: RegisterScreen(
//               selectedIndex: selectedIndex,
//               onRegisterSuccess: () async {
//                 isUserLoggedIn = true;
//                 notifyListeners();
//               },
//               onSwitchToLogin: () {
//                 showRegister = false;
//                 notifyListeners();
//               },
//             ),
//           ),
//         );
//       }
//     } else {
//       pages.add(
//         MaterialPage(key: const ValueKey('MainScreen'), child: MainScreen()),
//       );
//       if (showAdmin) {
//         if (!isAdminLoggedIn) {
//           pages.add(
//             MaterialPage(
//               key: const ValueKey('LoginAdminScreen'),
//               child: LoginAdminScreen(
//                 onAdminLoginSuccess: () async {
//                   isAdminLoggedIn = true;
//                   notifyListeners();
//                 },
//               ),
//             ),
//           );
//         } else {
//           pages.add(
//             MaterialPage(
//               key: const ValueKey('AdminScreen'),
//               child: AdminScreen(),
//             ),
//           );
//         }
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
//     // Загрузка данных из SharedPreferences или другая логика
//     notifyListeners();
//   }
// }

// class UnknownScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("404")),
//       body: const Center(child: Text("Страница не найдена")),
//     );
//   }
// }
