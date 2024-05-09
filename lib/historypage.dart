// history_page.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({Key? key}) : super(key: key);

  Future<List<Map<String, String>>> _loadScannedHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('scan_history') ?? [];
    return history.map((entry) {
      final parts = entry.split('|');
      return {'value': parts[0], 'timestamp': parts[1]};
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scanned History')),
      body: FutureBuilder<List<Map<String, String>>>(
        future: _loadScannedHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading history'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No history found'));
          }

          final history = snapshot.data!;
          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final entry = history[index];
              return ListTile(
                title: Text(entry['value']!),
                subtitle: Text('Scanned at: ${entry['timestamp']}'),
              );
            },
          );
        },
      ),
    );
  }
}
