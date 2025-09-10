# Troubleshooting & Tips

## Jika Notifikasi Tidak Muncul

### 1. **Periksa Izin Notifikasi**

- Buka Settings Android > Apps > PINTAR > Notifications
- Pastikan "Allow notifications" sudah diaktifkan

### 2. **Periksa Battery Optimization**

- Buka Settings Android > Battery > Battery optimization
- Cari "PINTAR" dan pilih "Don't optimize"

### 3. **Periksa Background App Refresh**

- Buka Settings Android > Apps > PINTAR > Battery
- Pilih "Unrestricted" untuk background activity

### 4. **Auto-start Apps (Xiaomi/MIUI)**

- Buka Security > Manage apps > Autostart
- Aktifkan autostart untuk PINTAR

### 5. **Battery Saver Mode**

- Jika HP dalam mode hemat baterai, nonaktifkan sementara
- Atau tambahkan PINTAR ke whitelist battery saver

## Testing Notifikasi Manual

Untuk test apakah notifikasi bekerja:

1. **Test Sensor Threshold**:

   - Ubah data di Firebase Console
   - Set nilai di luar rentang normal
   - Notifikasi harus muncul dalam 1-2 detik

2. **Test Control Changes**:

   - Nyalakan/matikan pompa melalui app
   - Notifikasi status harus muncul

3. **Test Background**:
   - Tutup aplikasi completely
   - Ubah data sensor di Firebase
   - Tunggu maksimal 15 menit (WorkManager interval)

## Optimisasi Performance

### Background Task Interval

Saat ini WorkManager berjalan setiap 15 menit. Untuk mengubah:

```dart
// Di NotificationService.dart, ubah frequency:
frequency: Duration(minutes: 5), // Lebih sering, tapi lebih boros baterai
frequency: Duration(minutes: 30), // Lebih hemat, tapi respons lebih lambat
```

### Selective Monitoring

Jika ingin monitoring hanya sensor tertentu, edit fungsi:

- `_checkPondThresholds()` - untuk kolam lele
- `_checkGreenhouseThresholds()` - untuk greenhouse
- `_checkControlChanges()` - untuk pompa/lampu

Comentar bagian yang tidak diperlukan untuk menghemat resource.

## Debugging

### Log Monitoring

Untuk melihat log background task:

```bash
flutter logs
```

### Firebase Database Rules

Pastikan rules Firebase mengizinkan read tanpa autentikasi:

```json
{
  "rules": {
    ".read": true,
    ".write": true
  }
}
```

### Network Connectivity

Background monitoring memerlukan koneksi internet. Pastikan:

- WiFi atau data seluler aktif
- Firebase dapat diakses
- Tidak ada firewall yang memblokir

## Pengaturan Lanjutan

### Custom Notification Channels

Untuk membuat channel notifikasi terpisah per jenis:

```dart
// Buat channel terpisah untuk kontrol devices
const AndroidNotificationDetails controlNotificationDetails =
    AndroidNotificationDetails(
      'device_control',
      'Kontrol Perangkat',
      channelDescription: 'Notifikasi untuk status pompa dan lampu',
      importance: Importance.high,
      priority: Priority.high,
    );
```

### Do Not Disturb Mode

Jika ingin bypass DND mode untuk notifikasi darurat:

```dart
// Tambahkan di AndroidNotificationDetails
category: AndroidNotificationCategory.alarm, // Bypass DND
fullScreenIntent: true, // Tampilkan full screen untuk emergency
```
