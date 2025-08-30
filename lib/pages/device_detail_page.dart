import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:infasys_pintar_app/models/device.dart';
import 'package:intl/intl.dart';

class DeviceDetailPage extends StatelessWidget {
  const DeviceDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final deviceId =
        ModalRoute.of(context)?.settings.arguments as String? ?? '';
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Detail Device',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
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
          final device = Device.fromMap(
            snapshot.data!.data() as Map<String, dynamic>,
            snapshot.data!.id,
          );
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: device.status
                            ? const Color(0xFF00C48C)
                            : Colors.grey,
                        child: Icon(
                          device.category == 'sensor'
                              ? Icons.sensors
                              : Icons.power_settings_new,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              device.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tipe: ${device.type}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            Text(
                              'Kategori: ${device.category}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: device.status,
                        activeColor: const Color(0xFF00C48C),
                        onChanged: (val) {
                          // TODO: update device status in Firestore
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Status: ${device.status ? 'Aktif' : 'Nonaktif'}',
                    style: TextStyle(
                      color: device.status ? Color(0xFF00C48C) : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Nilai Terakhir: ${device.lastValue?.toStringAsFixed(1) ?? '-'}',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Update Terakhir: ${DateFormat('HH:mm').format(device.lastUpdate)}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00C48C),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/schedule',
                              arguments: deviceId,
                            );
                          },
                          child: const Text(
                            'Atur Jadwal',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Kembali'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF00C48C),
        unselectedItemColor: Colors.grey,
        currentIndex: 1,
        onTap: (idx) {
          if (idx == 0) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else if (idx == 2) {
            Navigator.pushReplacementNamed(context, '/profile');
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Bangunan'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
