import 'package:aps/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class CustomBurgerMenu extends StatelessWidget {
  final AppLocalizations loc;
  final VoidCallback onInfoTap;
  final VoidCallback onLocationTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onCargoTap;
  // final VoidCallback onContractorsTap;
  // final VoidCallback onAccountingTap;
  // final VoidCallback onReportsTap;
  // final VoidCallback onSetupTap;
  // final VoidCallback onSettingsTap;

  const CustomBurgerMenu({
    super.key,
    required this.loc,
    required this.onInfoTap,
    required this.onLocationTap,
    required this.onSettingsTap,
    required this.onCargoTap,
    // required this.onContractorsTap,
    // required this.onAccountingTap,
    // required this.onReportsTap,
    // required this.onSetupTap,
    // required this.onSettingsTap,
  });

  Widget _drawerItem(String title, IconData icon, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
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
          _drawerItem(loc.cargo, Icons.business_center, onTap: onInfoTap),
          _drawerItem(loc.contractors, Icons.people, onTap: onLocationTap),
          _drawerItem(loc.accounting, Icons.attach_money, onTap: onSettingsTap),
          _drawerItem(loc.reports, Icons.insert_chart, onTap: onCargoTap),
          // _drawerItem(loc.setup, Icons.info, onTap: onSetupTap),
          // _drawerItem(loc.settings, Icons.settings, onTap: onSettingsTap),
        ],
      ),
    );
  }
}
