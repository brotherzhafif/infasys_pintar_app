import 'package:flutter/material.dart';

class StatistikPage extends StatelessWidget {
  const StatistikPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistik Sensor')),
      body: Center(child: Text('Grafik Suhu, pH, Kelembaban')),
    );
  }
}
