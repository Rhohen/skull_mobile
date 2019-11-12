
import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  WelcomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const RaisedButton(
            onPressed: null,
            child: Text(
              'Jouer',
              style: TextStyle(fontSize: 20)
            ),
          ),
          const RaisedButton(
            onPressed: null,
            child: Text(
              'Règles',
              style: TextStyle(fontSize: 20)
            ),
          ),
        ],
      ),
    );
  }
}