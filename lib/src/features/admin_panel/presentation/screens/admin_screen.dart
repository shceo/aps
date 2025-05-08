import 'dart:async';
import 'package:aps/l10n/app_localizations.dart';
import 'package:aps/main.dart';
import 'package:aps/src/core/constants/common_dimentions.dart';
import 'package:aps/src/features/admin_panel/presentation/screens/invoice_screen.dart';
import 'package:aps/src/features/admin_panel/presentation/widgets/timer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// import 'package:intl/intl.dart';
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

  Future<void> _addInvoice() async {
    await _createInvoice(passport: null);
  }

  Future<void> _addInvoiceWithPassport(String passport) async {
    await _createInvoice(passport: passport);
  }

  Future<void> _createInvoice({String? passport}) async {
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
        'created_at': FieldValue.serverTimestamp(),
        if (passport != null) 'passport': passport,
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _deleteInvoice(String invoiceId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(AppLocalizations.of(context).deleteConfirmationTitle),
            content: Text(
              AppLocalizations.of(context).deleteConfirmationContent,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context).cancel),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    await _firestore
                        .collection('invoices')
                        .doc(invoiceId)
                        .delete();
                  } catch (e) {
                    debugPrint(e.toString());
                  }
                  Navigator.pop(context);
                },
                child: Text(
                  AppLocalizations.of(context).delete,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildInvoiceCard(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final passport = (data['passport'] ?? '').toString().trim();
    final invoiceId = doc.id;

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
            Text(
              '${AppLocalizations.of(context).orderNo} $invoiceId',
              style: const TextStyle(fontSize: 18),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.library_add_sharp,
                    color: Colors.orange,
                  ),
                  tooltip: AppLocalizations.of(context).addInvoice,
                  onPressed: () {
                    // final passport = (data['passport'] ?? '').toString().trim();
                    if (passport.isEmpty) {
                      showDialog(
                        context: context,
                        builder:
                            (_) => AlertDialog(
                              title: Text(
                                AppLocalizations.of(context).errorTitle,
                              ),
                              content: Text(
                                AppLocalizations.of(context).noPassportError,
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(AppLocalizations.of(context).ok),
                                ),
                              ],
                            ),
                      );
                    } else {
                      _addInvoiceWithPassport(passport);
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteInvoice(invoiceId),
                  tooltip: AppLocalizations.of(context).delete,
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
      return Center(
        child: Text(AppLocalizations.of(context).noAdminsWithContainers),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children:
          adminEmails.map((email) {
            return Card(
              child: ListTile(
                title: Text(
                  '${AppLocalizations.of(context).emailPrefix} $email',
                ),
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
        child: Text(AppLocalizations.of(context).addNewContainer),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
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
      finalContent = Center(
        child: Text(
          loc.welcomeToAdminPanel,
          style: const TextStyle(fontSize: 24),
        ),
      );
    } else {
      finalContent = content;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.adminPanelTitle),
        centerTitle: true,
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            onPressed: () => _showContextMenu(context),
            icon: const Icon(Icons.language_rounded),
            tooltip: loc.changeLanguage,
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.green),
            onPressed: _addInvoice,
            tooltip: loc.addNewEmail,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 18),
            child: IstanbulClock(),
          ),
        ],
      ),
      body: finalContent,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard),
            label: loc.dashboard,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.table_chart),
            label: loc.table,
          ),
        ],
      ),
    );
  }
}

void _showContextMenu(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return Center(
        child: Material(
          type: MaterialType.transparency,
          child: Container(
            width: 250,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context).chooseLanguage,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundImage: AssetImage('assets/images/uz.png'),
                    radius: CommonDimensions.large,
                  ),
                  title: Text(AppLocalizations.of(context).uzbek),
                  onTap: () {
                    Navigator.of(context).pop();
                    MyApp.setLocale(context, const Locale('uz'));
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundImage: AssetImage('assets/images/ru.png'),
                    radius: CommonDimensions.large,
                  ),
                  title: Text(AppLocalizations.of(context).russian),
                  onTap: () {
                    Navigator.of(context).pop();
                    MyApp.setLocale(context, const Locale('ru'));
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundImage: AssetImage('assets/images/gb.png'),
                    radius: CommonDimensions.large,
                  ),
                  title: Text(AppLocalizations.of(context).english),
                  onTap: () {
                    Navigator.of(context).pop();
                    MyApp.setLocale(context, const Locale('en'));
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundImage: AssetImage('assets/images/tr.png'),
                    radius: CommonDimensions.large,
                  ),
                  title: Text(AppLocalizations.of(context).turkish),
                  onTap: () {
                    Navigator.of(context).pop();
                    MyApp.setLocale(context, const Locale('tr'));
                  },
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
