class UserModel {
  final String id;
  final String name;
  final String email;
  final List<String> buildings;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.buildings,
  });
}
