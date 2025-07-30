class ScheduleModel {
  final String idSchedule;
  final String idDevice;
  final String time; // Use String or TimeOfDay
  final String repeat; // Daily, Weekly, Monthly
  final double threshold;

  ScheduleModel({
    required this.idSchedule,
    required this.idDevice,
    required this.time,
    required this.repeat,
    required this.threshold,
  });
}
