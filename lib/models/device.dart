import 'package:cloud_firestore/cloud_firestore.dart';

class Device {
  final String? id;
  final String name;
  final String type;
  final String category;
  final bool status;
  final String buildingId;
  final double? lastValue;
  final DateTime lastUpdate;

  Device({
    this.id,
    required this.name,
    required this.type,
    required this.category,
    required this.status,
    required this.buildingId,
    this.lastValue,
    required this.lastUpdate,
  });

  factory Device.fromMap(Map<String, dynamic> data, String id) {
    return Device(
      id: id,
      name: data['device_name'] ?? '',
      type: data['type'] ?? '',
      category: data['category'] ?? '',
      status: data['status'] ?? false,
      buildingId: data['id_building'] ?? '',
      lastValue: data['last_value']?.toDouble(),
      lastUpdate: (data['last_update'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'device_name': name,
      'type': type,
      'category': category,
      'status': status,
      'id_building': buildingId,
      'last_value': lastValue,
      'last_update': FieldValue.serverTimestamp(),
    };
  }
}
