import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddBuildingPage extends StatefulWidget {
  const AddBuildingPage({super.key});

  @override
  State<AddBuildingPage> createState() => _AddBuildingPageState();
}

class _AddBuildingPageState extends State<AddBuildingPage> {
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _imageController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _saveBuilding() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await FirebaseFirestore.instance.collection('buildings').add({
        'building_name': _nameController.text,
        'location': _locationController.text,
        'url_images': _imageController.text,
        'devices': [],
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
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Bangunan')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nama Bangunan'),
            ),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Lokasi'),
            ),
            TextField(
              controller: _imageController,
              decoration: const InputDecoration(labelText: 'URL Gambar'),
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: _loading ? null : _saveBuilding,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
