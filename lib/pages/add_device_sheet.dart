import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddDeviceSheet extends StatefulWidget {
  final String buildingId;
  const AddDeviceSheet({super.key, required this.buildingId});

  @override
  State<AddDeviceSheet> createState() => _AddDeviceSheetState();
}

class _AddDeviceSheetState extends State<AddDeviceSheet> {
  String? _selectedDeviceId;
  bool _assigning = false;
  bool _showSuccess = false;

  Future<void> _assignDevice(String deviceId) async {
    setState(() => _assigning = true);
    await FirebaseFirestore.instance.collection('devices').doc(deviceId).update(
      {'id_building': widget.buildingId, 'status': true},
    );
    setState(() {
      _assigning = false;
      _showSuccess = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showSuccess) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF00C48C), size: 64),
            const SizedBox(height: 16),
            const Text(
              'Perangkat Berhasil Ditambahkan',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C48C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'DONE',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Pilih Device untuk Assign',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              return GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  final device = devices[index].data() as Map<String, dynamic>;
                  final isSelected = _selectedDeviceId == devices[index].id;
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedDeviceId = devices[index].id),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: isSelected
                          ? const Color(0xFFE6FFF6)
                          : Colors.white,
                      elevation: isSelected ? 6 : 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.devices,
                              color: isSelected
                                  ? Color(0xFF00C48C)
                                  : Colors.grey,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              device['device_name'] ?? 'Device',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              device['type'] ?? '',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C48C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _assigning || _selectedDeviceId == null
                      ? null
                      : () => _assignDevice(_selectedDeviceId!),
                  child: _assigning
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'CONTINUE',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('BACK', style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
