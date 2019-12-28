import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'rules.dart';
import 'jouer.dart';
import 'lobby/lobby.dart';
import 'package:url_launcher/url_launcher.dart';

final databaseReference = FirebaseDatabase.instance.reference();

class AccueilPage extends StatelessWidget {
  AccueilPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RaisedButton(
            onPressed: () {
              Navigator.push(
                  context,
                  PageTransition(
                      type: PageTransitionType.fade, child: JouerPage()));
            },
            child: Text('Jouer', style: TextStyle(fontSize: 20)),
          ),
          RaisedButton(
            onPressed: () {
              /*
              Navigator.push(
                  context,
                  PageTransition(
                      type: PageTransitionType.fade,
                      child: Lobby("-Lx7KJcaKvlwpe2z2dEp")));*/
              _launchURL();
            },
            child: Text('Règles', style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );
  }

  _launchURL() async {
    const url = 'http://www.skull-and-roses.com/pdf/Skull_rules_Us.pdf';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
