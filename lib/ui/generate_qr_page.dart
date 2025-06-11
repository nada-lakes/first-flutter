import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRGeneratorPage extends StatelessWidget {
  final String dataToEncode;

  const QRGeneratorPage({super.key, required this.dataToEncode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("QR Code")),
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QrImageView(
              data: dataToEncode,
              version: QrVersions.auto,
              size: 200.0,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
