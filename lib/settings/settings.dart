import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:skull_mobile/settings/localUser.dart';
import 'package:skull_mobile/settings/profil/profil.dart';

import 'languageSelector.dart';

class SettingsPage extends StatefulWidget {
  static const routeName = '/SettingsPage';

  @override
  State<StatefulWidget> createState() => new _SettingsPage();
}

class _SettingsPage extends State<SettingsPage> {
  String _avatar;

  @override
  void initState() {
    _avatar = "assets/skull.png";
    LocalUser.getAvatar().then((user) => setState(() {
          _avatar = user;
        }));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(FlutterI18n.translate(context, "settings_title")),
      ),
      body: Stack(
        children: <Widget>[
          showButtons(),
        ],
      ),
    );
  }

  Widget showButtons() {
    return new Container(
      padding: EdgeInsets.all(16.0),
      child: new ListView(
        shrinkWrap: true,
        children: <Widget>[
          showLogo(),
          showPrimaryButton(),
        ],
      ),
    );
  }

  Widget showLogo() {
    return new Hero(
      tag: 'hero',
      child: Padding(
        padding: EdgeInsets.fromLTRB(0.0, 25.0, 0.0, 0.0),
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 48.0,
          child: Image.asset(_avatar),
        ),
      ),
    );
  }

  Widget showPrimaryButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
        child: SizedBox(
          child: new Column(
            children: <Widget>[
              new RaisedButton(
                elevation: 5.0,
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0)),
                color: Colors.blue,
                child: new Text('Profil',
                    style: new TextStyle(fontSize: 20.0, color: Colors.white)),
                onPressed: () {
                  Navigator.pushNamed(context, ProfilPage.routeName);
                },
              ),
              new LanguageSelector()
            ],
          ),
        ));
  }
}
