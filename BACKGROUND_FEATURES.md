# Fitur Background Monitoring & Notifikasi

## Fitur yang Ditambahkan

### 1. **Real-time Background Monitoring**

- Aplikasi menggunakan Firebase Realtime Database listeners yang persistent
- Monitoring sensor secara real-time saat aplikasi aktif
- Listeners tetap aktif saat aplikasi di background (selama proses aplikasi masih hidup)
- Notifikasi langsung ketika ada perubahan data

### 2. **Notifikasi Dalam Bahasa Indonesia**

Aplikasi akan mengirim notifikasi untuk berbagai kondisi:

#### **Notifikasi Sensor Kolam Lele:**

- 🚨 **Amonia Tinggi**: Kadar amonia >0.5 ppm berbahaya untuk ikan
- 🌡️ **Suhu Kolam**: Suhu kolam di luar rentang 25-30°C
- ⚠️ **pH Kolam**: pH air di luar rentang 6.5-8.5
- ⚠️ **TDS Kolam**: TDS di luar rentang 100-300 ppm

#### **Notifikasi Sensor Greenhouse:**

- 🌡️ **Suhu Greenhouse**: Suhu udara di luar rentang 20-35°C
- 💧 **Kelembapan Udara**: Kelembapan di luar rentang 60-80%
- 🌱 **Kelembapan Tanah**: Kelembapan tanah di luar rentang 40-70%
- ⚗️ **pH Tanah**: pH tanah di luar rentang 5.5-7.5

#### **Notifikasi Kontrol Perangkat:**

- 💡 **Lampu Dalam**: DIHIDUPKAN/DIMATIKAN
- 🔆 **Lampu Luar**: DIHIDUPKAN/DIMATIKAN
- 💧 **Pompa Air**: DIHIDUPKAN/DIMATIKAN
- 🌱 **Pompa Pupuk**: DIHIDUPKAN/DIMATIKAN
- 💨 **Pompa Udara**: DIHIDUPKAN/DIMATIKAN

### 3. **Battery Optimization**

- Aplikasi akan meminta izin untuk dibebaskan dari optimisasi baterai
- Dialog penjelasan dalam bahasa Indonesia mengapa izin diperlukan
- Memastikan monitoring background dapat berjalan dengan lancar

### 4. **Permissions yang Ditambahkan**

```xml
- POST_NOTIFICATIONS: Untuk mengirim notifikasi
- WAKE_LOCK: Menjaga aplikasi tetap aktif saat monitoring
- RECEIVE_BOOT_COMPLETED: Restart monitoring setelah reboot
- FOREGROUND_SERVICE: Menjalankan service background
- REQUEST_IGNORE_BATTERY_OPTIMIZATIONS: Bypass battery optimization
```

## Cara Kerja

### **Saat Aplikasi Terbuka:**

1. Monitoring real-time semua sensor via Firebase listeners
2. Notifikasi langsung untuk perubahan status dan threshold
3. Tracking perubahan pompa/lampu secara live

### **Saat Aplikasi di Background:**

1. Firebase listeners tetap aktif selama proses aplikasi hidup
2. Android mempertahankan koneksi untuk app yang memiliki active listeners
3. Notifikasi tetap dikirim untuk kondisi darurat dan perubahan perangkat

### **Pengaturan Otomatis:**

1. Saat pertama buka aplikasi, akan muncul dialog battery optimization
2. User dapat memilih untuk mengaktifkan atau melewati
3. Setting dapat diakses kembali melalui pengaturan sistem Android

## Keunggulan

✅ **Monitoring Real-time** - Firebase listeners memberikan notifikasi instan
✅ **Lebih Stabil** - Tidak bergantung pada WorkManager yang sering bermasalah
✅ **Bahasa Indonesia** - Mudah dipahami
✅ **Detail Status** - Tahu kapan pompa/lampu dinyalakan/dimatikan dengan timestamp
✅ **Threshold Akurat** - Sesuai dengan standar optimal pertanian dan akuakultur
✅ **Battery Efficient** - Firebase listeners lebih hemat baterai dibanding periodic tasks

## Limitations & Solutions

### **Limitation: Background Process Killing**

- Android dapat membunuh proses aplikasi untuk menghemat baterai
- **Solution**: Request battery optimization exemption + user awareness

### **Limitation: Network Dependency**

- Memerlukan koneksi internet untuk Firebase
- **Solution**: Notifikasi akan dikirim begitu koneksi pulih

### **Best Practices untuk User:**

1. Aktifkan "Don't optimize" untuk aplikasi PINTAR
2. Pastikan aplikasi dalam recent apps (jangan swipe away)
3. Koneksi internet stabil
4. Untuk monitoring 24/7, biarkan aplikasi terbuka di background

## Testing

Setelah install APK:

1. Izinkan notifikasi
2. Setujui battery optimization bypass
3. Minimize aplikasi (jangan tutup dari recent apps)
4. Ubah data sensor di Firebase Console
5. Nyalakan/matikan pompa atau lampu
6. Notifikasi akan muncul dalam hitungan detik
