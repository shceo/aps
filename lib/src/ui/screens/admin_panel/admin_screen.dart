import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _currentIndex = 0; // 0 – основная панель, 1 – форма ввода данных

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool useSideNav = constraints.maxWidth >= 600;

        // Контент зависит от выбранной вкладки
        Widget content;
        if (_currentIndex == 0) {
          content = Center(
            child: AutoSizeText(
              'Добро пожаловать в Админ Панель!',
              style: const TextStyle(fontSize: 24),
              maxLines: 1,
            ),
          );
        } else {
          content = const ManualTableScreen();
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
              automaticallyImplyLeading: false,
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

// Класс для представления продукта (или другого элемента таблицы)
// Добавлен новый параметр weight для хранения данных "Кг"
class Product {
  String name;
  String quantity;
  String price;
  String weight;

  Product({
    this.name = "",
    this.quantity = "",
    this.price = "",
    this.weight = "",
  });
}

// Виджет формы-ввода данных в виде таблицы
class ManualTableScreen extends StatefulWidget {
  const ManualTableScreen({Key? key}) : super(key: key);

  @override
  State<ManualTableScreen> createState() => _ManualTableScreenState();
}

class _ManualTableScreenState extends State<ManualTableScreen> {
  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    // Добавляем одну пустую строку по умолчанию
    products.add(Product());
  }

  void _addRow() {
    setState(() {
      products.add(Product());
    });
  }

  void _saveData() {
    // Здесь можно добавить логику сохранения (например, отправку на сервер)
    // Для демонстрации выводим данные в консоль
    for (var product in products) {
      print('Название: ${product.name}, Кол-во: ${product.quantity}, Цена: ${product.price}, Кг: ${product.weight}');
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Данные сохранены')),
    );
  }

  Widget _buildRow(int index) {
    final product = products[index];
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: TextFormField(
            initialValue: product.name,
            decoration: const InputDecoration(
              labelText: 'Название',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              product.name = value;
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: TextFormField(
            initialValue: product.quantity,
            decoration: const InputDecoration(
              labelText: 'Кол-во',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              product.quantity = value;
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: TextFormField(
            initialValue: product.price,
            decoration: const InputDecoration(
              labelText: 'Цена',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              product.price = value;
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: TextFormField(
            initialValue: product.weight,
            decoration: const InputDecoration(
              labelText: 'Кг',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              product.weight = value;
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Заголовок таблицы
          Row(
            children: const [
              Expanded(
                flex: 3,
                child: Text('Название',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: Text('Кол-во',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: Text('Цена',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: Text('Кг',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) => _buildRow(index),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ElevatedButton(
                onPressed: _addRow,
                child: const Text("Добавить продукт"),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _saveData,
                child: const Text("Сохранить"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
