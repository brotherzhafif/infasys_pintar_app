import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import '../firebase_options.dart';

class BackgroundMonitoringService {
  static const String serviceName = 'monitoring_service';

  static Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    // Configure notification channel for service
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'background_service',
      'Background Monitoring Service',
      description: 'This channel is used for monitoring notifications.',
      importance: Importance.low,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    await service.configure(
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
        notificationChannelId: 'background_service',
        initialNotificationTitle: 'PINTAR Background Service',
        initialNotificationContent:
            'Memantau sensor greenhouse dan kolam lele...',
        foregroundServiceNotificationId: 888,
      ),
    );
  }

  static Future<void> startService() async {
    final service = FlutterBackgroundService();
    var isRunning = await service.isRunning();
    if (!isRunning) {
      service.startService();
    }
  }

  static Future<void> stopService() async {
    final service = FlutterBackgroundService();
    service.invoke("stop");
  }

  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    return true;
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();

    // Initialize Firebase for background service
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      print('Firebase already initialized');
    }

    // Initialize notifications
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Variables for monitoring
    Map<String, String> previousControlStates = {};
    Map<String, double> previousSensorValues = {};

    // Start monitoring Firebase
    _startFirebaseMonitoring(
      flutterLocalNotificationsPlugin,
      previousControlStates,
      previousSensorValues,
    );

    // Update service notification every 30 seconds
    Timer.periodic(const Duration(seconds: 30), (timer) async {
      if (service is AndroidServiceInstance) {
        if (await service.isForegroundService()) {
          service.setForegroundNotificationInfo(
            title: "PINTAR Monitoring Aktif",
            content:
                "Memantau sensor - ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}",
          );
        }
      }

      // Send heartbeat to show service is alive
      print('Background service heartbeat: ${DateTime.now()}');
    });

    // Listen for stop commands
    service.on('stop').listen((event) {
      service.stopSelf();
    });
  }

  static void _startFirebaseMonitoring(
    FlutterLocalNotificationsPlugin notifications,
    Map<String, String> previousControlStates,
    Map<String, double> previousSensorValues,
  ) {
    // Monitor kolam lele data
    DatabaseReference pupukRef = FirebaseDatabase.instance.ref(
      'monitoring_pupuk',
    );
    pupukRef.onValue.listen((DatabaseEvent event) {
      try {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        if (data != null) {
          double tds = (data['TDS'] ?? 0).toDouble();
          double ph = (data['pH'] ?? 0).toDouble();
          double nh3 = (data['NH3'] ?? 0).toDouble();
          double suhu = (data['suhu'] ?? 0).toDouble();

          _checkPondThresholds(notifications, tds, ph, nh3, suhu);
        }
      } catch (e) {
        print('Error monitoring pupuk data: $e');
      }
    });

    // Monitor greenhouse data
    DatabaseReference greenhouseRef = FirebaseDatabase.instance.ref(
      'monitoring_greenhouse',
    );
    greenhouseRef.onValue.listen((DatabaseEvent event) {
      try {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        if (data != null) {
          double suhuUdara = (data['suhu_udara'] ?? 0).toDouble();
          double kelembapanUdara = (data['kelembapan_udara'] ?? 0).toDouble();
          double soilMoist = (data['soil_moist'] ?? 0).toDouble();
          double soilpH = (data['soilpH'] ?? 0).toDouble();
          double soilTemp = (data['soil_temp'] ?? 0).toDouble();

          _checkGreenhouseThresholds(
            notifications,
            suhuUdara,
            kelembapanUdara,
            soilMoist,
            soilpH,
            soilTemp,
          );
        }
      } catch (e) {
        print('Error monitoring greenhouse data: $e');
      }
    });

    // Monitor control changes
    DatabaseReference controlRef = FirebaseDatabase.instance.ref('control');
    controlRef.onValue.listen((DatabaseEvent event) {
      try {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        if (data != null) {
          _checkControlChanges(notifications, data, previousControlStates);
        }
      } catch (e) {
        print('Error monitoring control data: $e');
      }
    });
  }

  static void _checkPondThresholds(
    FlutterLocalNotificationsPlugin notifications,
    double tds,
    double ph,
    double nh3,
    double suhu,
  ) {
    // TDS threshold
    if (tds < 100 || tds > 300) {
      _showBackgroundNotification(
        notifications,
        1,
        '⚠️ Peringatan TDS Kolam!',
        'Kadar TDS: ${tds.toStringAsFixed(0)} ppm tidak normal (Optimal: 100-300 ppm)',
      );
    }

    // pH threshold
    if (ph < 6.5 || ph > 8.5) {
      _showBackgroundNotification(
        notifications,
        2,
        '⚠️ Peringatan pH Kolam!',
        'pH air: ${ph.toStringAsFixed(1)} tidak optimal (Optimal: 6.5-8.5)',
      );
    }

    // NH3 threshold
    if (nh3 > 0.5) {
      _showBackgroundNotification(
        notifications,
        3,
        '🚨 Bahaya Amonia Tinggi!',
        'Kadar amonia: ${nh3.toStringAsFixed(1)} ppm berbahaya untuk ikan (Aman: <0.5 ppm)',
      );
    }

    // Suhu kolam
    if (suhu < 25 || suhu > 30) {
      _showBackgroundNotification(
        notifications,
        4,
        '🌡️ Peringatan Suhu Kolam!',
        'Suhu kolam: ${suhu.toStringAsFixed(1)}°C kurang optimal (Optimal: 25-30°C)',
      );
    }
  }

  static void _checkGreenhouseThresholds(
    FlutterLocalNotificationsPlugin notifications,
    double suhuUdara,
    double kelembapanUdara,
    double soilMoist,
    double soilpH,
    double soilTemp,
  ) {
    // Suhu udara
    if (suhuUdara < 20 || suhuUdara > 35) {
      _showBackgroundNotification(
        notifications,
        5,
        '🌡️ Peringatan Suhu Greenhouse!',
        'Suhu udara: ${suhuUdara.toStringAsFixed(1)}°C tidak optimal (Optimal: 20-35°C)',
      );
    }

    // Kelembapan udara
    if (kelembapanUdara < 60 || kelembapanUdara > 80) {
      _showBackgroundNotification(
        notifications,
        6,
        '💧 Peringatan Kelembapan!',
        'Kelembapan udara: ${kelembapanUdara.toStringAsFixed(1)}% kurang seimbang (Optimal: 60-80%)',
      );
    }

    // Kelembapan tanah
    if (soilMoist < 40 || soilMoist > 70) {
      _showBackgroundNotification(
        notifications,
        7,
        '🌱 Peringatan Kelembapan Tanah!',
        'Kelembapan tanah: ${soilMoist.toStringAsFixed(1)}% perlu perhatian (Optimal: 40-70%)',
      );
    }

    // pH tanah
    if (soilpH < 5.5 || soilpH > 7.5) {
      _showBackgroundNotification(
        notifications,
        8,
        '⚗️ Peringatan pH Tanah!',
        'pH tanah: ${soilpH.toStringAsFixed(1)} tidak optimal (Optimal: 5.5-7.5)',
      );
    }
  }

  static void _checkControlChanges(
    FlutterLocalNotificationsPlugin notifications,
    Map<dynamic, dynamic> currentData,
    Map<String, String> previousControlStates,
  ) {
    Map<String, String> currentStates = {
      'lampu_dalam': currentData['lampu_dalam']?.toString() ?? 'off',
      'lampu_luar': currentData['lampu_luar']?.toString() ?? 'off',
      'pompa_air': currentData['pompa_air']?.toString() ?? 'off',
      'pompa_pupuk': currentData['pompa_pupuk']?.toString() ?? 'off',
      'pompa_udara': currentData['pompa_udara']?.toString() ?? 'off',
    };

    // Check for changes and send notifications
    currentStates.forEach((device, state) {
      if (previousControlStates.containsKey(device) &&
          previousControlStates[device] != state) {
        _sendControlNotification(notifications, device, state);
      }
    });

    // Update previous states
    previousControlStates.clear();
    previousControlStates.addAll(currentStates);
  }

  static void _sendControlNotification(
    FlutterLocalNotificationsPlugin notifications,
    String device,
    String state,
  ) {
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

    _showBackgroundNotification(
      notifications,
      device.hashCode,
      '$icon $deviceName $statusIcon',
      '$deviceName telah $status pada ${_getCurrentTime()}',
    );
  }

  static void _showBackgroundNotification(
    FlutterLocalNotificationsPlugin notifications,
    int id,
    String title,
    String body,
  ) {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'sensor_alerts',
          'Peringatan Sensor',
          channelDescription:
              'Notifikasi untuk peringatan sensor dan kontrol perangkat',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    notifications.show(id, title, body, platformChannelSpecifics);
  }

  static String _getCurrentTime() {
    DateTime now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }
}
