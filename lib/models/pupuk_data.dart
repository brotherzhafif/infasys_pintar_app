class PupukData {
  final int menit;
  final int jam;
  final String hari;
  final int tanggal;
  final int bulan;
  final int tahun;
  final double nh3;
  final double suhu;
  final double tds;
  final double pH;

  PupukData({
    required this.menit,
    required this.jam,
    required this.hari,
    required this.tanggal,
    required this.bulan,
    required this.tahun,
    required this.nh3,
    required this.suhu,
    required this.tds,
    required this.pH,
  });

  factory PupukData.fromMap(Map<String, dynamic> map) {
    return PupukData(
      menit: map['Menit'] ?? 0,
      jam: map['Jam'] ?? 0,
      hari: map['Hari'] ?? "",
      tanggal: map['Tanggal'] ?? 0,
      bulan: map['Bulan'] ?? 0,
      tahun: map['Tahun'] ?? 0,
      nh3: (map['NH3'] ?? 0).toDouble(),
      suhu: (map['Suhu'] ?? 0).toDouble(),
      tds: (map['TDS'] ?? 0).toDouble(),
      pH: (map['pH'] ?? 0).toDouble(),
    );
  }
}
