import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_database/firebase_database.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // State tracking untuk perubahan status
  static Map<String, String> _previousControlStates = {};

  // Tracking untuk status normal
  static bool _lastPondStatusWasNormal = false;
  static bool _lastGreenhouseStatusWasNormal = false;
  static DateTime? _lastNormalNotificationTime;
  static const Duration _normalNotificationInterval = Duration(hours: 2);

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(settings);

    // Request permissions for Android 13+
    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    bool isNormalStatus = false,
  }) async {
    final String channelId = isNormalStatus ? 'normal_status' : 'sensor_alerts';
    final String channelName = isNormalStatus
        ? 'Status Normal'
        : 'Peringatan Sensor';
    final String channelDescription = isNormalStatus
        ? 'Notifikasi untuk status normal sistem'
        : 'Notifikasi untuk peringatan ambang batas sensor dan kontrol perangkat';
    final Importance importance = isNormalStatus
        ? Importance.defaultImportance
        : Importance.high;
    final Priority priority = isNormalStatus
        ? Priority.defaultPriority
        : Priority.high;

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: channelDescription,
          importance: importance,
          priority: priority,
          icon: '@mipmap/ic_launcher',
        );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(id, title, body, details);
  }

  static Future<void> startSensorMonitoring() async {
    // Send initial notification that monitoring is active
    showNotification(
      id: 1000,
      title: '🚀 Monitoring Dimulai!',
      body:
          'Sistem monitoring PINTAR telah aktif. Anda akan mendapat notifikasi untuk setiap perubahan status dan peringatan.',
      isNormalStatus: true,
    );

    // Monitor Firebase Realtime Database - Sensor Data
    // These listeners will continue to work even when app is in background
    // as long as the app process is still alive

    DatabaseReference pupukRef = FirebaseDatabase.instance.ref(
      'monitoring_pupuk',
    );
    DatabaseReference greenhouseRef = FirebaseDatabase.instance.ref(
      'monitoring_greenhouse',
    );
    DatabaseReference controlRef = FirebaseDatabase.instance.ref('control');

    // Monitor kolam lele data
    pupukRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        double tds = (data['TDS'] ?? 0).toDouble();
        double ph = (data['pH'] ?? 0).toDouble();
        double nh3 = (data['NH3'] ?? 0).toDouble();
        double suhu = (data['suhu'] ?? 0).toDouble();

        // Check thresholds untuk kolam lele
        _checkPondThresholds(tds, ph, nh3, suhu);
      }
    });

    // Monitor greenhouse data
    greenhouseRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        double suhuUdara = (data['suhu_udara'] ?? 0).toDouble();
        double kelembapanUdara = (data['kelembapan_udara'] ?? 0).toDouble();
        double soilMoist = (data['soil_moist'] ?? 0).toDouble();
        double soilpH = (data['soilpH'] ?? 0).toDouble();
        double soilTemp = (data['soil_temp'] ?? 0).toDouble();

        // Check thresholds untuk greenhouse
        _checkGreenhouseThresholds(
          suhuUdara,
          kelembapanUdara,
          soilMoist,
          soilpH,
          soilTemp,
        );
      }
    });

    // Monitor control status changes
    controlRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        _checkControlChanges(data);
      }
    });

    // Start periodic normal status check
    _startPeriodicNormalCheck();
  }

  static void _startPeriodicNormalCheck() {
    // Check every 2 hours if everything is normal
    Timer.periodic(_normalNotificationInterval, (timer) {
      _checkAndSendPeriodicNormalNotification();
    });
  }

  static void _checkAndSendPeriodicNormalNotification() {
    final now = DateTime.now();

    // Only send if both systems are normal and enough time has passed
    if (_lastPondStatusWasNormal &&
        _lastGreenhouseStatusWasNormal &&
        (_lastNormalNotificationTime == null ||
            now.difference(_lastNormalNotificationTime!) >=
                _normalNotificationInterval)) {
      showNotification(
        id: 999,
        title: '🌟 Semua Sistem Normal!',
        body:
            'Kolam lele dan greenhouse dalam kondisi optimal pada ${_getCurrentTime()}. Monitoring tetap berjalan.',
        isNormalStatus: true,
      );

      _lastNormalNotificationTime = now;
    }
  }

  static void _checkPondThresholds(
    double tds,
    double ph,
    double nh3,
    double suhu,
  ) {
    bool hasIssue = false;

    // TDS threshold
    if (tds < 100 || tds > 300) {
      hasIssue = true;
      showNotification(
        id: 1,
        title: '⚠️ Peringatan TDS Kolam!',
        body:
            'Kadar TDS: ${tds.toStringAsFixed(0)} ppm tidak normal (Optimal: 100-300 ppm)',
      );
    }

    // pH threshold
    if (ph < 6.5 || ph > 8.5) {
      hasIssue = true;
      showNotification(
        id: 2,
        title: '⚠️ Peringatan pH Kolam!',
        body:
            'pH air: ${ph.toStringAsFixed(1)} tidak optimal (Optimal: 6.5-8.5)',
      );
    }

    // NH3 threshold
    if (nh3 > 0.5) {
      hasIssue = true;
      showNotification(
        id: 3,
        title: '🚨 Bahaya Amonia Tinggi!',
        body:
            'Kadar amonia: ${nh3.toStringAsFixed(1)} ppm berbahaya untuk ikan (Aman: <0.5 ppm)',
      );
    }

    // Suhu kolam
    if (suhu < 25 || suhu > 30) {
      hasIssue = true;
      showNotification(
        id: 4,
        title: '🌡️ Peringatan Suhu Kolam!',
        body:
            'Suhu kolam: ${suhu.toStringAsFixed(1)}°C kurang optimal (Optimal: 25-30°C)',
      );
    }

    // Check untuk status normal
    if (!hasIssue && !_lastPondStatusWasNormal) {
      showNotification(
        id: 101,
        title: '✅ Kolam Lele Normal!',
        body:
            'Semua parameter kolam lele dalam kondisi optimal. TDS: ${tds.toStringAsFixed(0)}ppm, pH: ${ph.toStringAsFixed(1)}, NH3: ${nh3.toStringAsFixed(1)}ppm, Suhu: ${suhu.toStringAsFixed(1)}°C',
        isNormalStatus: true,
      );
      _lastPondStatusWasNormal = true;
    } else if (hasIssue) {
      _lastPondStatusWasNormal = false;
    }
  }

  static void _checkGreenhouseThresholds(
    double suhuUdara,
    double kelembapanUdara,
    double soilMoist,
    double soilpH,
    double soilTemp,
  ) {
    bool hasIssue = false;

    // Suhu udara
    if (suhuUdara < 20 || suhuUdara > 35) {
      hasIssue = true;
      showNotification(
        id: 5,
        title: '🌡️ Peringatan Suhu Greenhouse!',
        body:
            'Suhu udara: ${suhuUdara.toStringAsFixed(1)}°C tidak optimal (Optimal: 20-35°C)',
      );
    }

    // Kelembapan udara
    if (kelembapanUdara < 60 || kelembapanUdara > 80) {
      hasIssue = true;
      showNotification(
        id: 6,
        title: '💧 Peringatan Kelembapan!',
        body:
            'Kelembapan udara: ${kelembapanUdara.toStringAsFixed(1)}% kurang seimbang (Optimal: 60-80%)',
      );
    }

    // Kelembapan tanah
    if (soilMoist < 40 || soilMoist > 70) {
      hasIssue = true;
      showNotification(
        id: 7,
        title: '🌱 Peringatan Kelembapan Tanah!',
        body:
            'Kelembapan tanah: ${soilMoist.toStringAsFixed(1)}% perlu perhatian (Optimal: 40-70%)',
      );
    }

    // pH tanah
    if (soilpH < 5.5 || soilpH > 7.5) {
      hasIssue = true;
      showNotification(
        id: 8,
        title: '⚗️ Peringatan pH Tanah!',
        body:
            'pH tanah: ${soilpH.toStringAsFixed(1)} tidak optimal (Optimal: 5.5-7.5)',
      );
    }

    // Check untuk status normal
    if (!hasIssue && !_lastGreenhouseStatusWasNormal) {
      showNotification(
        id: 102,
        title: '🌿 Greenhouse Normal!',
        body:
            'Semua parameter greenhouse dalam kondisi optimal. Suhu: ${suhuUdara.toStringAsFixed(1)}°C, Kelembapan: ${kelembapanUdara.toStringAsFixed(1)}%, Tanah: ${soilMoist.toStringAsFixed(1)}%, pH: ${soilpH.toStringAsFixed(1)}',
        isNormalStatus: true,
      );
      _lastGreenhouseStatusWasNormal = true;
    } else if (hasIssue) {
      _lastGreenhouseStatusWasNormal = false;
    }
  }

  static void _checkControlChanges(Map<dynamic, dynamic> currentData) {
    Map<String, String> currentStates = {
      'lampu_dalam': currentData['lampu_dalam']?.toString() ?? 'off',
      'lampu_luar': currentData['lampu_luar']?.toString() ?? 'off',
      'pompa_air': currentData['pompa_air']?.toString() ?? 'off',
      'pompa_pupuk': currentData['pompa_pupuk']?.toString() ?? 'off',
      'pompa_udara': currentData['pompa_udara']?.toString() ?? 'off',
    };

    // Check for changes and send notifications
    currentStates.forEach((device, state) {
      if (_previousControlStates.containsKey(device) &&
          _previousControlStates[device] != state) {
        _sendControlNotification(device, state);
      }
    });

    // Update previous states
    _previousControlStates = Map.from(currentStates);
  }

  static void _sendControlNotification(String device, String state) {
    String deviceName = '';
    String icon = '';

    switch (device) {
      case 'lampu_dalam':
        deviceName = 'Lampu Dalam';
        icon = '💡';
        break;
      case 'lampu_luar':
        deviceName = 'Lampu Luar';
        icon = '🔆';
        break;
      case 'pompa_air':
        deviceName = 'Pompa Air';
        icon = '💧';
        break;
      case 'pompa_pupuk':
        deviceName = 'Pompa Pupuk';
        icon = '🌱';
        break;
      case 'pompa_udara':
        deviceName = 'Pompa Udara';
        icon = '💨';
        break;
    }

    String status = state == 'on' ? 'DIHIDUPKAN' : 'DIMATIKAN';
    String statusIcon = state == 'on' ? '✅' : '⭕';

    showNotification(
      id: device.hashCode,
      title: '$icon $deviceName $statusIcon',
      body: '$deviceName telah $status pada ${_getCurrentTime()}',
    );
  }

  static String _getCurrentTime() {
    DateTime now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }
}
