import 'dart:io';

import 'package:flutter/material.dart';
import '../../models/contact.dart';
import '../ui/contact_form.dart';
import '../../repositories/contact_repository.dart'; 

class ContactDetailPage extends StatefulWidget {
  final Contact contact;

  const ContactDetailPage({super.key, required this.contact});

  @override
  State<ContactDetailPage> createState() => _ContactDetailPageState();
}

class _ContactDetailPageState extends State<ContactDetailPage> {
  late Contact _contact;

  @override
  void initState() {
    super.initState();
    _contact = widget.contact;
  }

  Future<void> _editContact() async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ContactForm(contact: _contact),
      ),
    );

    // fetch ulang data agar terupdate
    if (updated == true) {
      await ContactRepository.refresh();

      final latest = ContactRepository.contacts
          .firstWhere((c) => c.id == _contact.id, orElse: () => _contact);

      setState(() {
        _contact = latest;
      });

    }
  }

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (_contact.photoPath != null && _contact.photoPath!.isNotEmpty) {
      final file = File(_contact.photoPath!);
      imageWidget = CircleAvatar(
        radius: 60,
        backgroundImage: FileImage(file),
      );
    } else {
      imageWidget = const CircleAvatar(
        radius: 60,
        child: Icon(Icons.person, size: 50),
      );
    }


    return Scaffold(
      appBar: AppBar(
        title: Text(_contact.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: imageWidget),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.person, color: Colors.blue),
                  title: Text(_contact.name, style: const TextStyle(fontSize: 20)),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.phone, color: Colors.green),
                  title: Text(_contact.phoneNumber, style: const TextStyle(fontSize: 18)),
                ),
                const Divider(),
                ListTile(
                  leading: Icon(
                    _contact.isFavorite ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                  title: Text(
                    _contact.isFavorite ? 'Favorite Contact' : 'Not Favorite',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _editContact,
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Contact'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
