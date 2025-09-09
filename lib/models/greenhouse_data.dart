class GreenhouseData {
  final int menit;
  final int jam;
  final String hari;
  final int tanggal;
  final int bulan;
  final int tahun;
  final double kelembapanUdara;
  final double suhuUdara;
  final double soilMoist;
  final double soilTemp;
  final double soilpH;
  final double soilEC;
  final double tds;
  final double soilN;
  final double soilP;
  final double soilK;

  GreenhouseData({
    required this.menit,
    required this.jam,
    required this.hari,
    required this.tanggal,
    required this.bulan,
    required this.tahun,
    required this.kelembapanUdara,
    required this.suhuUdara,
    required this.soilMoist,
    required this.soilTemp,
    required this.soilpH,
    required this.soilEC,
    required this.tds,
    required this.soilN,
    required this.soilP,
    required this.soilK,
  });

  factory GreenhouseData.fromMap(Map<String, dynamic> map) {
    return GreenhouseData(
      menit: map['Menit'] ?? 0,
      jam: map['Jam'] ?? 0,
      hari: map['Hari'] ?? "",
      tanggal: map['Tanggal'] ?? 0,
      bulan: map['Bulan'] ?? 0,
      tahun: map['Tahun'] ?? 0,
      kelembapanUdara: (map['KelembapanUdara'] ?? 0).toDouble(),
      suhuUdara: (map['SuhuUdara'] ?? 0).toDouble(),
      soilMoist: (map['SoilMoist'] ?? 0).toDouble(),
      soilTemp: (map['SoilTemp'] ?? 0).toDouble(),
      soilpH: (map['SoilpH'] ?? 0).toDouble(),
      soilEC: (map['SoilEC'] ?? 0).toDouble(),
      tds: (map['TDS'] ?? 0).toDouble(),
      soilN: (map['SoilN'] ?? 0).toDouble(),
      soilP: (map['SoilP'] ?? 0).toDouble(),
      soilK: (map['SoilK'] ?? 0).toDouble(),
    );
  }
}
