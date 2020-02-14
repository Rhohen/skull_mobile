import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:skull_mobile/settings/localUser.dart';
import 'package:skull_mobile/settings/profil/profil.dart';

import '../glowRemover.dart';
import 'languageSelector.dart';

class SettingsPage extends StatefulWidget {
  static const routeName = '/SettingsPage';

  @override
  State<StatefulWidget> createState() => new _SettingsPage();
}

class _SettingsPage extends State<SettingsPage> {
  bool _isDisplayMode;

  @override
  void initState() {
    LocalUser().getAvatar().then((snapshot) => setState(() {}));
    LocalUser().getPseudo().then((snapshot) => setState(() {}));
    LocalUser().getScore().then((snapshot) => setState(() {}));
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
                  onPressed: () => toggleEditMode(false),
                ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          (_isDisplayMode) ? showDisplayMode() : showEditMode(),
        ],
      ),
    );
  }

  void toggleEditMode(bool forceRefresh) {
    setState(() {
      _isDisplayMode = !_isDisplayMode;
      if (forceRefresh) {
        refreshProfile();
      }
    });
  }

  void disableToggleMode() {
    setState(() {
      LocalUser().setLocalPseudo("");
      LocalUser().setLocalAvatar("");
    });
  }

  void refreshProfile() {
    LocalUser().getAvatar().then((snapshot) => setState(() {}));
    LocalUser().getPseudo().then((snapshot) => setState(() {}));
  }

  Widget showEditMode() {
    return ProfilPage(LocalUser().getLocalAvatar(),
        LocalUser().getLocalPseudo(), toggleEditMode, disableToggleMode);
  }

  Widget showDisplayMode() {
    return Container(
      padding: EdgeInsets.only(left: 16.0, right: 16.0),
      child: (isLoadingData())
          ? showCircularProgress()
          : ScrollConfiguration(
              behavior: GlowRemover(),
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  SizedBox(height: 20),
                  showLogo(),
                  showPseudo(),
                  showScore(),
                  LanguageSelector(),
                ],
              ),
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
    return LocalUser().getLocalAvatar().isEmpty ||
        LocalUser().getLocalPseudo().isEmpty ||
        LocalUser().getLocalScore() < 0;
  }

  Widget showLogo() {
    double size = MediaQuery.of(context).size.height / 6;
    if (MediaQuery.of(context).orientation != Orientation.portrait) {
      size = MediaQuery.of(context).size.width / 6;
    }

    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(LocalUser().getLocalAvatar()),
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
          LocalUser().getLocalPseudo(),
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
                      LocalUser().getLocalScore().toString(),
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Victoire${(LocalUser().getLocalScore() == 1 ? '' : 's')}",
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
}
