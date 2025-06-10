import 'package:first_flutter/repositories/contact_repository.dart';
import 'package:first_flutter/ui/contact_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../../models/contact.dart';
import '../../widgets/contact_list_item.dart';
import 'contact_form.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Contact> contacts = [];
  List<Contact> filteredContacts = [];
  bool _showOnlyFavorites = false;
  bool _isAsc = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadContacts();
    _searchController.addListener(_filterContacts);
  }

  Future<void> _loadContacts() async {
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
    setState(() {
      if (_isAsc) {
        contacts.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
      } else {
        contacts.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      }
      _isAsc = !_isAsc;
    });
  }

  void _showFavoriteContacts() {
    _showOnlyFavorites = !_showOnlyFavorites;
    final query = _searchController.text.toLowerCase();
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
    _loadContacts(); // reload data
  }

  void _updateFavoriteContact(int id, bool isFavorite) async {
    final newStatus = !isFavorite;
    await ContactRepository.updateFavoriteContact(id,newStatus);
    _loadContacts(); // reload data
  }

  void navigateToAddContactPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ContactForm(),
      ),
    ).then((shouldReload) {
      if (shouldReload == true) {
        _loadContacts();
      }
    });
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
                  onPressed: _loadContacts, 
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.separated(
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
                          _loadContacts();
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
            onTap: () {
              // your action
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.file_download),
            label: 'Export Contact',
            onTap: () {
              // your action
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
