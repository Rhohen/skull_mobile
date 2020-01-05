import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:skull_mobile/widgetTester.dart';
import 'jouer.dart';
import 'package:url_launcher/url_launcher.dart';

final databaseReference = FirebaseDatabase.instance.reference();

class AccueilPage extends StatelessWidget {
  static const routeName = '/AccueilPage';

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
              Navigator.pushNamed(context, JouerPage.routeName);
            },
            child: Text('Jouer', style: TextStyle(fontSize: 20)),
          ),
          RaisedButton(
            onPressed: () {
              Navigator.pushNamed(context, WidgetTester.routeName);
              //_launchURL();
            },
            child: Text('Règles', style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );
  }

  // ignore: unused_element
  _launchURL() async {
    const url = 'http://www.skull-and-roses.com/pdf/Skull_rules_Fr.pdf';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
