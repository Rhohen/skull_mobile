import 'package:skull_mobile/lobby/userModel.dart';

class LobbyModel {
  String key;
  String name;
  String password;
  int nbPlayerMax;
  int nbPlayers;

  LobbyModel(this.key, this.name, this.password, this.nbPlayerMax);

  factory LobbyModel.from(String key, Map<String, dynamic> json) {
    return new LobbyModel(
        key, json['name'], json['password'], json['nbPlayerMax']);
  }

  set(int _nbPlayers) => nbPlayers = _nbPlayers;
}
