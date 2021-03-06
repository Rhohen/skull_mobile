import 'package:flutter/material.dart';
import 'package:skull_mobile/creerLobby/creer.dart';
import 'package:skull_mobile/lobby/lobbyArguments.dart';
import 'package:skull_mobile/rejoindre/rejoindre.dart';
import 'package:skull_mobile/settings/localUser.dart';
import 'lobby/lobby.dart';

class JouerPage extends StatelessWidget {
  static const routeName = '/JouerPage';

  JouerPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Jouer a Skull"),
        backgroundColor: Colors.grey[800],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            RaisedButton(
              elevation: 5.0,
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0)),
              color: Colors.grey[800],
              onPressed: () {
                Navigator.pushNamed(context, CreerPage.routeName);
              },
              child: Text(
                'Créer partie',
                style: new TextStyle(fontSize: 20.0, color: Colors.white),
              ),
            ),
            RaisedButton(
              elevation: 5.0,
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0)),
              color: Colors.grey[800],
              onPressed: () {
                Navigator.pushNamed(context, RejoindrePage.routeName);
              },
              child: Text(
                'Rejoindre partie',
                style: new TextStyle(fontSize: 20.0, color: Colors.white),
              ),
            ),
            Opacity(
              opacity: 0.0,
              child: RaisedButton(
                color: Colors.blueAccent,
                textColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(18.0),
                    side: BorderSide(color: Colors.blue)),
                onPressed: () {
                  LocalUser().getUser().then((userValue) {
                    LobbyArguments lobbyArgs = new LobbyArguments(
                      "-Lx7KJcaKvlwpe2z2dEp",
                      userValue,
                      context,
                    );
                    Navigator.pushNamed(
                      context,
                      Lobby.routeName,
                      arguments: lobbyArgs,
                    );
                  });
                },
                child: Text(
                  '[DEBUG] Pas touche c\'est à nico',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
