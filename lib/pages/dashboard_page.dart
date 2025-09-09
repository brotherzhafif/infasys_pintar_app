import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/greenhouse_data.dart';
import '../models/pupuk_data.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  GreenhouseData? greenhouseData;
  PupukData? pupukData;
  bool isLoadingGreenhouse = true;
  bool isLoadingPupuk = true;

  @override
  void initState() {
    super.initState();
    _loadGreenhouseData();
    _loadPupukData();
  }

  void _loadGreenhouseData() {
    DatabaseReference ref = FirebaseDatabase.instance.ref(
      'monitoring_greenhouse',
    );
    ref.onValue.listen((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        setState(() {
          greenhouseData = GreenhouseData.fromMap(data);
          isLoadingGreenhouse = false;
        });
      }
    });
  }

  void _loadPupukData() {
    DatabaseReference ref = FirebaseDatabase.instance.ref('monitoring_pupuk');
    ref.onValue.listen((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        setState(() {
          pupukData = PupukData.fromMap(data);
          isLoadingPupuk = false;
        });
      }
    });
  }

  Future<void> _toggleActuator(String actuator, bool value) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref(
      'monitoring_greenhouse/$actuator',
    );
    await ref.set(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00C48C),
        elevation: 0,
        title: Row(
          children: [
            Image.asset('assets/app_icon.png', width: 32, height: 32),
            const SizedBox(width: 12),
            const Text(
              'PINTAR Dashboard',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greenhouse Section
            _buildSectionHeader('🌱 Monitoring Greenhouse'),
            const SizedBox(height: 12),
            if (isLoadingGreenhouse)
              const Center(child: CircularProgressIndicator())
            else if (greenhouseData != null)
              _buildGreenhouseCards()
            else
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('Data greenhouse tidak tersedia'),
                ),
              ),

            const SizedBox(height: 24),

            // Control Section
            _buildSectionHeader('⚙️ Kontrol Aktuator'),
            const SizedBox(height: 12),
            if (greenhouseData != null) _buildControlCards(),

            const SizedBox(height: 24),

            // Pupuk Section
            _buildSectionHeader('🐟 Monitoring Kolam Lele'),
            const SizedBox(height: 12),
            if (isLoadingPupuk)
              const Center(child: CircularProgressIndicator())
            else if (pupukData != null)
              _buildPupukCards()
            else
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('Data kolam tidak tersedia'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2D3748),
      ),
    );
  }

  Widget _buildGreenhouseCards() {
    return Column(
      children: [
        // Environment Cards
        Row(
          children: [
            Expanded(
              child: _buildDataCard(
                'Kelembapan Udara',
                '${greenhouseData!.kelembapanUdara.toStringAsFixed(1)}%',
                Icons.water_drop,
                _getHumidityColor(greenhouseData!.kelembapanUdara),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDataCard(
                'Suhu Udara',
                '${greenhouseData!.suhuUdara.toStringAsFixed(1)}°C',
                Icons.thermostat,
                _getTemperatureColor(greenhouseData!.suhuUdara),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Soil Cards
        Row(
          children: [
            Expanded(
              child: _buildDataCard(
                'Soil Moisture',
                '${greenhouseData!.soilMoist.toStringAsFixed(1)}%',
                Icons.grass,
                _getSoilMoistColor(greenhouseData!.soilMoist),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDataCard(
                'Soil Temp',
                '${greenhouseData!.soilTemp.toStringAsFixed(1)}°C',
                Icons.device_thermostat,
                _getTemperatureColor(greenhouseData!.soilTemp),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Soil Chemistry
        Row(
          children: [
            Expanded(
              child: _buildDataCard(
                'Soil pH',
                greenhouseData!.soilpH.toStringAsFixed(1),
                Icons.science,
                _getPhColor(greenhouseData!.soilpH),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDataCard(
                'TDS',
                '${greenhouseData!.tds.toStringAsFixed(0)} ppm',
                Icons.water,
                _getTdsColor(greenhouseData!.tds),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // NPK Values
        Row(
          children: [
            Expanded(
              child: _buildDataCard(
                'Nitrogen (N)',
                '${greenhouseData!.soilN.toStringAsFixed(1)}',
                Icons.eco,
                Colors.green,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildDataCard(
                'Phosphorus (P)',
                '${greenhouseData!.soilP.toStringAsFixed(1)}',
                Icons.eco,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildDataCard(
                'Potassium (K)',
                '${greenhouseData!.soilK.toStringAsFixed(1)}',
                Icons.eco,
                Colors.blue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildControlCards() {
    return Row(
      children: [
        Expanded(
          child: _buildControlCard(
            'Lampu',
            greenhouseData!.lampu,
            Icons.lightbulb,
            (value) => _toggleActuator('lampu', value),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildControlCard(
            'Pompa Air',
            greenhouseData!.pompaAir,
            Icons.water_drop,
            (value) => _toggleActuator('pompa_air', value),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildControlCard(
            'Pompa Pupuk',
            greenhouseData!.pompaPupuk,
            Icons.local_florist,
            (value) => _toggleActuator('pompa_pupuk', value),
          ),
        ),
      ],
    );
  }

  Widget _buildPupukCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDataCard(
                'NH3 (Amonia)',
                '${pupukData!.nh3.toStringAsFixed(1)} ppm',
                Icons.air,
                _getNh3Color(pupukData!.nh3),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDataCard(
                'Suhu Air',
                '${pupukData!.suhu.toStringAsFixed(1)}°C',
                Icons.thermostat,
                _getTemperatureColor(pupukData!.suhu),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDataCard(
                'TDS',
                '${pupukData!.tds.toStringAsFixed(0)} ppm',
                Icons.water,
                _getTdsColor(pupukData!.tds),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDataCard(
                'pH Air',
                pupukData!.pH.toStringAsFixed(1),
                Icons.science,
                _getPhColor(pupukData!.pH),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDataCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlCard(
    String title,
    bool value,
    IconData icon,
    Function(bool) onChanged,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              color: value ? const Color(0xFF00C48C) : Colors.grey,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Switch(
              value: value,
              activeColor: const Color(0xFF00C48C),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  // Color helpers
  Color _getHumidityColor(double humidity) {
    if (humidity < 30) return Colors.red;
    if (humidity > 70) return Colors.blue;
    return const Color(0xFF00C48C);
  }

  Color _getTemperatureColor(double temp) {
    if (temp < 15 || temp > 35) return Colors.red;
    if (temp < 20 || temp > 30) return Colors.orange;
    return const Color(0xFF00C48C);
  }

  Color _getSoilMoistColor(double moisture) {
    if (moisture < 20) return Colors.red;
    if (moisture > 80) return Colors.blue;
    return const Color(0xFF00C48C);
  }

  Color _getPhColor(double ph) {
    if (ph < 6.0 || ph > 8.0) return Colors.red;
    if (ph < 6.5 || ph > 7.5) return Colors.orange;
    return const Color(0xFF00C48C);
  }

  Color _getTdsColor(double tds) {
    if (tds < 100 || tds > 2000) return Colors.red;
    if (tds < 300 || tds > 1500) return Colors.orange;
    return const Color(0xFF00C48C);
  }

  Color _getNh3Color(double nh3) {
    if (nh3 > 25) return Colors.red;
    if (nh3 > 5) return Colors.orange;
    return const Color(0xFF00C48C);
  }
}
