// main.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'historypage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Scanner App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  String scannedResult = '';
  bool isScanning = false;
  Timer? displayTimer;

  Future<void> _storeScannedResult(String result) async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = DateTime.now().toString();
    final newEntry = '$result|$timestamp';
    final history = prefs.getStringList('scan_history') ?? [];
    history.add(newEntry);
    await prefs.setStringList('scan_history', history);
  }

  void _onQRViewCreated(QRViewController controller) {
    controller.scannedDataStream.listen((scanData) async {
      if (!isScanning) {
        isScanning = true;
        final result = scanData.code ?? '';
        setState(() {
          scannedResult = result;
        });
        await _storeScannedResult(result);
        displayTimer = Timer(const Duration(seconds: 5), () {
          setState(() {
            scannedResult = '';
          });
          isScanning = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Scanner'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          if (scannedResult.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Scanned: $scannedResult',
                style: const TextStyle(fontSize: 18, color: Colors.green),
              ),
            ),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const HistoryPage()),
                    );
                  },
                  child: const Text('View Scanned History'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    displayTimer?.cancel();
    super.dispose();
  }
}
