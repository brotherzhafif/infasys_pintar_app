import 'package:flutter/material.dart';
import 'pages/splash_screen.dart';
import 'pages/login_page.dart';
import 'pages/building_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/building_detail_page.dart';
import 'pages/device_detail_page.dart';
import 'pages/add_building_page.dart';
import 'pages/schedule_page.dart';
import 'pages/statistik_page.dart';
import 'pages/profile_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PINTAR App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginPage(),
        '/building': (context) => const BuildingPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/building_detail': (context) => const BuildingDetailPage(),
        '/device_detail': (context) => const DeviceDetailPage(),
        '/add_building': (context) => const AddBuildingPage(),

        // Untuk AddDeviceSheet, gunakan showModalBottomSheet, bukan route
        '/schedule': (context) => const SchedulePage(),
        '/statistik': (context) => const StatistikPage(),
        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}
