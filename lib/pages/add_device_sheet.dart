import 'package:flutter/material.dart';

class AddDeviceSheet extends StatelessWidget {
  const AddDeviceSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Pilih Device untuk Assign', style: TextStyle(fontSize: 18)),
          // TODO: List device belum assigned
        ],
      ),
    );
  }
}
