import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeviceDetailPage extends StatelessWidget {
  const DeviceDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final deviceId =
        ModalRoute.of(context)?.settings.arguments as String? ?? '';
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Device')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('devices')
            .doc(deviceId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Device tidak ditemukan'));
          }
          final device = snapshot.data!.data() as Map<String, dynamic>;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nama: ${device['device_name'] ?? '-'}'),
                Text('Tipe: ${device['type'] ?? '-'}'),
                Text('Kategori: ${device['category'] ?? '-'}'),
                Text(
                  'Status: ${device['status'] == true ? 'Aktif' : 'Nonaktif'}',
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/schedule',
                      arguments: deviceId,
                    );
                  },
                  child: const Text('Atur Jadwal'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
