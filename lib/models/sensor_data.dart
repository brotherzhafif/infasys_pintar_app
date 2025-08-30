import 'package:cloud_firestore/cloud_firestore.dart';

class SensorData {
  final String deviceId;
  final double value;
  final DateTime timestamp;
  final String type; // e.g. suhu, ph, actuator
  final bool abnormal; // for notification use case
  final List<double>? history; // for statistics

  SensorData({
    required this.deviceId,
    required this.value,
    required this.timestamp,
    this.type = '',
    this.abnormal = false,
    this.history,
  });

  factory SensorData.fromMap(Map<String, dynamic> data) {
    return SensorData(
      deviceId: data['id_device'] ?? '',
      value: data['value']?.toDouble() ?? 0.0,
      timestamp: (data['timestamp'] is Timestamp)
          ? (data['timestamp'] as Timestamp).toDate()
          : DateTime.tryParse(data['timestamp']?.toString() ?? '') ??
                DateTime.now(),
      type: data['type'] ?? '',
      abnormal: data['abnormal'] ?? false,
      history: (data['history'] is List)
          ? List<double>.from(data['history'].map((e) => e.toDouble()))
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_device': deviceId,
      'value': value,
      'timestamp': FieldValue.serverTimestamp(),
      'type': type,
      'abnormal': abnormal,
      if (history != null) 'history': history,
    };
  }
}
