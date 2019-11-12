import 'package:flutter/material.dart';
import 'accueil.dart';

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
                onPressed: null,
                child: Text('Rejoindre partie', style: TextStyle(fontSize: 20)),
              ),
            ],
          ),
        ));
  }
}
