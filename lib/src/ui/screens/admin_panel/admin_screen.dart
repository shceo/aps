import 'package:aps/src/ui/screens/admin_panel/invoice_scree.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminScreen extends StatefulWidget {
  static String? currentAdminPhone;
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _currentIndex = 1;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _userPhone;
  bool _isSuperAdmin = false;

  @override
  void initState() {
    super.initState();
    _userPhone = AdminScreen.currentAdminPhone;
    _isSuperAdmin = _userPhone == '998996666666';
  }

  Future<void> _addInvoice() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('invoices').get();
      int newId = 1;
      if (snapshot.docs.isNotEmpty) {
        newId =
            snapshot.docs
                .map((doc) => int.tryParse(doc.id) ?? 0)
                .fold(0, (prev, elem) => elem > prev ? elem : prev) +
            1;
      }
      String newIdStr = newId.toString();
      await _firestore.collection('invoices').doc(newIdStr).set({
        'invoice_no': newId,
        'created_by': _userPhone,
      });
    } catch (e) {
      debugPrint("Ошибка при добавлении инвойса: $e");
    }
  }

  void _deleteInvoice(String invoiceId) {
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
                child: const Text(
                  "Удалить",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildInvoiceCard(DocumentSnapshot doc) {
    String invoiceId = doc.id;
    return GestureDetector(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      InvoiceFormScreen(invoiceId: int.parse(invoiceId)),
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
    Widget content = StreamBuilder<QuerySnapshot>(
      stream:
          _firestore.collection('invoices').orderBy('invoice_no').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final allDocs = snapshot.data?.docs ?? [];
       final visibleDocs = _isSuperAdmin
  ? allDocs
  : allDocs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data['created_by'] == _userPhone;
    }).toList();


        if (visibleDocs.isEmpty) return _buildEmptyState();

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
            itemCount: visibleDocs.length,
            itemBuilder:
                (context, index) => _buildInvoiceCard(visibleDocs[index]),
          ),
        );
      },
    );

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
    bool useSideNav = MediaQuery.of(context).size.width >= 600;
    if (useSideNav) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected:
                  (index) => setState(() => _currentIndex = index),
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
        appBar: AppBar(title: const Text('Админ Панель'), centerTitle: true),
        body: finalContent,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
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
  }
}
