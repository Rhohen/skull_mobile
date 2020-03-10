import 'package:skull_mobile/lobby/userModel.dart';

class LobbyModel {
  String key;
  String name;
  String password;
  int nbPlayerMax;

  LobbyModel(this.key, this.name, this.password, this.nbPlayerMax);

  factory LobbyModel.from(String key, Map<String, dynamic> json) {
    return new LobbyModel(
        key, json['name'], json['password'], json['nbPlayerMax']);
  }
}
