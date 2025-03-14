import 'package:aps/l10n/app_localizations.dart';
import 'package:aps/main.dart';
import 'package:aps/src/ui/components/custom_burger.dart';
import 'package:aps/src/ui/components/nav_bar.dart';
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
  Widget _buildOrderCodeVerification() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Введите код заказа",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _orderCodeController,
              decoration: InputDecoration(
                hintText: "Например, 1234",
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
                    const SnackBar(content: Text("Неверный код заказа")),
                  );
                }
              },
              child: const Text("Подтвердить"),
            ),
          ],
        ),
      ),
    );
  }

  /// Отображение контента в зависимости от состояния верификации
  Widget _buildContent(AppLocalizations loc) {
    if ((_currentIndex == 0 || _currentIndex == 1) && !_isOrderCodeVerified) {
      return _buildOrderCodeVerification();
    } else {
      return _buildPageContent(loc);
    }
  }

  /// IndexedStack для смены контента по табам
  Widget _buildPageContent(AppLocalizations loc) {
    return IndexedStack(
      index: _currentIndex,
      children: [
        _buildMainContent(loc),
        Center(child: Text("Подробнее", style: TextStyle(fontSize: 24))),
        Center(child: Text("Магазин", style: TextStyle(fontSize: 24))),
        Center(child: Text("Профиль", style: TextStyle(fontSize: 24))),
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
        MaterialPage(key: const ValueKey("MainScreen"), child: _buildMainPage(loc)),
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
            child: const Text("Груз", style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () => _pushPage(const ContractorsPage()),
            child: const Text("Контрагенты", style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () => _pushPage(const AccountingPage()),
            child: const Text("Бухгалтерия", style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () => _pushPage(const ReportsPage()),
            child: const Text("Отчеты", style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () => _pushPage(const SetupPage()),
            child: const Text("Настройка", style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () => _pushPage(const SettingsPage()),
            child: const Text("Настройки", style: TextStyle(color: Colors.black)),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildFlightInfoBar(loc),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              bool isWide = constraints.maxWidth > 600;
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildPlaneLayout(loc)),
                    const SizedBox(width: 16),
                    SizedBox(width: 300, child: _buildPayloadInfo(loc)),
                  ],
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildPlaneLayout(loc),
                    const SizedBox(height: 16),
                    _buildPayloadInfo(loc),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFlightInfoBar(AppLocalizations loc) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        children: [
          _infoChip(loc.flights),
          _infoChip("EDDF → LSGG"),
          _infoChip(loc.flight_plan),
          _infoChip("Airbus A330-600"),
        ],
      ),
    );
  }

  Widget _infoChip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: Colors.blueGrey[50],
    );
  }

  Widget _buildPlaneLayout(AppLocalizations loc) {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        loc.plane_layout,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildPayloadInfo(AppLocalizations loc) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.payload_info,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          _payloadItem("FLB-001", "2500 kg"),
          _payloadItem("FLB-002", "3200 kg"),
          _payloadItem("FLB-003", "1800 kg"),
          _payloadItem("FLB-004", "4000 kg"),
        ],
      ),
    );
  }

  Widget _payloadItem(String id, String weight) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(id)),
          Text(weight),
        ],
      ),
    );
  }
}
