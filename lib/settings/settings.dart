import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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
  String _pseudo;
  int _score;
  bool _isDisplayMode;

  @override
  void initState() {
    LocalUser.getAvatar().then((snapshot) => setState(() {
          _avatar = snapshot;
        }));
    LocalUser.getPseudo().then((snapshot) => setState(() {
          _pseudo = snapshot;
        }));
    LocalUser.getScore().then((snapshot) => setState(() {
          _score = snapshot;
        }));
    _isDisplayMode = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(FlutterI18n.translate(context, "settings_title")),
        actions: <Widget>[
          (isLoadingData())
              ? Container()
              : IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: toggleEditMode,
                ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          showButtons(),
        ],
      ),
    );
  }

  void toggleEditMode() {
    setState(() {
      _isDisplayMode = !_isDisplayMode;
    });
  }

  Widget showButtons() {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: (isLoadingData())
          ? showCircularProgress()
          : ListView(
              shrinkWrap: true,
              children: <Widget>[
                showLogo(),
                showPseudo(),
                showScore(),
                showPrimaryButton(),
                LanguageSelector(),
              ],
            ),
    );
  }

  Widget showCircularProgress() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SpinKitCircle(
            color: Colors.grey[800],
            size: 100,
          ),
          Text(
            "Chargement du profil..",
            style: TextStyle(fontSize: 20),
          ),
        ],
      ),
    );
  }

  bool isLoadingData() {
    return _avatar == null || _pseudo == null || _score == null;
  }

  Widget showLogo() {
    double size = MediaQuery.of(context).size.height / 6;
    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(_avatar),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(80.0),
          border: Border.all(
            color: Colors.white,
            width: 10.0,
          ),
        ),
      ),
    );
  }

  Widget showPseudo() {
    return Padding(
      padding: EdgeInsets.only(top: 15.0),
      child: Center(
        child: Text(
          _pseudo,
          style: TextStyle(
            fontFamily: 'Roboto',
            color: Colors.black,
            fontSize: 28.0,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget showScore() {
    return Visibility(
      visible: _isDisplayMode,
      child: Padding(
        padding: EdgeInsets.only(top: 15.0),
        child: Center(
          child: Container(
            height: 60.0,
            margin: EdgeInsets.only(top: 8.0),
            decoration: BoxDecoration(
              color: Color(0xFFEFF4F7),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      _score.toString(),
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Victoire${(_score == 1 ? '' : 's')}",
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        color: Colors.black,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w200,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget showPrimaryButton() {
    return Padding(
      padding: EdgeInsets.only(top: 15.0),
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
          ],
        ),
      ),
    );
  }
}
