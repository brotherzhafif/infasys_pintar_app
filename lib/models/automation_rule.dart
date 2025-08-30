import 'package:cloud_firestore/cloud_firestore.dart';

class AutomationRule {
  final String? id;
  final String deviceId;
  final String conditionType;
  final double threshold;
  final String action;
  final String scheduleType;
  final DateTime? startTime;
  final DateTime? endTime;
  final bool isActive;
  final String description;

  AutomationRule({
    this.id,
    required this.deviceId,
    required this.conditionType,
    required this.threshold,
    required this.action,
    required this.scheduleType,
    this.startTime,
    this.endTime,
    required this.isActive,
    required this.description,
  });

  factory AutomationRule.fromMap(Map<String, dynamic> data, String id) {
    return AutomationRule(
      id: id,
      deviceId: data['device_id'] ?? '',
      conditionType: data['condition_type'] ?? 'min',
      threshold: data['threshold']?.toDouble() ?? 0.0,
      action: data['action'] ?? 'notify',
      scheduleType: data['schedule_type'] ?? 'always',
      startTime: data['start_time']?.toDate(),
      endTime: data['end_time']?.toDate(),
      isActive: data['is_active'] ?? false,
      description: data['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'device_id': deviceId,
      'condition_type': conditionType,
      'threshold': threshold,
      'action': action,
      'schedule_type': scheduleType,
      'start_time': startTime != null ? Timestamp.fromDate(startTime!) : null,
      'end_time': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'is_active': isActive,
      'description': description,
    };
  }
}
