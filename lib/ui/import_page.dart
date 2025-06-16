import 'package:file_picker/file_picker.dart';
import 'package:first_flutter/models/contact.dart';
import 'package:first_flutter/repositories/contact_repository.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'dart:io';
import 'package:excel/excel.dart';

class ImportPage extends StatefulWidget {
  const ImportPage({super.key});

  @override
  State<ImportPage> createState() => _ImportPageState();
}

class _ImportPageState extends State<ImportPage> {
  PlatformFile? _selectedFile;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();

    if(result != null && result.files.isNotEmpty) {
      _selectedFile = result.files.first;
      setState(() {});
    } else {
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Input File"),
          content: const Text("No file selected."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  void _importFile() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file first.')),
      );
    }

    try {
      final bytes = File(_selectedFile!.path!).readAsBytesSync();
      final excel = Excel.decodeBytes(bytes);

      for (final sheet in excel.tables.keys) {
        final table = excel.tables[sheet];
        if(table == null) continue;

        for (int rowIndex = 1; rowIndex < table.maxRows; rowIndex++) {
          final row = table.rows[rowIndex];

          final name = row[0]?.value.toString().trim() ?? '';
          final phone = row[1]?.value.toString().trim() ?? '';

          if (name.isNotEmpty && phone.isNotEmpty) {
            await _saveContactToHive(name, phone);
          }
        }
        
      }
      if(!mounted) return;
      Navigator.pop(context, true);
      
    } catch (e) {
      debugPrint('Import failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to import contacts.')),
      );
    }
  }

  Future<void> _saveContactToHive(String name, String phone) async {
    final box = await Hive.openBox(ContactRepository.boxName);
    int latestId = box.get('latestId', defaultValue: 0);

    final contact = Contact(
      id: latestId + 1,
      name: name,
      phoneNumber: phone,
      isFavorite: false,
      photo: null,
    );

    await ContactRepository.addContact(contact);
    await box.put('latestId', contact.id);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import New Contact'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _pickFile, 
                icon: const Icon(Icons.upload_file),
                label: const Text("Select File")
              ),
              const SizedBox(height: 20),
              if(_selectedFile != null)
                Text("Selected file: ${_selectedFile!.name}"),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _importFile,
                child: const Text("Import File"),
              ),
            ],
          )
        ),
      )
    );
  }
}