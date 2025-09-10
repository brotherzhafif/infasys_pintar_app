import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BackgroundService {
  static const MethodChannel _channel = MethodChannel('background_service');

  /// Request to disable battery optimization for the app
  static Future<void> requestBatteryOptimization(BuildContext context) async {
    try {
      final bool isIgnoringBatteryOptimizations = await _channel.invokeMethod(
        'isIgnoringBatteryOptimizations',
      );

      if (!isIgnoringBatteryOptimizations) {
        // Show dialog to explain why we need this permission
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Izin Penggunaan Background'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Untuk memastikan aplikasi PINTAR dapat terus memantau sensor dan mengirim notifikasi meskipun dalam mode background, aplikasi memerlukan izin khusus.',
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Izin ini diperlukan untuk:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  SizedBox(height: 8),
                  Text('• Memantau data sensor secara real-time'),
                  Text('• Mengirim notifikasi peringatan'),
                  Text('• Memberitahu perubahan status pompa/lampu'),
                  SizedBox(height: 12),
                  Text(
                    'Aplikasi akan membuka pengaturan sistem untuk mengaktifkan izin ini.',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await _channel.invokeMethod(
                      'requestIgnoreBatteryOptimizations',
                    );
                  },
                  child: Text('Buka Pengaturan'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print('Error requesting battery optimization: $e');
    }
  }

  /// Check if app is whitelisted from battery optimization
  static Future<bool> isIgnoringBatteryOptimizations() async {
    try {
      return await _channel.invokeMethod('isIgnoringBatteryOptimizations');
    } catch (e) {
      print('Error checking battery optimization: $e');
      return false;
    }
  }
}
