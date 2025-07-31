import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:infasys_pintar_app/models/sensor_data.dart';
import 'package:intl/intl.dart';

class StatistikPage extends StatelessWidget {
  const StatistikPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Statistik Sensor',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('data')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Belum ada data sensor'));
          }
          final datas = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: datas.length,
            itemBuilder: (context, index) {
              final sensorData = SensorData.fromMap(
                datas[index].data() as Map<String, dynamic>,
              );
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: Icon(
                    Icons.sensors,
                    color: _getSensorColor(sensorData.value),
                    size: 32,
                  ),
                  title: Text(
                    'Device: ${sensorData.deviceId}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nilai: ${sensorData.value.toStringAsFixed(1)}'),
                      Text(
                        DateFormat(
                          'dd MMM yyyy HH:mm',
                        ).format(sensorData.timestamp),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.notifications_active,
                      color: Color(0xFF00C48C),
                    ),
                    onPressed: () =>
                        _showAlertHistory(context, sensorData.deviceId),
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF00C48C),
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        onTap: (idx) {
          if (idx == 1) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else if (idx == 2) {
            Navigator.pushReplacementNamed(context, '/profile');
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Statistik',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }

  Color _getSensorColor(double value) {
    if (value > 80) {
      return Colors.red;
    } else if (value > 50) {
      return Colors.orange;
    } else {
      return const Color(0xFF00C48C);
    }
  }

  void _showAlertHistory(BuildContext context, String deviceId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Riwayat Alert'),
        content: Text('Belum ada riwayat alert untuk device $deviceId.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}
