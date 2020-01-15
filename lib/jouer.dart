import 'package:flutter/material.dart';
import 'package:skull_mobile/creer.dart';
import 'package:skull_mobile/lobby/lobbyArguments.dart';
import 'package:skull_mobile/lobby/userModel.dart';
import 'package:skull_mobile/rejoindre.dart';
import 'lobby/lobby.dart';

class JouerPage extends StatelessWidget {
  static const routeName = '/JouerPage';

  JouerPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Jouer a Skull"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            RaisedButton(
              onPressed: () {
                Navigator.pushNamed(context, CreerPage.routeName);
              },
              child: Text('Créer partie', style: TextStyle(fontSize: 20)),
            ),
            RaisedButton(
              onPressed: () {
                Navigator.pushNamed(context, RejoindrePage.routeName);
              },
              child: Text('Rejoindre partie', style: TextStyle(fontSize: 20)),
            ),
            RaisedButton(
              color: Colors.blueAccent,
              textColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(18.0),
                  side: BorderSide(color: Colors.blue)),
              onPressed: () {
                LobbyArguments lobbyArgs = new LobbyArguments(
                  "-Lx7KJcaKvlwpe2z2dEp",
                  User.generate("admin"),
                  context,
                );
                Navigator.pushNamed(
                  context,
                  Lobby.routeName,
                  arguments: lobbyArgs,
                );
              },
              child: Text('[DEBUG] Pas touche c\'est à nico',
                  style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}
