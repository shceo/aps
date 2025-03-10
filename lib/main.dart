import 'package:aps/l10n/app_localizations.dart';
import 'package:aps/src/ui/screens/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async{
   WidgetsFlutterBinding.ensureInitialized();
      //  await FlutterLocalization.instance.ensureInitialized();
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  Locale _locale = const Locale('ru');

  void _changeLanguage(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: _locale,
      supportedLocales: const [
        Locale('ru'),
        Locale('en'),
        Locale('zh'),
        Locale('tr'),
        Locale('uz'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: LoginScreen(),
    );
  }
}

// class HomeScreen extends StatelessWidget {
//   final Function(Locale) onLocaleChange;

//   const HomeScreen({super.key, required this.onLocaleChange});

//   @override
//   Widget build(BuildContext context) {
//     final isMobile = MediaQuery.of(context).size.width < 600;
//     final loc = AppLocalizations.of(context)!;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(loc.navigation),
//         actions: [
//           DropdownButton<Locale>(
//             underline: const SizedBox(),
//             icon: const Icon(Icons.language, color: Colors.white),
//             items: const [
//               DropdownMenuItem(value: Locale('ru'), child: Text("Русский")),
//               DropdownMenuItem(value: Locale('en'), child: Text("English")),
//               DropdownMenuItem(value: Locale('zh'), child: Text("中文")),
//               DropdownMenuItem(value: Locale('tr'), child: Text("Türkçe")),
//               DropdownMenuItem(value: Locale('uz'), child: Text("O'zbekcha")),
//             ],
//             onChanged: (newLocale) => onLocaleChange(newLocale!),
//           ),
//         ],
//       ),
//       body: Row(
//         children: [
//           if (!isMobile)
//             NavigationRail(
//               selectedIndex: 0,
//               destinations: [
//                 NavigationRailDestination(icon: const Icon(Icons.home), label: Text(loc.home)),
//                 NavigationRailDestination(icon: const Icon(Icons.search), label: Text(loc.search)),
//                 NavigationRailDestination(icon: const Icon(Icons.notifications), label: Text(loc.notifications)),
//                 NavigationRailDestination(icon: const Icon(Icons.settings), label: Text(loc.settings)),
//               ],
//               onDestinationSelected: (int index) {},
//             ),
//           Expanded(
//             child: Center(
//               child: Text("${loc.selected_language}: ${Localizations.localeOf(context).languageCode}",
//                   style: const TextStyle(fontSize: 20)),
//             ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: isMobile
//           ? BottomNavigationBar(
//               backgroundColor: Colors.white,
//               type: BottomNavigationBarType.fixed,
//               items: [
//                 BottomNavigationBarItem(icon: const Icon(Icons.home), label: loc.home),
//                 BottomNavigationBarItem(icon: const Icon(Icons.search), label: loc.search),
//                 BottomNavigationBarItem(icon: const Icon(Icons.notifications), label: loc.notifications),
//                 BottomNavigationBarItem(icon: const Icon(Icons.settings), label: loc.settings),
//               ],
//               onTap: (index) {},
//             )
//           : null,
//     );
//   }
