import 'package:aps/l10n/app_localizations.dart';
import 'package:aps/src/ui/widgets/custom_burger.dart';
import 'package:aps/src/ui/widgets/nav_bar.dart';
import 'package:aps/src/ui/widgets/order_code_verification.dart';
import 'package:aps/src/ui/constants/app_colors.dart';
import 'package:aps/src/ui/constants/screen_exports.dart';
import 'package:aps/src/ui/screens/drawers_screens/about_screen.dart';
import 'package:aps/src/ui/screens/drawers_screens/info_screen.dart';
import 'package:aps/src/ui/screens/drawers_screens/location_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _isOrderCodeVerified = false;
  static const double webBreakpoint = 900;

  // Индекс для табовой навигации (IndexedStack)
  int _currentIndex = 0;
  // Список дополнительных страниц для Navigator 2.0
  final List<Page> _childPages = [];

  @override
  void initState() {
    super.initState();
    _checkOrderCode();
  }

  /// Проверяем, сохранён ли флаг в SharedPreferences
  Future<void> _checkOrderCode() async {
    final prefs = await SharedPreferences.getInstance();
    bool verified = prefs.getBool('isOrderCodeVerified') ?? false;
    if (verified && mounted) {
      setState(() {
        _isOrderCodeVerified = true;
      });
    }
  }

  /// Добавляет новую страницу в стек Navigator
  void _pushPage(Widget page) {
    setState(() {
      _childPages.add(
        MaterialPage(
          key: ValueKey(
            page.runtimeType.toString() +
                DateTime.now().millisecondsSinceEpoch.toString(),
          ),
          child: page,
        ),
      );
    });
  }

  /// Сбрасывает вложенную навигацию (возвращает на главный экран)
  void _popToMain() {
    setState(() {
      _childPages.clear();
    });
  }

  Widget _buildAppBarTitle(bool isWeb) {
    Widget logo = Image.asset(
      'assets/icons/logo.png',
      height: 180,
      color: ApsColors.photoBlue,
    );
    if (isWeb) {
      return InkWell(
        onTap: () {
          _popToMain();
        },
        child: logo,
      );
    } else {
      return logo;
    }
  }

  Widget _buildOrderCodeVerification(AppLocalizations loc) {
    return OrderCodeVerification(
      onVerified: (bool verified) {
        setState(() {
          _isOrderCodeVerified = verified;
        });
      },
    );
  }

  /// Отображение контента в зависимости от состояния верификации
  Widget _buildContent(AppLocalizations loc) {
    if ((_currentIndex == 0 /*|| _currentIndex == 1*/ ) &&
        !_isOrderCodeVerified) {
      return _buildOrderCodeVerification(loc);
    } else {
      return _buildPageContent(loc);
    }
  }

  Widget _buildPageContent(AppLocalizations loc) {
    return IndexedStack(
      index: _currentIndex,
      children: [
        _buildMainContent(loc),
        // Center(child: Text(loc.details, style: const TextStyle(fontSize: 24))),
        MarketScreen(),
        Center(child: Text(loc.profile, style: const TextStyle(fontSize: 24))),
      ],
    );
  }

  /// В зависимости от ширины экрана выбирается веб- или мобильная вёрстка
  Widget _buildMainPage(AppLocalizations loc) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= webBreakpoint) {
          return _buildWebLayout(context, loc);
        } else {
          return _buildMobileLayout(context, loc);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Navigator(
      pages: [
        MaterialPage(
          key: const ValueKey("MainScreen"),
          child: _buildMainPage(loc),
        ),
        ..._childPages,
      ],
      onPopPage: (route, result) {
        if (!route.didPop(result)) return false;
        setState(() {
          _childPages.removeLast();
        });
        return true;
      },
    );
  }

  // ---------------------------------------------------------------------------
  // WEB-ВЕРСТКА
  // ---------------------------------------------------------------------------
  Widget _buildWebLayout(BuildContext context, AppLocalizations loc) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ApsColors.bwhite,
        title: _buildAppBarTitle(true),
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () => _pushPage(const InfoScreen()),
            child: Text(loc.cargo, style: const TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () => _pushPage(const AboutScreen()),
            child: Text(
              loc.contractors,
              style: const TextStyle(color: Colors.black),
            ),
          ),
          TextButton(
            onPressed: () => _pushPage(const LocationScreen()),
            child: Text(
              loc.accounting,
              style: const TextStyle(color: Colors.black),
            ),
          ),
          // TextButton(
          //   onPressed: () => _pushPage(const ReportsPage()),
          //   child: Text(
          //     loc.reports,
          //     style: const TextStyle(color: Colors.black),
          //   ),
          // ),
          // TextButton(
          //   onPressed: () => _pushPage(const SetupPage()),
          //   child: Text(loc.setup, style: const TextStyle(color: Colors.black)),
          // ),
          TextButton(
            onPressed: () => _pushPage(const SettingsPage()),
            child: Text(
              loc.settings,
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          Container(
            width: 200,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: ApsColors.bwhite,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  offset: const Offset(2, 0),
                  blurRadius: 2,
                ),
              ],
            ),
            child: CustomSideBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
          Expanded(
            child: Container(
              color: ApsColors.bwhite,
              child: _buildContent(loc),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // МОБИЛЬНАЯ ВЕРСТКА
  // ---------------------------------------------------------------------------
  Widget _buildMobileLayout(BuildContext context, AppLocalizations loc) {
    return Scaffold(
      backgroundColor: ApsColors.bwhite,
      appBar: AppBar(
        backgroundColor: ApsColors.bwhite,
        title: _buildAppBarTitle(false),
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Builder(
            builder: (context) {
              return IconButton(
                icon: Image.asset(
                  'assets/icons/drawer.png',
                  color: ApsColors.photoBlue,
                ),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              );
            },
          ),
        ],
      ),
      endDrawer: CustomBurgerMenu(
        loc: loc,
        onInfoTap: () {
          Navigator.of(context).pop();
          _pushPage(const InfoScreen());
        },
        onLocationTap: () {
          Navigator.of(context).pop();
          _pushPage(const AboutScreen());
        },
        onCargoTap: () {
          Navigator.of(context).pop();
          _pushPage(const LocationScreen());
        },
        onSettingsTap: () {
          Navigator.of(context).pop();
          _pushPage(const SettingsPage());
        },
        // onSettingsTap: () {
        //   Navigator.of(context).pop();
        //   _pushPage(const SettingsPage());
        // },
      ),
      body: _buildContent(loc),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ОСНОВНОЙ КОНТЕНТ (для индекса 0)
  // ---------------------------------------------------------------------------
  Widget _buildMainContent(AppLocalizations loc) {
    return MainContent(
      loc: loc,
      onReset: () async {
        // Сбрасываем флаг в SharedPreferences и обновляем состояние
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isOrderCodeVerified', false);
        setState(() {
          _isOrderCodeVerified = false;
        });
      },
    );
  }
}
