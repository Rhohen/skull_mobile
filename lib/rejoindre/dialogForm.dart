import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:skull_mobile/settings/localUser.dart';

import '../lobby/lobby.dart';
import '../lobby/lobbyArguments.dart';
import '../lobby/userModel.dart';

// ignore: must_be_immutable
class DialogForm extends StatefulWidget {
  String roomKey;
  String password;

  DialogForm(this.roomKey, this.password);

  @override
  _DialogForm createState() => _DialogForm(roomKey, password);
}

class _DialogForm extends State<DialogForm> {
  String roomKey;
  String password;

  String _inputPassword;

  bool _isPasswordInvalid = false;

  bool isLoading = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  _DialogForm(this.roomKey, this.password);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Rejoindre la partie ?"),
      content: Form(
        key: _formKey,
        autovalidate: _isPasswordInvalid,
        child: Visibility(
          visible: (this.password != null && this.password != ""),
          child: TextFormField(
            decoration: InputDecoration(
              hintText: 'Entrez le mot de passe',
              labelText: 'Mot de passe',
            ),
            obscureText: true,
            keyboardType: TextInputType.text,
            validator: _validatePassword,
            onChanged: (String value) {
              _inputPassword = value;
            },
          ),
        ),
      ),
      actions: <Widget>[
        (isLoading
            ? Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SpinKitPouringHourglass(color: Colors.grey[800]),
                    Text("Connexion..."),
                  ],
                ),
              )
            : Container(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      RaisedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.cancel),
                        label: Text('Annuler'),
                      ),
                      RaisedButton.icon(
                        label: Text('Valider'),
                        icon: Icon(Icons.check),
                        onPressed: () => _submit(context),
                      ),
                    ],
                  ),
                ),
              )),
      ],
    );
  }

  String _validatePseudo(String value) {
    if (value.length < 3) {
      return 'Votre pseudo doit faire au moins 3 charactères';
    } else {
      return null;
    }
  }

  String _validatePassword(String password) {
    if (_isPasswordInvalid) {
      _isPasswordInvalid = false;
      return 'Mot de passe erroné';
    } else {
      return null;
    }
  }

  void _submit(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    if (_formKey.currentState.validate()) {
      if (this.password != null && this.password != "") {
        if (this.password == this._inputPassword) {
          LocalUser().getUser().then((userValue) {
            User user = userValue;
            user.isOwner = 'true';
            LobbyArguments lobbyArgs = new LobbyArguments(
              this.roomKey,
              user,
              context,
            );
            Navigator.pushNamed(context, Lobby.routeName, arguments: lobbyArgs);
          });
        } else {
          this._isPasswordInvalid = true;
        }
      } else {
        LocalUser().getUser().then((userValue) {
          User user = userValue;
          user.isOwner = 'true';
          LobbyArguments lobbyArgs = new LobbyArguments(
            this.roomKey,
            user,
            context,
          );
          Navigator.pushNamed(context, Lobby.routeName, arguments: lobbyArgs);
        });
      }
    }
  }

  Future<String> getPseudo() async {
    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    final pseudo = await FirebaseDatabase.instance
        .reference()
        .child('users')
        .child(user.uid)
        .child('pseudo')
        .once();
    return pseudo.value;
  }
}
