import 'package:aps/src/ui/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:aps/l10n/app_localizations.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

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
    return CurvedNavigationBar(
      index: currentIndex,
      items: <Widget>[
        Icon(
          Icons.home,
          size: 30,
          color: currentIndex == 0 ? ApsColors.platinum : Colors.black,
        ),
        // Icon(
        //   Icons.info_outline,
        //   size: 30,
        //   color: currentIndex == 1 ? ApsColors.platinum : Colors.black,
        // ),
        Icon(
          Icons.store,
          size: 30,
          color: currentIndex == 1 ? ApsColors.platinum : Colors.black,
        ),
        Icon(
          Icons.person,
          size: 30,
          color: currentIndex == 2 ? ApsColors.platinum : Colors.black,
        ),
      ],
      color: ApsColors.photoBlue,
      buttonBackgroundColor: ApsColors.photoBlue,
      backgroundColor: Colors.white,
      animationCurve: Curves.easeInOut,
      animationDuration: Duration(milliseconds: 600),
      onTap: onTap,
      letIndexChange: (index) => true,
    );
  }
}

class CustomSideBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomSideBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Column(
      children: [
        const SizedBox(height: 16),
        ListTile(
          leading: Icon(
            Icons.home,
            color: currentIndex == 0 ? ApsColors.platinum : Colors.black,
          ),
          title: Text(loc.home),
          selected: currentIndex == 0,
          onTap: () => onTap(0),
        ),
        // ListTile(
        //   leading: Icon(
        //     Icons.info_outline,
        //     color: currentIndex == 1 ? ApsColors.platinum : Colors.black,
        //   ),
        //   title: Text(loc.details),
        //   selected: currentIndex == 1,
        //   onTap: () => onTap(1),
        // ),
        ListTile(
          leading: Icon(
            Icons.store,
            color: currentIndex == 1 ? ApsColors.platinum : Colors.black,
          ),
          title: Text(loc.shop),
          selected: currentIndex == 1,
          onTap: () => onTap(1),
        ),
        ListTile(
          leading: Icon(
            Icons.person,
            color: currentIndex == 2 ? ApsColors.platinum : Colors.black,
          ),
          title: Text(loc.profile),
          selected: currentIndex == 2,
          onTap: () => onTap(2),
        ),
      ],
    );
  }
}
