import 'schedule_model.dart';
import 'data_model.dart';

enum DeviceType { Sensor, Actuator }

enum DeviceCategory { suhu, ph, irigasi, lainnya }

class DeviceModel {
  final String idDevice;
  final String idBuilding;
  final String deviceName;
  final DeviceType type;
  final DeviceCategory category;
  final bool status;
  final double sensitivity;
  final List<ScheduleModel> schedules;
  final List<DataModel> data;
  final DataModel? lastData;

  DeviceModel({
    required this.idDevice,
    required this.idBuilding,
    required this.deviceName,
    required this.type,
    required this.category,
    required this.status,
    required this.sensitivity,
    required this.schedules,
    required this.data,
    this.lastData,
  });
}
