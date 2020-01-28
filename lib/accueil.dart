import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:skull_mobile/connexion/login.dart';
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
  String _pseudo;

  

  @override
  void initState() {
    _pseudo = "";
    this.getCurrentUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(_pseudo),
        actions: <Widget>[
          FlatButton(
            child: Text("Log out"),
            onPressed: () {
              logout();
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

  Widget showLogo() {
    return new Container(
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
            child: Text('Jouer',
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

  void getCurrentUserInfo() {
    FirebaseAuth.instance.currentUser().then((user) => {
          FirebaseDatabase.instance
              .reference()
              .child('users')
              .child(user.uid)
              .child('pseudo')
              .once()
              .then((pseudo) => {
                    setState(() {
                      _pseudo = pseudo.value;
                    })
                  })
        });
  }

  void logout() {
    FirebaseAuth.instance
        .signOut()
        .then((onValue) => {Navigator.pushNamed(context, LoginPage.routeName)});
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
