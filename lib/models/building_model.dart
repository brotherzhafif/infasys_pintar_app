import 'device_model.dart';

class BuildingModel {
  final String idBuilding;
  final String idUser;
  final String buildingName;
  final String location;
  final String urlImages;
  final List<DeviceModel> devices;

  BuildingModel({
    required this.idBuilding,
    required this.idUser,
    required this.buildingName,
    required this.location,
    required this.urlImages,
    required this.devices,
  });
}
