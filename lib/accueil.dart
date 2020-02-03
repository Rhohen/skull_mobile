import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:skull_mobile/settings/localUser.dart';
import 'package:skull_mobile/settings/settings.dart';
import 'MenuItems.dart';
import 'jouer.dart';
import 'package:url_launcher/url_launcher.dart';

final databaseReference = FirebaseDatabase.instance.reference();

class AccueilPage extends StatefulWidget {
  static const routeName = '/AccueilPage';

  AccueilPage({Key key}) : super(key: key);

  @override
  _AcceuilPage createState() => _AcceuilPage();
}

class _AcceuilPage extends State<AccueilPage> {
  @override
  void initState() {
    LocalUser().getPseudo().then((onValue) => setState(() {}));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(LocalUser().getLocalPseudo()),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: choiceAction,
            itemBuilder: (BuildContext context) {
              return MenuItems.choices.entries.map((elem) {
                return PopupMenuItem<String>(
                  value: elem.key,
                  child: MenuItems.rowItem(elem.key, elem.value),
                );
              }).toList();
            },
          )
        ],
      ),
      body: Stack(
        children: <Widget>[
          accessButtons(context),
        ],
      ),
    );
  }

  void choiceAction(String choice) {
    if (choice == MenuItems.Profile) {
      Navigator.pushNamed(context, SettingsPage.routeName);
    } else if (choice == MenuItems.SignOut) {
      LocalUser().logout(context);
    }
  }

  Widget showLogo() {
    return Container(
      child: Padding(
        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 25.0),
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 48.0,
          child: Image.asset('assets/skull.png'),
        ),
      ),
    );
  }

  Widget accessButtons(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          showLogo(),
          RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.blue,
            onPressed: () {
              Navigator.pushNamed(context, JouerPage.routeName);
            },
            child: Text(FlutterI18n.translate(context, "jouer"),
                style: new TextStyle(fontSize: 20.0, color: Colors.white)),
          ),
          RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.grey,
            onPressed: () {
              //Navigator.pushNamed(context, WidgetTester.routeName);
              _launchURL();
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
