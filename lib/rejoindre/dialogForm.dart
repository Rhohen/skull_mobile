import 'package:flutter/material.dart';

import '../lobby/lobby.dart';
import '../lobby/lobbyArguments.dart';
import '../lobby/userModel.dart';

// ignore: must_be_immutable
class DialogForm extends StatelessWidget {
  String roomKey;
  String password;

  String _pseudo;
  String _inputPassword;

  bool _isPasswordInvalid = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  DialogForm(this.roomKey, this.password);

  @override
  Widget build(BuildContext context) {
    return new AlertDialog(
      content: new Form(
        key: _formKey,
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new TextFormField(
              decoration: InputDecoration(
                  hintText: 'Entrez un pseudo', labelText: 'Pseudo'),
              keyboardType: TextInputType.text,
              validator: _validatePseudo,
              onSaved: (String value) {
                _pseudo = value;
              },
            ),
            new Visibility(
              visible: (this.password != null && this.password != ""),
              child: new TextFormField(
                decoration: InputDecoration(
                    hintText: 'Entrez le mot de passe',
                    labelText: 'Mot de passe'),
                obscureText: true,
                validator: _validatePassword,
                onSaved: (String value) {
                  _inputPassword = value;
                },
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
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
        )
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

  void _submit(BuildContext context) {
    if (_formKey.currentState.validate()) {
      if (this.password != null && this.password != "") {
        if (this.password == this._inputPassword) {
          Navigator.pushNamed(context, Lobby.routeName,
              arguments: new LobbyArguments(
                  this.roomKey, User.generate(_pseudo), context));
        } else {
          this._isPasswordInvalid = true;
        }
      } else {
        Navigator.pushNamed(context, Lobby.routeName,
            arguments: new LobbyArguments(
                this.roomKey, User.generate(_pseudo), context));
      }
    }
  }
}
