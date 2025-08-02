import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:infasys_pintar_app/models/building.dart';

class BuildingPage extends StatelessWidget {
  const BuildingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Bangunan',
          style: TextStyle(
            color: Color(0xFF2D3748),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF8FFFE), Color(0xFFE8F8F5)],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8FFFE), Color(0xFFE8F8F5)],
          ),
        ),
        child: SafeArea(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('buildings').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00C48C)),
                  ),
                );
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    'Belum ada bangunan',
                    style: TextStyle(
                      color: Color(0xFF2D3748),
                      fontSize: 16,
                    ),
                  ),
                );
              }
              final buildings = snapshot.data!.docs;
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: buildings.length,
                itemBuilder: (context, index) {
                  final building = Building.fromMap(
                    buildings[index].data() as Map<String, dynamic>,
                    buildings[index].id,
                  );
                  return _buildBuildingCard(context, building, buildings[index].id);
                },
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
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
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00C48C),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.pushNamed(context, '/add_building');
        },
      ),
    );
  }

  Widget _buildBuildingCard(BuildContext context, Building building, String buildingId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: building.url_images.isNotEmpty
                  ? _buildBackgroundImage(building.url_images)
                  : Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF00C48C), Color(0xFF00A876)],
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.home_outlined,
                          size: 60,
                          color: Colors.white60,
                        ),
                      ),
                    ),
            ),
            // Gradient Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),
            // Content
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/building_detail',
                      arguments: buildingId,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          building.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                building.location,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundImage(String imageData) {
    try {
      // Check if it's a base64 string
      if (imageData.startsWith('data:image') || !imageData.startsWith('http')) {
        // Remove data:image/jpeg;base64, prefix if present
        String base64String = imageData;
        if (imageData.contains(',')) {
          base64String = imageData.split(',')[1];
        }
        
        // Decode base64 to bytes
        final bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF00C48C), Color(0xFF00A876)],
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.home_outlined,
                  size: 60,
                  color: Colors.white60,
                ),
              ),
            );
          },
        );
      } else {
        // It's a URL, use network image
        return Image.network(
          imageData,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF00C48C), Color(0xFF00A876)],
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.home_outlined,
                  size: 60,
                  color: Colors.white60,
                ),
              ),
            );
          },
        );
      }
    } catch (e) {
      // If there's any error, show default background
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF00C48C), Color(0xFF00A876)],
          ),
        ),
        child: const Center(
          child: Icon(
            Icons.home_outlined,
            size: 60,
            color: Colors.white60,
          ),
        ),
      );
    }
  }

}