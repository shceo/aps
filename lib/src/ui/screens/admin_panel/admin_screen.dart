import 'package:aps/src/ui/screens/admin_panel/invoice_scree.dart';
import 'package:flutter/material.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _currentIndex = 1; // 0 – Панель, 1 – Таблица (инвойсы)

  // Список инвойсов (используем числа как идентификаторы)
  List<int> invoices = [1];

  /// Добавление нового инвойса (с новой нумерацией)
  void _addInvoice() {
    setState(() {
      int newId = (invoices.isNotEmpty ? invoices.last + 1 : 1);
      invoices.add(newId);
    });
  }

  /// Удаление инвойса с предварительным подтверждением
  void _deleteInvoice(int index) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Подтверждение удаления"),
            content: const Text(
              "Вы уверены, что хотите удалить этот контейнер?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Отмена"),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    invoices.removeAt(index);
                  });
                  Navigator.pop(context);
                },
                child: const Text(
                  "Удалить",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  /// Виджет одного контейнера инвойса с нумерацией и кнопками + и удаления
  Widget _buildInvoiceCard(int index) {
    int invoiceId = invoices[index];
    return GestureDetector(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InvoiceFormScreen(invoiceId: invoiceId),
            ),
          ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Заказ № $invoiceId", style: const TextStyle(fontSize: 18)),
            Row(
              children: [
                // Кнопка "плюс" для добавления нового контейнера
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.green),
                  onPressed: _addInvoice,
                ),
                // Кнопка удаления
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteInvoice(index),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Используем LayoutBuilder для определения, использовать сайд-бар или нижнюю навигацию
    return LayoutBuilder(
      builder: (context, constraints) {
        bool useSideNav = constraints.maxWidth >= 600;
        // Контент зависит от выбранного индекса
        Widget content;
        if (_currentIndex == 0) {
          content = const Center(
            child: Text(
              'Добро пожаловать в Админ Панель!',
              style: TextStyle(fontSize: 24),
            ),
          );
        } else {
          content = Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: invoices.length,
              itemBuilder: (context, index) => _buildInvoiceCard(index),
            ),
          );
        }

        if (useSideNav) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  labelType: NavigationRailLabelType.all,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.dashboard),
                      selectedIcon: Icon(Icons.dashboard_outlined),
                      label: Text('Панель'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.table_chart),
                      selectedIcon: Icon(Icons.table_chart_outlined),
                      label: Text('Таблица'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(child: content),
              ],
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Админ Панель'),
              centerTitle: true,
            ),
            body: content,
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard),
                  label: 'Панель',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.table_chart),
                  label: 'Таблица',
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
