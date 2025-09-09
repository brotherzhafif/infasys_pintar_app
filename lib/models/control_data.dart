class ControlData {
  final String lampuDalam;
  final String lampuLuar;
  final String pompaAir;
  final int pompaAirDuration;
  final int pompaDuration;
  final String pompaPupuk;
  final int pompaPupukDuration;
  final String pompaUdara;
  final int pompaUdaraDuration;

  ControlData({
    required this.lampuDalam,
    required this.lampuLuar,
    required this.pompaAir,
    required this.pompaAirDuration,
    required this.pompaDuration,
    required this.pompaPupuk,
    required this.pompaPupukDuration,
    required this.pompaUdara,
    required this.pompaUdaraDuration,
  });

  factory ControlData.fromMap(Map<String, dynamic> map) {
    return ControlData(
      lampuDalam: map['lampu_dalam'] ?? "off",
      lampuLuar: map['lampu_luar'] ?? "off",
      pompaAir: map['pompa_air'] ?? "off",
      pompaAirDuration: map['pompa_air_duration'] ?? 30,
      pompaDuration: map['pompa_duration'] ?? 30,
      pompaPupuk: map['pompa_pupuk'] ?? "off",
      pompaPupukDuration: map['pompa_pupuk_duration'] ?? 30,
      pompaUdara: map['pompa_udara'] ?? "off",
      pompaUdaraDuration: map['pompa_udara_duration'] ?? 30,
    );
  }
}
