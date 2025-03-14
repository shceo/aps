import 'package:aps/l10n/app_localizations.dart';
import 'package:aps/main.dart';
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

  /// Метод для перехода на новую страницу.
  void _navigateTo(Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => page),
    );
  }

  Widget _buildAppBarTitle(bool isWeb) {
    Widget logo = Image.asset('assets/icons/logo.png', height: 30);
    if (isWeb) {
      return InkWell(
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainScreen()),
          );
        },
        child: logo,
      );
    } else {
      return logo;
    }
  }

  Widget _buildContent(AppLocalizations loc) {
    if (!_isOrderCodeVerified) {
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
    } else {
      return _buildMainContent(loc);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
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
      ),
      body: Row(
        children: [
          Container(
            width: 200,
            color: Colors.grey[200],
            child: _buildSideBar(loc),
          ),
          Expanded(
            child: Container(color: Colors.white, child: _buildContent(loc)),
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
      endDrawer: _buildDrawer(loc, context),
      body: _buildContent(loc),
      bottomNavigationBar: _buildBottomNavBar(loc),
    );
  }

  // Обновлённый Drawer с кликабельными элементами
  Widget _buildDrawer(AppLocalizations loc, BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blueAccent),
            child: Text(
              loc.cargo_system,
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          _drawerItem(
            loc.cargo,
            Icons.business_center,
            onTap: () {
              Navigator.of(context).pop();
              _navigateTo(const CargoPage());
            },
          ),
          _drawerItem(
            loc.contractors,
            Icons.people,
            onTap: () {
              Navigator.of(context).pop();
              _navigateTo(const ContractorsPage());
            },
          ),
          _drawerItem(
            loc.accounting,
            Icons.attach_money,
            onTap: () {
              Navigator.of(context).pop();
              _navigateTo(const AccountingPage());
            },
          ),
          _drawerItem(
            loc.reports,
            Icons.insert_chart,
            onTap: () {
              Navigator.of(context).pop();
              _navigateTo(const ReportsPage());
            },
          ),
          _drawerItem(
            loc.setup,
            Icons.info,
            onTap: () {
              Navigator.of(context).pop();
              _navigateTo(const SetupPage());
            },
          ),
          _drawerItem(
            loc.settings,
            Icons.settings,
            onTap: () {
              Navigator.of(context).pop();
              _navigateTo(const SettingsPage());
            },
          ),
        ],
      ),
    );
  }

  // Переопределённый метод для создания элемента Drawer с возможностью передать onTap
  Widget _drawerItem(String title, IconData icon, {VoidCallback? onTap}) {
    return ListTile(leading: Icon(icon), title: Text(title), onTap: onTap);
  }

  // Обновлённый сайдбар для WEB-версии с кликабельными элементами
  Widget _buildSideBar(AppLocalizations loc) {
    return Column(
      children: [
        const SizedBox(height: 16),
        _sideBarItem(
          loc.flights,
          Icons.flight_takeoff,
          onTap: () {
            _navigateTo(const FlightsPage());
          },
        ),
        _sideBarItem(
          loc.cargo,
          Icons.business_center,
          onTap: () {
            _navigateTo(const CargoPage());
          },
        ),
        _sideBarItem(
          loc.accounting,
          Icons.attach_money,
          onTap: () {
            _navigateTo(const AccountingPage());
          },
        ),
        _sideBarItem(
          loc.setup,
          Icons.info,
          onTap: () {
            _navigateTo(const SetupPage());
          },
        ),
      ],
    );
  }

  // Переопределённый метод для создания элемента сайдбара с возможностью передать onTap
  Widget _sideBarItem(String title, IconData icon, {VoidCallback? onTap}) {
    return ListTile(leading: Icon(icon), title: Text(title), onTap: onTap);
  }

  // ---------------------------------------------------------------------------
  // ОСНОВНОЙ КОНТЕНТ (после подтверждения кода)
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
    return Chip(label: Text(label), backgroundColor: Colors.blueGrey[50]);
  }

  Widget _buildPlaneLayout(AppLocalizations loc) {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(loc.plane_layout, textAlign: TextAlign.center),
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
      child: Row(children: [Expanded(child: Text(id)), Text(weight)]),
    );
  }

  // Обновлённая нижняя навигационная панель с onTap-обработчиком
  Widget _buildBottomNavBar(AppLocalizations loc) {
    return BottomNavigationBar(
      selectedItemColor: Colors.blueAccent,
      unselectedItemColor: Colors.grey,
      currentIndex: 0, // можно реализовать сохранение индекса, если требуется
      onTap: (index) {
        switch (index) {
          case 0:
            _navigateTo(const FlightsPage());
            break;
          case 1:
            _navigateTo(const CargoPage());
            break;
          case 2:
            _navigateTo(const AccountingPage());
            break;
          case 3:
            _navigateTo(const SetupPage());
            break;
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.flight_takeoff),
          label: loc.flights,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.business_center),
          label: loc.cargo,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.attach_money),
          label: loc.accounting,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.info),
          label: loc.setup,
        ),
      ],
    );
  }
}
