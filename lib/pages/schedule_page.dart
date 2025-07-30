import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final _timeController = TextEditingController();
  final _thresholdController = TextEditingController();
  String _repeat = 'Daily';
  bool _loading = false;
  String? _error;

  Future<void> _saveSchedule(String deviceId) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await FirebaseFirestore.instance.collection('schedules').add({
        'id_device': deviceId,
        'time': _timeController.text,
        'repeat': _repeat,
        'threshold': double.tryParse(_thresholdController.text) ?? 0.0,
        'created_at': DateTime.now(),
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Contoh deviceId, seharusnya didapat dari navigasi/parameter
    final deviceId =
        ModalRoute.of(context)?.settings.arguments as String? ?? 'device_id';
    return Scaffold(
      appBar: AppBar(title: const Text('Jadwal Device')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _timeController,
              decoration: const InputDecoration(labelText: 'Waktu (HH:mm)'),
            ),
            DropdownButtonFormField<String>(
              value: _repeat,
              items: [
                'Daily',
                'Weekly',
                'Monthly',
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => setState(() => _repeat = val ?? 'Daily'),
              decoration: const InputDecoration(labelText: 'Repeat'),
            ),
            TextField(
              controller: _thresholdController,
              decoration: const InputDecoration(labelText: 'Threshold'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: _loading ? null : () => _saveSchedule(deviceId),
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Simpan Jadwal'),
            ),
          ],
        ),
      ),
    );
  }
}
