import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddDeviceSheet extends StatelessWidget {
  final String buildingId;
  const AddDeviceSheet({super.key, required this.buildingId});

  Future<void> _assignDevice(BuildContext context, String deviceId) async {
    await FirebaseFirestore.instance.collection('devices').doc(deviceId).update(
      {'id_building': buildingId, 'status': true},
    );
    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Pilih Device untuk Assign',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('devices')
                .where('id_building', isEqualTo: '')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Text('Tidak ada device yang belum assigned');
              }
              final devices = snapshot.data!.docs;
              return ListView.builder(
                shrinkWrap: true,
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  final device = devices[index].data() as Map<String, dynamic>;
                  return ListTile(
                    title: Text(device['device_name'] ?? 'Device'),
                    subtitle: Text(device['type'] ?? ''),
                    trailing: ElevatedButton(
                      onPressed: () =>
                          _assignDevice(context, devices[index].id),
                      child: const Text('Assign'),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
