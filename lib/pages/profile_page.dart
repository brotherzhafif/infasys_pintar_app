import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<Map<String, dynamic>?> _getUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists) {
          return doc.data() as Map<String, dynamic>;
        }
      } catch (e) {
        print('Error fetching user data: $e');
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF8FFFE), Color(0xFFE8F8F5)],
            ),
          ),
        ),
        title: const Text(
          'Profil User',
          style: TextStyle(
            color: Color(0xFF2D3748),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8FFFE), Color(0xFFE8F8F5)],
          ),
        ),
        child: Stack(
          children: [
            // Floating decorative elements
            Positioned(
              top: 100,
              right: 50,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF00C48C).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              top: 200,
              left: 30,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF00A876).withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: 150,
              right: 80,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF00C48C).withOpacity(0.06),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            FutureBuilder<Map<String, dynamic>?>(
              future: _getUserData(),
              builder: (context, snapshot) {
                return Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (snapshot.connectionState == ConnectionState.waiting)
                                  const Center(
                                    child: CircularProgressIndicator(
                                      color: Color(0xFF00C48C),
                                    ),
                                  )
                                else
                                  Row(
                                    children: [
                                      Container(
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [Color(0xFF00C48C), Color(0xFF00A876)],
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const CircleAvatar(
                                          radius: 32,
                                          backgroundColor: Colors.transparent,
                                          child: Icon(Icons.person, color: Colors.white, size: 36),
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              snapshot.data?['username'] ?? 'Pengguna',
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF2D3748),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              user?.email ?? '-',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w400,
                                                color: Color(0xFF718096),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'User ID: ${user?.uid ?? '-'}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color: Color(0xFF718096),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                const SizedBox(height: 32),
                                Container(
                                  width: double.infinity,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF00C48C), Color(0xFF00A876)],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF00C48C).withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(16),
                                      onTap: () async {
                                        await FirebaseAuth.instance.signOut();
                                        if (context.mounted) {
                                          Navigator.pushReplacementNamed(context, '/login');
                                        }
                                      },
                                      child: const Center(
                                        child: Text(
                                          'Logout',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            ],
          ),
        ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
        ),
        child: BottomNavigationBar(
          // backgroundColor: Colors.transparent,
          selectedItemColor: const Color(0xFF00C48C),
          unselectedItemColor: Colors.grey,
          currentIndex: 2,
          onTap: (idx) {
            if (idx == 0) {
              Navigator.pushReplacementNamed(context, '/dashboard');
            } else if (idx == 1) {
              Navigator.pushReplacementNamed(context, '/building');
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
    );
  }
}
