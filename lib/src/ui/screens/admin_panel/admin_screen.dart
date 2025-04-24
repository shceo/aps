import 'package:aps/src/ui/screens/admin_panel/invoice_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminScreen extends StatefulWidget {
  static String? currentAdminEmail;
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _currentIndex = 1;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _userEmail;
  bool _isSuperAdmin = false;
  String? _selectedAdminEmail;

  @override
  void initState() {
    super.initState();
    _userEmail = AdminScreen.currentAdminEmail;
    _isSuperAdmin = _userEmail == 'apsexpress@gmail.com';
  }

  DateTime get _nowIstanbul {
    // Istanbul is UTC+3 year-round
    return DateTime.now().toUtc().add(const Duration(hours: 3));
  }

  String _formatIstanbulTime() {
    return DateFormat('dd.MM.yyyy | HH:mm').format(_nowIstanbul);
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
        'created_by': _userEmail,
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

  Widget _buildAdminList(List<DocumentSnapshot> allDocs) {
    final Set<String?> adminEmails =
        allDocs
            .map(
              (doc) =>
                  (doc.data() as Map<String, dynamic>)['created_by']
                      ?.toString(),
            )
            .where((email) => email != null)
            .toSet();

    if (adminEmails.isEmpty) {
      return const Center(child: Text("Нет админов с контейнерами"));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children:
          adminEmails.map((email) {
            return Card(
              child: ListTile(
                title: Text("📧 $email"),
                onTap: () => setState(() => _selectedAdminEmail = email),
              ),
            );
          }).toList(),
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

        if (_isSuperAdmin && _selectedAdminEmail == null) {
          return _buildAdminList(allDocs);
        }

        final visibleDocs =
            allDocs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final createdBy = data['created_by'];
              if (_isSuperAdmin && _selectedAdminEmail != null) {
                return createdBy == _selectedAdminEmail;
              } else {
                return createdBy == _userEmail;
              }
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Админ Панель'),
        centerTitle: true,
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addInvoice,
            tooltip: 'Добавить новую почту',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('Время сервера', style: TextStyle(fontSize: 12)),
                Text(
                  _formatIstanbulTime(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: finalContent,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Панель'),
          BottomNavigationBarItem(
            icon: Icon(Icons.table_chart),
            label: 'Таблица',
          ),
        ],
      ),
    );
  }
}
