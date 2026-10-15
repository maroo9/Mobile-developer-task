
class UserModel {

  final String id;
  final String username;


  UserModel(
  this.id,
  this.username
      );
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      json['id'] ?? "",
      json['username'] ?? "",
    );
  }
}