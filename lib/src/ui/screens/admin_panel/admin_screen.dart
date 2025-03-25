import 'package:aps/src/ui/screens/admin_panel/invoice_scree.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _currentIndex = 1; // 0 – Панель, 1 – Таблица (инвойсы)
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Добавление нового инвойса: вычисляем новый номер и создаём пустой документ
  Future<void> _addInvoice() async {
    try {
      // Получаем все документы коллекции "invoices"
      QuerySnapshot snapshot =
          await _firestore.collection('invoices').get();
      int newId = 1;
      if (snapshot.docs.isNotEmpty) {
        // Предполагаем, что идентификаторы документов — это числа в виде строк
        newId = snapshot.docs
                .map((doc) => int.tryParse(doc.id) ?? 0)
                .fold(0, (prev, element) => element > prev ? element : prev) +
            1;
      }
      // Создаём новый документ с новым идентификатором
      await _firestore
          .collection('invoices')
          .doc(newId.toString())
          .set({'invoice_no': newId});
    } catch (e) {
      debugPrint("Ошибка при добавлении инвойса: $e");
    }
  }

  /// Удаление инвойса с подтверждением и удалением из Firestore
  void _deleteInvoice(String invoiceId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Подтверждение удаления"),
        content: const Text("Вы уверены, что хотите удалить этот контейнер?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Отмена"),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _firestore
                    .collection('invoices')
                    .doc(invoiceId)
                    .delete();
              } catch (e) {
                debugPrint("Ошибка удаления из Firestore: $e");
              }
              Navigator.pop(context);
            },
            child: const Text("Удалить", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// Виджет одного контейнера инвойса с нумерацией и кнопками + и удаления
  Widget _buildInvoiceCard(DocumentSnapshot doc) {
    // Документ ID — это номер инвойса
    String invoiceId = doc.id;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InvoiceFormScreen(invoiceId: int.parse(invoiceId)),
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
            Text("Заказ № $invoiceId",
                style: const TextStyle(fontSize: 18)),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.green),
                  onPressed: _addInvoice,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteInvoice(invoiceId),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Виджет для отображения пустого состояния с кнопкой добавления нового инвойса
  Widget _buildEmptyState() {
    return Center(
      child: ElevatedButton(
        onPressed: _addInvoice,
        child: const Text("Добавить новый контейнер"),
      ),
    );
  }
  

  @override
  Widget build(BuildContext context) {
    // Используем StreamBuilder для получения списка инвойсов из Firestore
    Widget content = StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('invoices').orderBy('invoice_no').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return _buildEmptyState();
        }
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) =>
                _buildInvoiceCard(docs[index]),
          ),
        );
      },
    );

    // Остальная навигация остается без изменений
    return LayoutBuilder(
      builder: (context, constraints) {
        bool useSideNav = constraints.maxWidth >= 600;
        Widget finalContent;
        if (_currentIndex == 0) {
          finalContent = const Center(
            child: Text(
              'Добро пожаловать в Админ Панель!',
              style: TextStyle(fontSize: 24),
            ),
          );
        } else {
          finalContent = content;
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
                Expanded(child: finalContent),
              ],
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Админ Панель'),
              centerTitle: true,
            ),
            body: finalContent,
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
