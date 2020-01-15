import 'package:skull_mobile/lobby/userModel.dart';

class LobbyModel {
  String key;
  String name;
  String password;
  int nbPlayerMax;
  List<User> users = new List();

  LobbyModel(this.key, this.name, this.password, this.nbPlayerMax, this.users);

  factory LobbyModel.from(String key, Map<String, dynamic> json) {
    return new LobbyModel(key, json['name'], json['password'],
        json['nbPlayerMax'], json['users']);
  }
}
