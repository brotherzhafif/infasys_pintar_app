import 'package:flutter/material.dart';
import 'dart:ui';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _tabIndex = 0; // 0: Data, 1: Alat
  bool _autoMode = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
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
        title: _buildTabSwitcher(),
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
        child: SafeArea(
          child: _tabIndex == 0 ? _buildDataTab() : _buildAlatTab(),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF00C48C),
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        onTap: (idx) {
          if (idx == 1) {
            Navigator.pushReplacementNamed(context, '/building');
          } else if (idx == 2) {
            Navigator.pushReplacementNamed(context, '/profile');
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Bangunan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF).withOpacity(0.9),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [_tabButton('Data', 0), _tabButton('Alat', 1)],
      ),
    );
  }

  Widget _tabButton(String label, int idx) {
    return GestureDetector(
      onTap: () => setState(() => _tabIndex = idx),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: _tabIndex == idx
              ? const LinearGradient(
                  colors: [Color(0xFF00C48C), Color(0xFF00A876)],
                )
              : null,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: _tabIndex == idx ? Colors.white : const Color(0xFF2D3748),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            if (label == 'Alat')
              Container(
                margin: const EdgeInsets.only(left: 6),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _tabIndex == idx ? Colors.white : const Color(0xFF00C48C),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '20',
                  style: TextStyle(
                    color: _tabIndex == idx ? const Color(0xFF00C48C) : Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ), // TODO: dynamic
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTab() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Mode System Section with Glassmorphism
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00C48C).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.settings_remote,
                      color: Color(0xFF00C48C),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Mode Otomatis',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                  ),
                  Switch(
                    value: _autoMode,
                    activeColor: const Color(0xFF00C48C),
                    activeTrackColor: const Color(0xFF00C48C).withOpacity(0.3),
                    inactiveThumbColor: const Color(0xFF718096),
                    inactiveTrackColor: const Color(0xFF718096).withOpacity(0.3),
                    onChanged: (val) => setState(() => _autoMode = val),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        
        // Data Greenhouse Section
        Text(
          'Data Greenhouse',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1,
          children: [
            _modernDataCard('Irigasi Tetes', '3 Kali', 'Terakhir Disiram 10.00', Icons.water_drop),
            _modernDataCard('Nilai pH', '7 pH', 'Terakhir Diukur 10.00', Icons.science),
            _modernDataCard('Nilai Suhu', '24°C', 'Terakhir Diukur 10.00', Icons.thermostat),
            _modernDataCard('Nilai Kelembaban', '25%', 'Terakhir Diukur 10.00', Icons.grain),
          ],
        ),
        const SizedBox(height: 32),
        
        // Data Kolam Lele Section
        Text(
          'Data Kolam Lele',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1,
          children: [
            _modernDataCard('Nilai Nutrisi', 'Bagus', 'Terakhir Diukur 10.00', Icons.eco),
            _modernDataCard('Nilai pH', '7 pH', 'Terakhir Diukur 10.00', Icons.science),
          ],
        ),
      ],
    );
  }

  Widget _modernDataCard(String title, String value, String subtitle, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF00C48C).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: const Color(0xFF00C48C),
                size: 24,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Color(0xFF718096),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlatTab() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Perangkat Greenhouse Section
        Text(
          'Perangkat Greenhouse',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.9,
          children: [
            _modernAlatCard('Irigasi Tetes', 4, true, Icons.water_drop),
            _modernAlatCard('Sensor pH', 9, false, Icons.science),
            _modernAlatCard('Sensor Suhu', 4, true, Icons.thermostat),
            _modernAlatCard('Sensor Moist', 4, false, Icons.grain),
          ],
        ),
        const SizedBox(height: 32),
        
        // Perangkat Kolam Lele Section
        Text(
          'Perangkat Kolam Lele',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.9,
          children: [
            _modernAlatCard('Irigasi Tetes', 3, true, Icons.water_drop),
            _modernAlatCard('Sensor pH', 3, false, Icons.science),
            _modernAlatCard('Sensor Nutrisi', 3, true, Icons.eco),
          ],
        ),
      ],
    );
  }

  Widget _modernAlatCard(String title, int count, bool isActive, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF00C48C).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: const Color(0xFF00C48C),
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$count device',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 6),
            Switch(
              value: isActive,
              activeColor: const Color(0xFF00C48C),
              activeTrackColor: const Color(0xFF00C48C).withOpacity(0.3),
              inactiveThumbColor: const Color(0xFF718096),
              inactiveTrackColor: const Color(0xFF718096).withOpacity(0.3),
              onChanged: (val) {}, // TODO: update status
            ),
          ],
        ),
      ),
    );
  }
}
