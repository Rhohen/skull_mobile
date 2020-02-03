import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:skull_mobile/settings/localUser.dart';

import 'avatarSelector.dart';

class ProfilPage extends StatefulWidget {
  static const routeName = '/ProfilPage';

  final String avatar;
  final String pseudo;
  var toggleEditMode;
  var disableToggleMode;

  ProfilPage(
      this.avatar, this.pseudo, this.toggleEditMode, this.disableToggleMode);

  @override
  State<StatefulWidget> createState() => new _ProfilPage(
      this.avatar, this.pseudo, this.toggleEditMode, this.disableToggleMode);
}

class _ProfilPage extends State<ProfilPage> {
  TextEditingController _pseudo = TextEditingController();

  String avatar;
  final String pseudo;
  String _errorMessage;
  bool isLoading;
  var toggleEditMode;
  var disableToggleMode;

  _ProfilPage(
      this.avatar, this.pseudo, this.toggleEditMode, this.disableToggleMode);

  @override
  void initState() {
    isLoading = false;
    _pseudo.text = pseudo;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return (isLoading)
        ? showCircularProgress()
        : Container(
            padding: EdgeInsets.all(16.0),
            child: new ListView(
              shrinkWrap: true,
              children: <Widget>[
                AvatarSelector(sendAvatar, avatar),
                pseudoEditor(),
                saveButton(),
                showErrorMessage()
              ],
            ),
          );
  }

  Widget pseudoEditor() {
    return Padding(
      padding: EdgeInsets.only(top: 15.0),
      child: Center(
        child: TextFormField(
          maxLength: 10,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Roboto',
            color: Colors.black,
            fontSize: 28.0,
            fontWeight: FontWeight.w700,
          ),
          controller: _pseudo,
          keyboardType: TextInputType.text,
          onSaved: (String value) {
            _pseudo.text = value;
          },
        ),
      ),
    );
  }

  Widget saveButton() {
    return RaisedButton.icon(
      elevation: 5.0,
      shape: new RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(30.0)),
      color: Colors.blue,
      icon: Icon(
        Icons.check,
        color: Colors.white,
      ),
      onPressed: () => _submit(context),
      label: Text(
        FlutterI18n.translate(context, "valider"),
        style: new TextStyle(fontSize: 20.0, color: Colors.white),
      ),
    );
  }

  void _submit(BuildContext context) {
    setState(() {
      _errorMessage = "";
    });
    if (avatar != null && avatar != '') {
      if (_pseudo.text != null && _pseudo.text.length > 3) {
        isLoading = true;
        disableToggleMode();
        LocalUser().setPseudo(_pseudo.text).whenComplete(() {
          LocalUser().setAvatar(avatar).whenComplete(() {
            isLoading = false;
            toggleEditMode(true);
          });
        });
      } else {
        _errorMessage = "Le pseudo choisi est trop petit";
      }
    } else {
      _errorMessage = "L'avatar choisie est incorrect";
    }
  }

  sendAvatar(String value) {
    avatar = value;
  }

  Widget showErrorMessage() {
    if (_errorMessage != null && _errorMessage.length > 0) {
      return new Text(
        _errorMessage,
        style: TextStyle(
          fontSize: 13.0,
          color: Colors.red,
          height: 1.0,
          fontWeight: FontWeight.w300,
        ),
      );
    } else {
      return new Container(
        height: 0.0,
      );
    }
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
}
