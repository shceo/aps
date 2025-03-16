import 'package:aps/src/ui/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:aps/l10n/app_localizations.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: ApsColors.primary,
      unselectedItemColor: Colors.grey,
      onTap: onTap,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: loc.home,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.info_outline),
          label: loc.details,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.store),
          label: loc.shop,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person),
          label: loc.profile,
        ),
      ],
    );
  }
}

class CustomSideBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomSideBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Column(
      children: [
        const SizedBox(height: 16),
        ListTile(
          leading: const Icon(Icons.home),
          title: Text(loc.home),
          selected: currentIndex == 0,
          onTap: () => onTap(0),
        ),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: Text(loc.details),
          selected: currentIndex == 1,
          onTap: () => onTap(1),
        ),
        ListTile(
          leading: const Icon(Icons.store),
          title: Text(loc.shop),
          selected: currentIndex == 2,
          onTap: () => onTap(2),
        ),
        ListTile(
          leading: const Icon(Icons.person),
          title: Text(loc.profile),
          selected: currentIndex == 3,
          onTap: () => onTap(3),
        ),
      ],
    );
  }
}
