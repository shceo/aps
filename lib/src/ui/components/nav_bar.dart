import 'package:flutter/material.dart';

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
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: Colors.blueAccent,
      unselectedItemColor: Colors.grey,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Главное",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.info_outline),
          label: "Подробнее",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.store),
          label: "Магазин",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "Профиль",
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
    return Column(
      children: [
        const SizedBox(height: 16),
        ListTile(
          leading: const Icon(Icons.home),
          title: const Text("Главное"),
          selected: currentIndex == 0,
          onTap: () => onTap(0),
        ),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text("Подробнее"),
          selected: currentIndex == 1,
          onTap: () => onTap(1),
        ),
        ListTile(
          leading: const Icon(Icons.store),
          title: const Text("Магазин"),
          selected: currentIndex == 2,
          onTap: () => onTap(2),
        ),
        ListTile(
          leading: const Icon(Icons.person),
          title: const Text("Профиль"),
          selected: currentIndex == 3,
          onTap: () => onTap(3),
        ),
      ],
    );
  }
}
