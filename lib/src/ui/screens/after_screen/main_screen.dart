import 'package:aps/l10n/app_localizations.dart';
import 'package:aps/src/ui/screens/auth_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  static const double webBreakpoint = 900;
  
 Future<void> _logout(BuildContext context) async {
  try {
    print("⏳ Отправка запроса на logout...");
    Dio dio = Dio();
    final response = await dio.get("https://khaledo.pythonanywhere.com/logout");

    print("📩 Ответ от сервера: ${response.statusCode}"); // Лог ответа сервера

    if (response.statusCode == 200) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Очищаем сохраненные данные
      print("✅ Выход выполнен, данные очищены."); // Лог успешного выхода

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(
            selectedIndex: 0,
            onLoginSuccess: () {},
            onRegisterTapped: () {},
          ),
        ),
      ); // Возвращаем на экран входа
      print("🔄 Переход на экран входа..."); // Лог перехода на LoginScreen
    } else {
      print("⚠ Ошибка выхода: статус ${response.statusCode}");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ошибка выхода, попробуйте снова")),
      );
    }
  } catch (e) {
    print("❌ Ошибка выхода: $e"); // Лог ошибки
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Ошибка выхода: $e")),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= webBreakpoint) {
          return _buildWebLayout(context);
        } else {
          return _buildMobileLayout(context);
        }
      },
    );
  }

  // ---------------------------------------------------------------------------
  // WEB-ВЕРСТКА
  // ---------------------------------------------------------------------------
  Widget _buildWebLayout(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: _buildTopBarWeb(loc),
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
            child: Container(
              color: Colors.white,
              child: _buildMainContent(loc),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBarWeb(AppLocalizations loc) {
    return Row(
      children: [
        Text(
          loc.cargo_system,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 40),
        _topBarButton(loc.cargo),
        _topBarButton(loc.contractors),
        _topBarButton(loc.accounting),
        _topBarButton(loc.reports),
        _topBarButton(loc.setup),
        _topBarButton(loc.settings),
      ],
    );
  }

  Widget _topBarButton(String text) {
    return TextButton(onPressed: () {}, child: Text(text));
  }

  // ---------------------------------------------------------------------------
  // МОБИЛЬНАЯ ВЕРСТКА
  // ---------------------------------------------------------------------------
  Widget _buildMobileLayout(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: Text(
          loc.cargo_system,
          style: const TextStyle(color: Colors.black87),
        ),
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          // Перенёс бургер в `actions`
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
      endDrawer: _buildDrawer(loc, context), // Бургер-меню теперь справа
      body: _buildMainContent(loc),
      bottomNavigationBar: _buildBottomNavBar(loc), // Вернул нижний навбар
    );
  }

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
        _drawerItem(loc.cargo, Icons.business_center),
        InkWell(
          onTap: () => _logout(context), 
          child: _drawerItem(loc.contractors, Icons.people),
        ),
        _drawerItem(loc.accounting, Icons.attach_money),
        _drawerItem(loc.reports, Icons.insert_chart),
        _drawerItem(loc.setup, Icons.info),
        _drawerItem(loc.settings, Icons.settings),
      ],
    ),
  );
}



  Widget _drawerItem(String title, IconData icon) {
    return ListTile(leading: Icon(icon), title: Text(title), onTap: () {});
  }

  // ---------------------------------------------------------------------------
  // САЙДБАР ДЛЯ ВЕБА
  // ---------------------------------------------------------------------------
  Widget _buildSideBar(AppLocalizations loc) {
    return Column(
      children: [
        const SizedBox(height: 16),
        _sideBarItem(loc.flights, Icons.flight_takeoff),
        _sideBarItem(loc.cargo, Icons.business_center),
        _sideBarItem(loc.accounting, Icons.attach_money),
        _sideBarItem(loc.setup, Icons.info),
      ],
    );
  }

  Widget _sideBarItem(String title, IconData icon) {
    return ListTile(leading: Icon(icon), title: Text(title), onTap: () {});
  }

  // ---------------------------------------------------------------------------
  // ОСНОВНОЙ КОНТЕНТ
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

  // ---------------------------------------------------------------------------
  // НИЖНИЙ НАВБАР ДЛЯ МОБИЛЬНОЙ ВЕРСИИ
  // ---------------------------------------------------------------------------
  Widget _buildBottomNavBar(AppLocalizations loc) {
    return BottomNavigationBar(
      selectedItemColor: Colors.blueAccent,
      unselectedItemColor: Colors.grey,
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
        BottomNavigationBarItem(icon: const Icon(Icons.info), label: loc.setup),
      ],
    );
  }
}
