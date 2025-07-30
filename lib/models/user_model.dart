import 'building_model.dart';

class UserModel {
  final String idUser;
  final String username;
  final String email;
  final String password;
  final List<BuildingModel> buildings;

  UserModel({
    required this.idUser,
    required this.username,
    required this.email,
    required this.password,
    required this.buildings,
  });
}
