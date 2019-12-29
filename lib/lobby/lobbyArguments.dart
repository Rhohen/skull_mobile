import 'package:skull_mobile/lobby/userModel.dart';
import 'package:flutter/material.dart';

class LobbyArguments {
  final String lobbyId;
  final User currentUser;
  final BuildContext lobbiesContext;

  LobbyArguments(this.lobbyId, this.currentUser, this.lobbiesContext);
}
