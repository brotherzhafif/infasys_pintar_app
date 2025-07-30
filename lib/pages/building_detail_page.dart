import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BuildingDetailPage extends StatelessWidget {
  const BuildingDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final buildingId =
        ModalRoute.of(context)?.settings.arguments as String? ?? '';
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Bangunan')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('devices')
            .where('id_building', isEqualTo: buildingId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Belum ada device'));
          }
          final devices = snapshot.data!.docs;
          return ListView.builder(
            itemCount: devices.length,
            itemBuilder: (context, index) {
              final device = devices[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(device['device_name'] ?? 'Device'),
                subtitle: Text(device['type'] ?? ''),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/device_detail',
                    arguments: devices[index].id,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
