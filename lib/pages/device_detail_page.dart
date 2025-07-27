import 'package:flutter/material.dart';

class DeviceDetailPage extends StatelessWidget {
  const DeviceDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Device')),
      body: Center(child: Text('Data, Jadwal, Log, Kontrol Manual')),
    );
  }
}
