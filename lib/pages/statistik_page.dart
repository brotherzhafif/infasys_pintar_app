import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StatistikPage extends StatelessWidget {
  const StatistikPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistik Sensor')),
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
            itemCount: datas.length,
            itemBuilder: (context, index) {
              final data = datas[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text('Device: ${data['id_device'] ?? '-'}'),
                subtitle: Text('Value: ${data['value'] ?? '-'}'),
                trailing: Text('${data['timestamp'] ?? '-'}'),
              );
            },
          );
        },
      ),
    );
  }
}
