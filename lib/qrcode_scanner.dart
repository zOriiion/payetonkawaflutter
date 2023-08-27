// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:paye_ton_kawa2/models/boxes.dart';
import 'package:paye_ton_kawa2/products_page.dart';

class QRCodeScanner extends StatefulWidget {
  const QRCodeScanner({super.key});

  @override
  State<QRCodeScanner> createState() => _QRCodeScannerState();
}

class _QRCodeScannerState extends State<QRCodeScanner> {
  MobileScannerController cameraController = MobileScannerController();
  bool canScan = true;
  late Response res;

  void _onQRCodeScanned(String? code) async {
    if (code == null || code.isEmpty || !canScan) return;
    print('test');
    canScan = false;

    bool loggedIn = await _login(code);
    if (loggedIn) {
      //final jsonResponse = jsonDecode(res.body);
      //box.put("jwt_token", jsonResponse);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProductsPage()),
      );
    }
  }

  Future<bool> _login(String qrcode) async {
    return true;
    final url = Uri.parse(
        'https://mspr-payetonkawa-95a92-revendeur-7yeohaluka-uc.a.run.app/revendeur/login');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'key': qrcode,
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      res = response;
      return true;
    } else if (response.statusCode == 401 || response.statusCode == 404) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('QR Code invalide'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                canScan = true;
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      // Error occurred, display an error message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text(
              'Une erreur est survenue, veuillez réessayer plus tard ${response.statusCode}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: const Color(0xFFc8b474),
      ),
      body: MobileScanner(
        controller: cameraController,
        onDetect: (capture) {
          _onQRCodeScanned(capture.barcodes[0].rawValue);
        },
      ),
    );
  }
}
