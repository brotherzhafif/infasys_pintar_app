import 'package:flutter/material.dart';

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTabSwitcher(),
            const SizedBox(width: 16),
            _tabIndex == 0
                ? Text(
                    'Data',
                    style: TextStyle(
                      color: Color(0xFF00C48C),
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : Text(
                    'Alat',
                    style: TextStyle(
                      color: Color(0xFF00C48C),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ],
        ),
        centerTitle: true,
      ),
      body: _tabIndex == 0 ? _buildDataTab() : _buildAlatTab(),
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Bangunan'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
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
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: _tabIndex == idx
              ? const Color(0xFF00C48C)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: _tabIndex == idx ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (label == 'Alat')
              Container(
                margin: const EdgeInsets.only(left: 6),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '20',
                  style: TextStyle(color: Color(0xFF00C48C), fontSize: 12),
                ), // TODO: dynamic
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
          child: ListTile(
            leading: Icon(Icons.settings_remote, color: Color(0xFF00C48C)),
            title: Text('Mode Otomatis'),
            trailing: Switch(
              value: _autoMode,
              activeColor: Color(0xFF00C48C),
              onChanged: (val) => setState(() => _autoMode = val),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Data Greenhouse',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _dataCard('Irigasi Tetes', '3 kali', '10.00', Icons.water_drop),
            _dataCard('Nilai pH', '7 pH', '', Icons.science),
            _dataCard('Nilai Suhu', '24°C', '', Icons.thermostat),
            _dataCard('Nilai Kelembaban', '25%', '', Icons.grain),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Data Kolam Lele',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _dataCard('Nilai Nutrisi', 'Bagus', '', Icons.eco),
            _dataCard('Nilai pH', '7 pH', '', Icons.science),
          ],
        ),
      ],
    );
  }

  Widget _dataCard(String title, String value, String time, IconData icon) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: Color(0xFF00C48C), size: 32),
              const SizedBox(height: 8),
              Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
              Text(value, style: TextStyle(fontSize: 16)),
              if (time.isNotEmpty)
                Text(
                  'Terakhir: $time',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlatTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Perangkat Greenhouse',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _alatCard('Irigasi Tetes', 4, true, Icons.water_drop),
            _alatCard('Sensor pH', 9, false, Icons.science),
            _alatCard('Sensor Suhu', 4, true, Icons.thermostat),
            _alatCard('Sensor Moist', 4, false, Icons.grain),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Perangkat Kolam Lele',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _alatCard('Irigasi Tetes', 3, true, Icons.water_drop),
            _alatCard('Sensor pH', 3, false, Icons.science),
            _alatCard('Sensor Nutrisi', 3, true, Icons.eco),
          ],
        ),
      ],
    );
  }

  Widget _alatCard(String title, int count, bool isActive, IconData icon) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: Color(0xFF00C48C), size: 32),
              const SizedBox(height: 8),
              Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
              Text('$count device', style: TextStyle(fontSize: 16)),
              Switch(
                value: isActive,
                activeColor: Color(0xFF00C48C),
                onChanged: (val) {}, // TODO: update status
              ),
            ],
          ),
        ),
      ),
    );
  }
}
