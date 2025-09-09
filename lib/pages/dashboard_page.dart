import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/greenhouse_data.dart';
import '../models/pupuk_data.dart';
import '../models/control_data.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _tabIndex = 0; // 0: Data, 1: Alat
  bool _autoMode = true;

  GreenhouseData? _greenhouseData;
  PupukData? _pupukData;
  ControlData? _controlData;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _loadGreenhouseData();
    _loadPupukData();
    _loadControlData();
  }

  void _loadGreenhouseData() {
    _database.child('monitoring_greenhouse').onValue.listen((event) {
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        setState(() {
          _greenhouseData = GreenhouseData.fromMap(data);
        });
      }
    });
  }

  void _loadPupukData() {
    _database.child('monitoring_pupuk').onValue.listen((event) {
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        setState(() {
          _pupukData = PupukData.fromMap(data);
        });
      }
    });
  }

  void _loadControlData() {
    _database.child('control').onValue.listen((event) {
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        setState(() {
          _controlData = ControlData.fromMap(data);
        });
      }
    });
  }

  void _toggleControl(String controlPath, String currentValue) async {
    String newValue = currentValue == "on" ? "off" : "on";
    await _database.child('control').child(controlPath).set(newValue);
  }

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
        Text(
          'Data Greenhouse',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 8),
        if (_greenhouseData != null) ...[
          // Baris pertama - data iklim
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _dataCard(
                'Suhu Udara',
                '${_greenhouseData!.suhuUdara.toStringAsFixed(1)}°C',
                '${_greenhouseData!.jam}:${_greenhouseData!.menit.toString().padLeft(2, '0')}',
                Icons.thermostat,
              ),
              _dataCard(
                'Kelembaban',
                '${_greenhouseData!.kelembapanUdara.toStringAsFixed(1)}%',
                '',
                Icons.water_drop,
              ),
              _dataCard(
                'TDS',
                '${_greenhouseData!.tds.toInt()} ppm',
                '',
                Icons.opacity,
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Baris kedua - data tanah
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _dataCard(
                'Soil pH',
                '${_greenhouseData!.soilpH.toStringAsFixed(1)}',
                '',
                Icons.science,
              ),
              _dataCard(
                'Soil Moisture',
                '${_greenhouseData!.soilMoist.toStringAsFixed(1)}%',
                '',
                Icons.grain,
              ),
              _dataCard(
                'Soil Temp',
                '${_greenhouseData!.soilTemp.toStringAsFixed(1)}°C',
                '',
                Icons.device_thermostat,
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Baris ketiga - nutrisi tanah
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _dataCard(
                'Nitrogen (N)',
                '${_greenhouseData!.soilN.toStringAsFixed(1)} mg/L',
                '',
                Icons.eco,
              ),
              _dataCard(
                'Fosfor (P)',
                '${_greenhouseData!.soilP.toStringAsFixed(1)} mg/L',
                '',
                Icons.local_florist,
              ),
              _dataCard(
                'Kalium (K)',
                '${_greenhouseData!.soilK.toStringAsFixed(1)} mg/L',
                '',
                Icons.grass,
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Soil EC
          Row(
            children: [
              _dataCard(
                'Soil EC',
                '${_greenhouseData!.soilEC.toStringAsFixed(2)} mS/cm',
                '',
                Icons.electrical_services,
              ),
              Expanded(child: Container()), // Spacer
              Expanded(child: Container()), // Spacer
            ],
          ),
        ],
        const SizedBox(height: 24),
        Text(
          'Data Kolam Lele',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 8),
        if (_pupukData != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _dataCard(
                'NH3',
                '${_pupukData!.nh3.toStringAsFixed(1)} ppm',
                '${_pupukData!.jam}:${_pupukData!.menit.toString().padLeft(2, '0')}',
                Icons.cloud,
              ),
              _dataCard(
                'Suhu Air',
                '${_pupukData!.suhu.toStringAsFixed(1)}°C',
                '',
                Icons.thermostat,
              ),
              _dataCard(
                'pH Air',
                '${_pupukData!.pH.toStringAsFixed(1)}',
                '',
                Icons.science,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _dataCard(
                'TDS Air',
                '${_pupukData!.tds.toInt()} ppm',
                '',
                Icons.opacity,
              ),
              Expanded(child: Container()), // Spacer
              Expanded(child: Container()), // Spacer
            ],
          ),
        ],
        if (_greenhouseData == null && _pupukData == null)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'Menunggu data dari sensor...',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ),
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
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              Text(
                value,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              if (time.isNotEmpty)
                Text(
                  'Update: $time',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _controlCard(
    String title,
    bool isActive,
    IconData icon,
    VoidCallback onToggle,
  ) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(
                icon,
                color: isActive ? Color(0xFF00C48C) : Colors.grey,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              Text(
                isActive ? 'ON' : 'OFF',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Color(0xFF00C48C) : Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Switch(
                value: isActive,
                activeColor: Color(0xFF00C48C),
                onChanged: (val) => onToggle(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _durationCard(String title, int duration, String path) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  '$duration detik',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  onPressed: duration > 10
                      ? () => _updateDuration(path, duration - 10)
                      : null,
                  icon: Icon(Icons.remove),
                  color: Color(0xFF00C48C),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$duration',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                IconButton(
                  onPressed: duration < 300
                      ? () => _updateDuration(path, duration + 10)
                      : null,
                  icon: Icon(Icons.add),
                  color: Color(0xFF00C48C),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _updateDuration(String path, int newDuration) async {
    await _database.child('control').child(path).set(newDuration);
  }

  Widget _buildAlatTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Kontrol Perangkat Greenhouse',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 8),
        if (_controlData != null) ...[
          // Baris pertama - lampu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _controlCard(
                'Lampu Dalam',
                _controlData!.lampuDalam == "on",
                Icons.lightbulb,
                () => _toggleControl('lampu_dalam', _controlData!.lampuDalam),
              ),
              _controlCard(
                'Lampu Luar',
                _controlData!.lampuLuar == "on",
                Icons.lightbulb_outline,
                () => _toggleControl('lampu_luar', _controlData!.lampuLuar),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Baris kedua - pompa
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _controlCard(
                'Pompa Air',
                _controlData!.pompaAir == "on",
                Icons.water_drop,
                () => _toggleControl('pompa_air', _controlData!.pompaAir),
              ),
              _controlCard(
                'Pompa Pupuk',
                _controlData!.pompaPupuk == "on",
                Icons.eco,
                () => _toggleControl('pompa_pupuk', _controlData!.pompaPupuk),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Baris ketiga - pompa udara
          Row(
            children: [
              _controlCard(
                'Pompa Udara',
                _controlData!.pompaUdara == "on",
                Icons.air,
                () => _toggleControl('pompa_udara', _controlData!.pompaUdara),
              ),
              Expanded(child: Container()), // Spacer
            ],
          ),
          const SizedBox(height: 24),
          // Duration Settings
          Text(
            'Pengaturan Durasi (detik)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          _durationCard(
            'Pompa Air',
            _controlData!.pompaAirDuration,
            'pompa_air_duration',
          ),
          _durationCard(
            'Pompa Pupuk',
            _controlData!.pompaPupukDuration,
            'pompa_pupuk_duration',
          ),
          _durationCard(
            'Pompa Udara',
            _controlData!.pompaUdaraDuration,
            'pompa_udara_duration',
          ),
        ],
        if (_controlData == null)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'Menunggu data kontrol...',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ),
          ),
      ],
    );
  }
}
