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
    final deviceId =
        ModalRoute.of(context)?.settings.arguments as String? ?? 'device_id';
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Jadwal Device',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.schedule, color: Color(0xFF00C48C), size: 48),
                const SizedBox(height: 16),
                TextField(
                  controller: _timeController,
                  decoration: const InputDecoration(
                    labelText: 'Waktu (HH:mm)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _repeat,
                  items: ['Daily', 'Weekly', 'Monthly']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) => setState(() => _repeat = val ?? 'Daily'),
                  decoration: const InputDecoration(
                    labelText: 'Repeat',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _thresholdController,
                  decoration: const InputDecoration(
                    labelText: 'Threshold',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                if (_error != null)
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00C48C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _loading ? null : () => _saveSchedule(deviceId),
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Simpan Jadwal',
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
