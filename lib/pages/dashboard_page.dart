import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/greenhouse_data.dart';
import '../models/pupuk_data.dart';
import '../models/control_data.dart';
import '../services/background_service.dart';
import '../services/background_monitoring_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _tabIndex = 0; // 0: Data, 1: Control

  // Define primary color variable
  static const Color primaryColor = Color.fromARGB(255, 8, 182, 110);

  GreenhouseData? _greenhouseData;
  PupukData? _pupukData;
  ControlData? _controlData;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    _loadData();
    _requestBatteryOptimization();
  }

  void _requestBatteryOptimization() async {
    // Request battery optimization permission setelah 3 detik
    Future.delayed(Duration(seconds: 3), () {
      BackgroundService.requestBatteryOptimization(context);
    });

    // Ensure background service is running
    Future.delayed(Duration(seconds: 5), () async {
      await BackgroundMonitoringService.startService();
    });
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
        backgroundColor: primaryColor,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/app_icon.png',
                width: 32,
                height: 32,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        title: Text(
          'PPKO HMTP UAD 2025',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, color: Colors.white),
            onPressed: _showInfoDialog,
          ),
        ],
      ),
      body: _tabIndex == 0 ? _buildDataTab() : _buildControlTab(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        currentIndex: _tabIndex,
        onTap: (idx) {
          setState(() {
            _tabIndex = idx;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Data'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_remote),
            label: 'Control',
          ),
        ],
      ),
    );
  }

  Widget _buildDataTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header Data Greenhouse dengan update time
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Data Greenhouse',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            if (_greenhouseData != null)
              Text(
                '${_greenhouseData!.hari}, ${_greenhouseData!.tanggal}/${_greenhouseData!.bulan}/${_greenhouseData!.tahun} ${_greenhouseData!.jam}:${_greenhouseData!.menit.toString().padLeft(2, '0')}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (_greenhouseData != null) ...[
          // Baris pertama - 2 card
          Row(
            children: [
              _dataCard(
                'Suhu\nUdara',
                '${_greenhouseData!.suhuUdara.toStringAsFixed(1)}°C',
                Icons.thermostat,
              ),
              const SizedBox(width: 8),
              _dataCard(
                'Kelembapan Udara',
                '${_greenhouseData!.kelembapanUdara.toStringAsFixed(1)}%',
                Icons.water_drop,
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Baris kedua - 2 card
          Row(
            children: [
              _dataCard(
                'TDS\nAir',
                '${_greenhouseData!.tds.toInt()} ppm',
                Icons.opacity,
              ),
              const SizedBox(width: 8),
              _dataCard(
                'pH\nAir',
                '${_greenhouseData!.soilpH.toStringAsFixed(1)}',
                Icons.science,
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Baris ketiga - 2 card
          Row(
            children: [
              _dataCard(
                'Kelembapan Tanah',
                '${_greenhouseData!.soilMoist.toStringAsFixed(1)}%',
                Icons.grain,
              ),
              const SizedBox(width: 8),
              _dataCard(
                'Suhu\nTanah',
                '${_greenhouseData!.soilTemp.toStringAsFixed(1)}°C',
                Icons.device_thermostat,
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Baris keempat - 2 card
          Row(
            children: [
              _dataCard(
                'Nitrogen\n(N)',
                '${_greenhouseData!.soilN.toStringAsFixed(1)} mg/L',
                Icons.eco,
              ),
              const SizedBox(width: 8),
              _dataCard(
                'Fosfor\n(P)',
                '${_greenhouseData!.soilP.toStringAsFixed(1)} mg/L',
                Icons.local_florist,
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Baris kelima - 2 card
          Row(
            children: [
              _dataCard(
                'Kalium\n(K)',
                '${_greenhouseData!.soilK.toStringAsFixed(1)} mg/L',
                Icons.grass,
              ),
              const SizedBox(width: 8),
              _dataCard(
                'Konduktivitas Tanah',
                '${_greenhouseData!.soilEC.toStringAsFixed(2)} mS/cm',
                Icons.electrical_services,
              ),
            ],
          ),
        ],
        const SizedBox(height: 24),
        // Header Data Kolam Lele dengan update time
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Data Kolam Lele',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            if (_pupukData != null)
              Text(
                '${_pupukData!.hari}, ${_pupukData!.tanggal}/${_pupukData!.bulan}/${_pupukData!.tahun} ${_pupukData!.jam}:${_pupukData!.menit.toString().padLeft(2, '0')}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (_pupukData != null) ...[
          // Baris pertama - 2 card
          Row(
            children: [
              _dataCard(
                'Amonia\nKolam',
                '${_pupukData!.nh3.toStringAsFixed(1)} ppm',
                Icons.cloud,
              ),
              const SizedBox(width: 8),
              _dataCard(
                'Suhu\nKolam',
                '${_pupukData!.suhu.toStringAsFixed(1)}°C',
                Icons.thermostat,
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Baris kedua - 2 card
          Row(
            children: [
              _dataCard(
                'pH\nKolam',
                '${_pupukData!.pH.toStringAsFixed(1)}',
                Icons.science,
              ),
              const SizedBox(width: 8),
              _dataCard(
                'TDS\nKolam',
                '${_pupukData!.tds.toInt()} ppm',
                Icons.opacity,
              ),
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

  Widget _dataCard(String title, String value, IconData icon) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _showDataExplanation(title),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(icon, color: primaryColor, size: 40),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
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
                color: isActive ? primaryColor : Colors.grey,
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
                  color: isActive ? primaryColor : Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Switch(
                value: isActive,
                activeColor: primaryColor,
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
                  '$duration Menit',
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
                  color: primaryColor,
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
                  color: primaryColor,
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

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Image.asset('assets/app_icon.png', width: 32, height: 32),
              SizedBox(width: 12),
              Text(
                'Tentang Aplikasi',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PINTAR (Pandowo Integrated Farming Center)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 12),
              Text(
                'Aplikasi monitoring dan kontrol sistem pertanian pintar untuk greenhouse dan kolam lele.',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 16),
              Text(
                'Latar Belakang:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              SizedBox(height: 8),
              Text(
                'Aplikasi ini dibuat untuk mendukung sistem pertanian modern dengan teknologi IoT, memungkinkan pemantauan dan kontrol jarak jauh untuk meningkatkan efisiensi dan produktivitas pertanian.',
                style: TextStyle(fontSize: 12),
              ),
              SizedBox(height: 16),
              Text(
                'Dikembangkan oleh:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              SizedBox(height: 8),
              Text(
                '• Raja Zhafif Raditya Harahap\n• Muhammad Ikhwan Nur Sidik\n• Siti Nurhayati',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Tutup', style: TextStyle(color: primaryColor)),
            ),
          ],
        );
      },
    );
  }

  void _showDataExplanation(String dataType) {
    // Remove line breaks from dataType to match the keys in explanations
    String cleanDataType = dataType.replaceAll('\n', ' ');

    Map<String, Map<String, String>> explanations = {
      'Suhu Udara': {
        'title': 'Suhu Udara',
        'description': 'Mengukur suhu lingkungan di dalam greenhouse.',
        'range': 'Optimal: 20-35°C',
        'importance':
            'Suhu yang tepat mempengaruhi laju fotosintesis, pertumbuhan tanaman, dan aktivitas mikroorganisme dalam tanah.',
      },
      'Kelembapan Udara': {
        'title': 'Kelembapan Udara',
        'description': 'Mengukur kadar air dalam udara greenhouse.',
        'range': 'Optimal: 60-80%',
        'importance':
            'Kelembapan yang seimbang mencegah stress pada tanaman dan mengurangi risiko penyakit jamur.',
      },
      'TDS Air': {
        'title': 'TDS Air (Total Dissolved Solids)',
        'description': 'Mengukur total zat terlarut dalam air irigasi.',
        'range': 'Optimal: 500-1500 ppm',
        'importance':
            'Menunjukkan konsentrasi nutrisi dalam air. TDS tinggi menandakan air kaya nutrisi.',
      },
      'pH Air': {
        'title': 'pH Air',
        'description': 'Mengukur tingkat keasaman/kebasaan air irigasi.',
        'range': 'Optimal: 5.5-7.5',
        'importance':
            'pH yang tepat memastikan tanaman dapat menyerap nutrisi dengan optimal.',
      },
      'Kelembapan Tanah': {
        'title': 'Kelembapan Tanah',
        'description': 'Mengukur kadar air dalam tanah.',
        'range': 'Optimal: 40-70%',
        'importance':
            'Menentukan kebutuhan irigasi. Kelembapan optimal mencegah stress air pada tanaman.',
      },
      'Suhu Tanah': {
        'title': 'Suhu Tanah',
        'description': 'Mengukur suhu di dalam tanah.',
        'range': 'Optimal: 15-30°C',
        'importance':
            'Mempengaruhi aktivitas akar, penyerapan nutrisi, dan aktivitas mikroorganisme tanah.',
      },
      'Nitrogen (N)': {
        'title': 'Nitrogen (N)',
        'description': 'Mengukur kadar nitrogen dalam tanah.',
        'range': 'Optimal: 10-50 mg/L',
        'importance':
            'Nutrisi utama untuk pertumbuhan daun dan batang. Penting untuk fotosintesis.',
      },
      'Fosfor (P)': {
        'title': 'Fosfor (P)',
        'description': 'Mengukur kadar fosfor dalam tanah.',
        'range': 'Optimal: 5-25 mg/L',
        'importance':
            'Penting untuk pembentukan akar, bunga, dan buah. Berperan dalam transfer energi.',
      },
      'Kalium (K)': {
        'title': 'Kalium (K)',
        'description': 'Mengukur kadar kalium dalam tanah.',
        'range': 'Optimal: 10-40 mg/L',
        'importance':
            'Mengatur keseimbangan air, meningkatkan ketahanan penyakit, dan kualitas buah.',
      },
      'Konduktivitas Tanah': {
        'title': 'Konduktivitas Tanah (EC)',
        'description': 'Mengukur kemampuan tanah menghantarkan listrik.',
        'range': 'Optimal: 0.8-2.5 mS/cm',
        'importance':
            'Menunjukkan kadar garam dan nutrisi dalam tanah. EC tinggi dapat menyebabkan stress osmotik.',
      },
      'Amonia Kolam': {
        'title': 'Amonia Kolam (NH3)',
        'description': 'Mengukur kadar amonia dalam air kolam lele.',
        'range': 'Aman: < 0.5 ppm',
        'importance':
            'Amonia tinggi berbahaya bagi ikan. Indikator kualitas air dan efektivitas filter biologis.',
      },
      'Suhu Kolam': {
        'title': 'Suhu Kolam',
        'description': 'Mengukur suhu air dalam kolam lele.',
        'range': 'Optimal: 25-30°C',
        'importance':
            'Mempengaruhi metabolisme ikan, nafsu makan, dan pertumbuhan. Suhu optimal meningkatkan efisiensi pakan.',
      },
      'pH Kolam': {
        'title': 'pH Kolam',
        'description': 'Mengukur tingkat keasaman/kebasaan air kolam.',
        'range': 'Optimal: 6.5-8.5',
        'importance':
            'pH yang seimbang menjaga kesehatan ikan dan efektivitas filter biologis.',
      },
      'TDS Kolam': {
        'title': 'TDS Kolam',
        'description': 'Mengukur total zat terlarut dalam air kolam.',
        'range': 'Optimal: 100-300 ppm',
        'importance':
            'Menunjukkan kualitas air secara umum. TDS tinggi dapat mengganggu kesehatan ikan.',
      },
    };

    final explanation = explanations[cleanDataType];
    if (explanation == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            explanation['title']!,
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Deskripsi:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              SizedBox(height: 4),
              Text(explanation['description']!, style: TextStyle(fontSize: 13)),
              SizedBox(height: 12),
              Text(
                'Rentang Optimal:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              SizedBox(height: 4),
              Text(
                explanation['range']!,
                style: TextStyle(
                  fontSize: 13,
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Pentingnya:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              SizedBox(height: 4),
              Text(explanation['importance']!, style: TextStyle(fontSize: 13)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Tutup', style: TextStyle(color: primaryColor)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildControlTab() {
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
            'Pengaturan Durasi (Menit)',
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
