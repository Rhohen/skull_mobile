import 'package:flutter/material.dart';
import 'jouer.dart';

class WelcomePage extends StatelessWidget {
  WelcomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Skull Mobile",
            style: TextStyle(fontSize: 20),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              RaisedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => JouerPage()),
                  );
                },
                child: Text('Jouer', style: TextStyle(fontSize: 20)),
              ),
              RaisedButton(
                onPressed: null,
                child: Text('Règles', style: TextStyle(fontSize: 20)),
              ),
            ],
          ),
        ));
  }
}
