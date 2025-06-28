# 📱 PINTAR - Pandowo Integrated Auto Farming

**Aplikasi Mobile untuk Otomatisasi dan Monitoring Pertanian Berbasis IoT**

---

## 📌 Ringkasan Proyek

**PINTAR (Pandowo Integrated Auto Farming)** adalah aplikasi mobile berbasis Flutter yang dirancang untuk mendukung sistem pertanian cerdas (smart farming) melalui pemantauan dan pengendalian perangkat IoT di area seperti greenhouse dan kolam lele. Aplikasi ini merupakan bagian dari program PPK Ormawa HMTP 2025 berbasis INFASYS.

---

## 🏗️ Arsitektur Sistem

```mermaid
flowchart TD
    ESP32[ESP32 Sensor/Actuator] -->|Wi-Fi| MQTT[MQTT Broker / REST API]
    MQTT --> Firebase[Firebase (Firestore + Auth)]
    Firebase --> App[Flutter App (PINTAR)]
    App --> Firebase
```

**Komponen Utama:**

- **ESP32**: Perangkat IoT untuk membaca dan mengendalikan lingkungan (sensor suhu, pH, kelembaban, pompa air, dll).
- **Wi-Fi Greenhouse**: Koneksi lokal alat IoT ke internet/server.
- **MQTT Broker / REST API**: Jembatan komunikasi real-time antar alat dan aplikasi.
- **Firebase**: Backend untuk autentikasi, penyimpanan data, notifikasi, dan cloud function.
- **Flutter App**: Aplikasi mobile untuk petani dan tim pengelola.

---

## 🔧 Fitur Utama

- **Registrasi Bangunan dan Perangkat IoT**
- **Pemantauan Data Sensor (Real-time)**
- **Kontrol Aktuator Jarak Jauh (Pompa, Kipas, dll)**
- **Statistik dan Grafik Data**
- **Penjadwalan Otomatisasi Perangkat**
- **Notifikasi Keadaan Abnormal**

---

## 🔌 Alur Pendaftaran Perangkat IoT

1. Perangkat IoT (ESP32) connect ke Wi-Fi greenhouse
2. Mengirim identitas ke server via MQTT atau HTTP POST:

```json
{
  "device_id": "SENSOR_ABC123",
  "type": "sensor",
  "category": "pH",
  "status": "ready"
}
```

3. Firebase menyimpan data device dengan status `unassigned`
4. User membuka aplikasi PINTAR → pilih bangunan → klik “Tambah Alat”
5. Aplikasi menampilkan daftar perangkat yang belum dipasangkan
6. User memilih perangkat dan menghubungkannya ke bangunan terdaftar

---

## 📡 Pengiriman Data Sensor

Perangkat ESP32 secara berkala mengirimkan data sensor:

```json
{
  "device_id": "SENSOR_ABC123",
  "value": 6.8,
  "timestamp": "2025-07-01T10:00:00"
}
```

Firebase menyimpan dan menyinkronkan data ke aplikasi secara real-time.

---

## 🧠 Struktur Database Firebase (Firestore)

```json
"users": {
  "user_id": {
    "name": "Zhafif",
    "email": "...",
    "buildings": ["building_001"]
  }
},
"buildings": {
  "building_001": {
    "name": "Greenhouse 1",
    "devices": ["SENSOR_ABC123", "ACTUATOR_XYZ456"]
  }
},
"devices": {
  "SENSOR_ABC123": {
    "type": "sensor",
    "category": "pH",
    "status": true,
    "building_id": "building_001"
  }
}
```

---

## 📱 Struktur Halaman Aplikasi (Flutter)

- **Auth**: Login, Register, Forgot Password
- **Dashboard**: Data Sensor, Kontrol Aktuator, Toggle Otomatis
- **Bangunan**: Daftar Bangunan, Detail Bangunan, Tambah Perangkat
- **Device Detail**: Jadwal, Grafik, Log, Kontrol Manual
- **Statistik**: Grafik pH, suhu, kelembaban harian/bulanan
- **Pengaturan**: Profil, Notifikasi, Info Aplikasi

---

## 🚀 Teknologi yang Digunakan

- **Flutter** (Frontend Mobile)
- **Firebase Auth & Firestore** (Backend & Realtime DB)
- **MQTT (Mosquitto / HiveMQ)** untuk komunikasi real-time
- **ESP32 / NodeMCU** dengan sensor DHT22, pH Meter, pompa air, dsb

---

## 🎨 Desain & Prototype

- **UI/UX Design**: [Figma - PINTAR APP](https://www.figma.com/design/owNGkQ9JZ5e9nhhwmj92ET/PINTAR-APP?node-id=457-3773&t=tBxinTQEixz1bl8s-1)

---

## 📄 Lisensi

Aplikasi ini dikembangkan untuk tujuan sosial dan edukatif di bawah program PPK Ormawa 2025.
Lisensi bersifat terbuka dengan atribusi ke Tim HMTP Universitas Ahmad Dahlan.

---

## 📬 Kontak & Kontribusi

- **Pengembang Aplikasi**: Raja Zhafif Raditya Harahap
- **Perangkat & Alat**: Muhammad Ikhwan nur Sidik dan Siti Nurhayati
- **Email**: [bangz1504@gmail.com](mailto:bangz1504@gmail.com)
- **Instagram**: [PPKOHMTPUAD](https://www.instagram.com/ppkohmtp.uad/)

Jika Anda ingin berkontribusi dalam pengembangan aplikasi ini, silakan fork repo dan pull request! 💚
