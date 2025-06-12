import 'dart:convert';

import 'package:first_flutter/repositories/contact_repository.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:hive/hive.dart';
import 'package:first_flutter/models/contact.dart';

class QRScanPage extends StatefulWidget {
  const QRScanPage({super.key});

  @override
  State<QRScanPage> createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? qrText;
  bool _isProcessing = false;

  Future<void> _saveContact(String? scanData) async {
    if (_isProcessing || scanData == null) return; // Hindari double scan
    _isProcessing = true;

    try {
      final decodedData = jsonDecode(scanData);
      final String name = decodedData['name'];
      final String phone = decodedData['phone'];

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

      if (!mounted) return;

      Navigator.pop(context, true);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Berhasil"),
          content: const Text("Kontak berhasil ditambahkan."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Tutup"),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint('Gagal decode atau simpan kontak: $e');
      setState(() {
        qrText = scanData;
      });
      _isProcessing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code')),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: (QRViewController c) {
                controller = c;
                c.scannedDataStream.listen((scanData) {
                  _saveContact(scanData.code);
                });
              },
              overlay: QrScannerOverlayShape(
                borderColor: Colors.blue,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 8,
                cutOutSize: 300,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                qrText ?? 'Scan a code',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          )
        ],
      ),
    );
  }
}
