import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('buildings').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Belum ada bangunan'));
          }
          final buildings = snapshot.data!.docs;
          return ListView.builder(
            itemCount: buildings.length,
            itemBuilder: (context, index) {
              final building = buildings[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(building['building_name'] ?? 'Bangunan'),
                subtitle: Text(building['location'] ?? ''),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/building_detail',
                    arguments: buildings[index].id,
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
