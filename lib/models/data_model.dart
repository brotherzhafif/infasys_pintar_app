class DataModel {
  final String idData;
  final String idDevice;
  final Map<String, dynamic> value;
  final DateTime timestamp;

  DataModel({
    required this.idData,
    required this.idDevice,
    required this.value,
    required this.timestamp,
  });
}
