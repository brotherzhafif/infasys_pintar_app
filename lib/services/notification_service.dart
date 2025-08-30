import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_database/firebase_database.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

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
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'sensor_alerts',
          'Sensor Alerts',
          channelDescription: 'Notifications for sensor threshold alerts',
          importance: Importance.high,
          priority: Priority.high,
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(id, title, body, details);
  }

  static Future<void> startSensorMonitoring() async {
    // Monitor Firebase Realtime Database
    DatabaseReference ref = FirebaseDatabase.instance.ref('monitoring_pupuk');

    ref.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        double tds = (data['TDS'] ?? 0).toDouble();
        double ph = (data['pH'] ?? 0).toDouble();
        double nh3 = (data['NH3'] ?? 0).toDouble();

        // Check thresholds
        _checkThresholds(tds, ph, nh3);
      }
    });
  }

  static void _checkThresholds(double tds, double ph, double nh3) {
    // TDS threshold
    if (tds < 1000 || tds > 3000) {
      showNotification(
        id: 1,
        title: 'TDS Alert!',
        body:
            'TDS level: ${tds.toStringAsFixed(0)} ppm is out of range (1000-3000)',
      );
    }

    // pH threshold
    if (ph < 6.5 || ph > 8.0) {
      showNotification(
        id: 2,
        title: 'pH Alert!',
        body: 'pH level: ${ph.toStringAsFixed(1)} is out of range (6.5-8.0)',
      );
    }

    // NH3 threshold
    if (nh3 > 25) {
      showNotification(
        id: 3,
        title: 'NH3 Critical Alert!',
        body: 'NH3 level: ${nh3.toStringAsFixed(1)} ppm is dangerous (>25)',
      );
    } else if (nh3 > 5) {
      showNotification(
        id: 4,
        title: 'NH3 Warning!',
        body: 'NH3 level: ${nh3.toStringAsFixed(1)} ppm needs attention (>5)',
      );
    }
  }
}
