import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:infasys_pintar_app/models/device.dart';
import 'package:infasys_pintar_app/pages/add_device_sheet.dart';

class BuildingDetailPage extends StatelessWidget {
  const BuildingDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final buildingId =
        ModalRoute.of(context)?.settings.arguments as String? ?? '';
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Detail Bangunan',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: Color(0xFF00C48C)),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (ctx) => AddDeviceSheet(buildingId: buildingId),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 160,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              color: Colors.grey[200],
            ),
            child: const Icon(
              Icons.home,
              size: 80,
              color: Colors.grey,
            ), // TODO: fetch building image
          ),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
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
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.4,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    final device = Device.fromMap(
                      devices[index].data() as Map<String, dynamic>,
                      devices[index].id,
                    );
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/device_detail',
                            arguments: devices[index].id,
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    device.type == 'Actuator'
                                        ? Icons.power_settings_new
                                        : Icons.sensors,
                                    color: device.status
                                        ? const Color(0xFF00C48C)
                                        : Colors.grey,
                                    size: 32,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      device.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Status: ${device.status ? 'Aktif' : 'Nonaktif'}',
                                style: TextStyle(
                                  color: device.status
                                      ? Color(0xFF00C48C)
                                      : Colors.red,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Nilai: ${device.lastValue?.toStringAsFixed(1) ?? '-'}',
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Switch(
                                    value: device.status,
                                    activeColor: const Color(0xFF00C48C),
                                    onChanged: (val) {
                                      // TODO: update device status in Firestore
                                    },
                                  ),
                                  const Spacer(),
                                  Icon(Icons.settings, color: Colors.grey[400]),
                                ],
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
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF00C48C),
        unselectedItemColor: Colors.grey,
        currentIndex: 1,
        onTap: (idx) {
          if (idx == 0) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else if (idx == 2) {
            Navigator.pushReplacementNamed(context, '/profile');
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Bangunan'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
