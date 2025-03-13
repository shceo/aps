import 'package:aps/src/ui/screens/after_screen/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:aps/l10n/app_localizations.dart';
import 'package:aps/src/ui/screens/admin_screen.dart';
import 'package:aps/src/ui/screens/auth_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool("isLoggedIn") ?? false;

  String savedLocale = prefs.getString("locale") ?? 'ru';

  runApp(MyApp(isLoggedIn: isLoggedIn, savedLocale: Locale(savedLocale)));
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home:
          widget.isLoggedIn
              ? MainScreen()
              : LoginScreen(selectedIndex: selectedIndex),
      routes: {if (kIsWeb) '/aps-admins': (context) => AdminScreen()},
      debugShowCheckedModeBanner: false,
      locale: _locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
