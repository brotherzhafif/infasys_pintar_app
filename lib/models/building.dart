import 'package:cloud_firestore/cloud_firestore.dart';

class Building {
  final String? id;
  final String name;
  final String location;
  final String url_images;
  final List<String> devices;
  final DateTime createdAt;

  Building({
    this.id,
    required this.name,
    required this.location,
    this.url_images = '',
    required this.devices,
    required this.createdAt,
  });

  factory Building.fromMap(Map<String, dynamic> data, String id) {
    return Building(
      id: id,
      name: data['building_name'] ?? '',
      location: data['location'] ?? '',
      url_images: data['url_images'] ?? '',
      devices: List<String>.from(data['devices'] ?? []),
      createdAt: (data['created_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'building_name': name,
      'location': location,
      'url_images': url_images,
      'devices': devices,
      'created_at': FieldValue.serverTimestamp(),
    };
  }
}
