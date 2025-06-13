import 'dart:io';
import 'package:excel/excel.dart';
import 'package:first_flutter/repositories/contact_repository.dart';
import 'package:first_flutter/ui/contact_detail.dart';
import 'package:first_flutter/ui/import_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../models/contact.dart';
import '../../widgets/contact_list_item.dart';
import 'contact_form.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  List<Contact> contacts = [];
  List<Contact> filteredContacts = [];
  static bool _showOnlyFavorites = false;
  static bool _isAsc = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadContacts();
    _searchController.addListener(_filterContacts);
  }

  Future<void> loadContacts() async {
    if (!mounted) return;

    setState(() {
      contacts = ContactRepository.contacts;
      filteredContacts = contacts;
    });
  }

  void _filterContacts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredContacts = contacts.where((contact) { 
        return contact.name.toLowerCase().contains(query) || contact.phoneNumber.contains(query);
      }).toList();
    });
  }

  void _toggleSort() {
    final sortedData = [...contacts];
    sortedData.sort((a, b) {
      final nameA = a.name.toLowerCase();
      final nameB = b.name.toLowerCase();
      return _isAsc ? nameA.compareTo(nameB) : nameB.compareTo(nameA);
    });

    setState(() {
      filteredContacts = sortedData;
      _isAsc = !_isAsc;
    });
  }

  void _showFavoriteContacts() {
    final query = _searchController.text.toLowerCase();
    _showOnlyFavorites = !_showOnlyFavorites;

    setState(() {
      filteredContacts = contacts.where((contact) {
        final matchesFavorite = !_showOnlyFavorites || contact.isFavorite;
        final matchesQuery = contact.name.toLowerCase().contains(query) || contact.phoneNumber.contains(query);
        return matchesFavorite && matchesQuery;
      }).toList();
    });
  }

  void _onDelete(int id) async {
    await ContactRepository.deleteContact(id);
    loadContacts();
  }

  void _updateFavoriteContact(int id, bool isFavorite) async {
    final newStatus = !isFavorite;
    await ContactRepository.updateFavoriteContact(id,newStatus);
    loadContacts();
  }

  void navigateToAddContactPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ContactForm(),
      ),
    ).then((shouldReload) {
      if (shouldReload == true) {
        loadContacts();
      }
    });
  }

  void navigateToImportPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ImportPage(),
      ),
    ).then((shouldReload) {
      if (shouldReload == true) {
        loadContacts();
      }
    });
  }

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      if (await Permission.manageExternalStorage.isGranted) {
        return true;
      } else {
        final status = await Permission.manageExternalStorage.request();
        return status.isGranted;
      }
    }
    return true; // untuk iOS dan lainnya, anggap granted
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  Future<void> _exportData() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Center(child: CircularProgressIndicator()),
      ),
    );

    try {
      // izin penyimpanan untuk Android
      final granted = await _requestStoragePermission();
      if (!granted) {
        if (!mounted) return;
        Navigator.of(context).pop();
        _showMessage("Akses penyimpanan ditolak. Silakan aktifkan permission di Pengaturan.");
        return;
      }

      final contacts = await ContactRepository.getAllContact();

      final excel = Excel.createExcel();
      final sheet = excel['Contacts'];
      
      sheet.appendRow(['Name', 'Phone Number', 'Favorite']);

      for (var contact in contacts) {
        sheet.appendRow([
          contact.name,
          contact.phoneNumber,
          contact.isFavorite ? 'Yes' : 'No',
        ]);
      }

      final bytes = excel.encode();
      if (bytes == null) {
        if (!mounted) return;
        Navigator.of(context).pop();
        _showMessage("Gagal membuat file Excel.");
        return;
      }

      // Tentukan path ke folder Download
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      // Buat folder jika belum ada
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      
      // Simpan file
      final now = DateTime.now();
      final formattedDate = '${now.year}-${_twoDigits(now.month)}-${_twoDigits(now.day)}_${_twoDigits(now.hour)}-${_twoDigits(now.minute)}-${_twoDigits(now.second)}';
      final filePath = '${directory.path}/contacts_export_$formattedDate.xlsx';
      final file = File(filePath);
      await file.writeAsBytes(bytes, flush: true);

      if (!mounted) return;
      Navigator.of(context).pop();

      _showMessage("Kontak berhasil diekspor ke:\n$filePath");
    } catch (e) {
      Navigator.of(context).pop();
      _showMessage("Terjadi kesalahan saat ekspor:\n${e.toString()}");
    }
  }

  void _showMessage(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Ekspor Kontak"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).colorScheme.surface
          : Theme.of(context).colorScheme.primary,
          title: Text(
        widget.title,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'search',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder()
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.sort_by_alpha),
                  tooltip: 'Sort Data',
                  onPressed: _toggleSort, 
                ),
                IconButton(
                  icon: Icon(_showOnlyFavorites ? Icons.favorite : Icons.favorite_border),
                  color: _showOnlyFavorites ? Colors.blue : Colors.blue,
                  tooltip: 'Favorite',
                  onPressed: _showFavoriteContacts, 
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: loadContacts, 
                ),
              ],
            ),
          ),

          Expanded(
            child: filteredContacts.isEmpty
              ? const Center(
                  child: Text(
                    'Empty Data',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.separated(
              itemCount: filteredContacts.length,
              itemBuilder: (context, index) {
                final contact = filteredContacts[index];

                return Dismissible(
                  key: Key(contact.id.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Confirm Delete"),
                        content: Text("Are you sure you want to delete ${contact.name}?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text("Delete", style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (direction) => _onDelete(contact.id),
                  child: ContactListItem(
                    contact: contact,
                    updateFavoriteContact: _updateFavoriteContact,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ContactDetailPage(contact: contact),
                        ),
                      ).then((shouldReload) {
                          loadContacts();
                      });
                    },
                  ),
                );
              },
              separatorBuilder: (context, index) => const Divider(),
            ),
          ),
        ],
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : Colors.blue,
        foregroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.blue
          : Colors.white,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.person_add),
            label: 'Add Contact',
            onTap: () => navigateToAddContactPage(context),
          ),
          SpeedDialChild(
            child: const Icon(Icons.input),
            label: 'Import Contact',
            onTap: () => navigateToImportPage(context)
          ),
          SpeedDialChild(
            child: const Icon(Icons.file_download),
            label: 'Export Contact',
            onTap: () {
              _exportData();
            },
          ),
        ],
      ),
    );
  }

  /// `dispose()` adalah method lifecycle dari `StatefulWidget`
  /// yang digunakan untuk membersihkan resource saat widget
  /// dihapus dari widget tree (misalnya ketika berpindah halaman
  /// atau widget tidak digunakan lagi).
  ///
  /// Di sini, kita memanggil `dispose()` pada `_searchController`
  /// untuk menghindari memory leak dan memastikan listener yang
  /// terkait juga dibersihkan dengan benar.

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

}
