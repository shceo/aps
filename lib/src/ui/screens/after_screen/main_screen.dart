import 'package:aps/l10n/app_localizations.dart';
import 'package:aps/main.dart';
import 'package:aps/src/ui/components/custom_burger.dart';
import 'package:aps/src/ui/components/nav_bar.dart';
import 'package:aps/src/ui/screens/after_screen/main_screen_content.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _isOrderCodeVerified = false;
  final TextEditingController _orderCodeController = TextEditingController();
  static const double webBreakpoint = 900;

  // Индекс для табовой навигации (IndexedStack)
  int _currentIndex = 0;

  // Список дополнительных страниц для Navigator 2.0
  final List<Page> _childPages = [];

  /// Добавляет новую страницу в стек Navigator (Navigator 2.0)
  void _pushPage(Widget page) {
    setState(() {
      _childPages.add(
        MaterialPage(
          key: ValueKey(page.runtimeType.toString() +
              DateTime.now().millisecondsSinceEpoch.toString()),
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
    Widget logo = Image.asset('assets/icons/logo.png', height: 30);
    if (isWeb) {
      return InkWell(
        onTap: () {
          // При нажатии возвращаемся к главной странице (сбрасываем вложенные страницы)
          _popToMain();
        },
        child: logo,
      );
    } else {
      return logo;
    }
  }

  /// Форма верификации кода заказа
  Widget _buildOrderCodeVerification(AppLocalizations loc) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              loc.enter_order_code,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _orderCodeController,
              decoration: InputDecoration(
                hintText: loc.order_code_hint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_orderCodeController.text == "1234") {
                  setState(() {
                    _isOrderCodeVerified = true;
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(loc.invalid_order_code)),
                  );
                }
              },
              child: Text(loc.confirm_order_code),
            ),
          ],
        ),
      ),
    );
  }

  /// Отображение контента в зависимости от состояния верификации
  Widget _buildContent(AppLocalizations loc) {
    if ((_currentIndex == 0 || _currentIndex == 1) && !_isOrderCodeVerified) {
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
        Center(child: Text(loc.details, style: const TextStyle(fontSize: 24))),
        Center(child: Text(loc.shop, style: const TextStyle(fontSize: 24))),
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
      // Первой страницей всегда является основная (главный Scaffold)
      pages: [
        MaterialPage(
            key: const ValueKey("MainScreen"), child: _buildMainPage(loc)),
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
        backgroundColor: Colors.white,
        elevation: 2,
        title: _buildAppBarTitle(true),
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () => _pushPage(const CargoPage()),
            child: Text(loc.cargo, style: const TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () => _pushPage(const ContractorsPage()),
            child:
                Text(loc.contractors, style: const TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () => _pushPage(const AccountingPage()),
            child:
                Text(loc.accounting, style: const TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () => _pushPage(const ReportsPage()),
            child: Text(loc.reports, style: const TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () => _pushPage(const SetupPage()),
            child: Text(loc.setup, style: const TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () => _pushPage(const SettingsPage()),
            child: Text(loc.settings, style: const TextStyle(color: Colors.black)),
          ),
        ],
      ),
      body: Row(
        children: [
          Container(
            width: 200,
            color: Colors.grey[200],
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
              color: Colors.white,
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: _buildAppBarTitle(false),
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu),
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
        onCargoTap: () {
          Navigator.of(context).pop(); // закрываем Drawer
          _pushPage(const CargoPage());
        },
        onContractorsTap: () {
          Navigator.of(context).pop();
          _pushPage(const ContractorsPage());
        },
        onAccountingTap: () {
          Navigator.of(context).pop();
          _pushPage(const AccountingPage());
        },
        onReportsTap: () {
          Navigator.of(context).pop();
          _pushPage(const ReportsPage());
        },
        onSetupTap: () {
          Navigator.of(context).pop();
          _pushPage(const SetupPage());
        },
        onSettingsTap: () {
          Navigator.of(context).pop();
          _pushPage(const SettingsPage());
        },
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
    return MainContent(loc: loc);
  }
}
