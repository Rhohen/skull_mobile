import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:skull_mobile/lobby/userModel.dart';
import 'accueil.dart';
import 'lobby/lobby.dart';

class JouerPage extends StatelessWidget {
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
                onPressed: null,
                child: Text('Créer partie', style: TextStyle(fontSize: 20)),
              ),
              RaisedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.fade,
                      child: Lobby(
                          "-Lx7KJcaKvlwpe2z2dEp",
                          User.generate("admin"),
                          context), // TODO: Nico c'est à la classe Lobby que tu fileras l'id du salon pour le rejoindre
                    ),
                  );
                },
                child: Text('Rejoindre partie', style: TextStyle(fontSize: 20)),
              ),
            ],
          ),
        ));
  }
}
