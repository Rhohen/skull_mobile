import 'package:flutter/material.dart';

import '../game.dart';

// ignore: must_be_immutable
class DefiDialog extends StatelessWidget {
  int nbRosesMax;

  TextEditingController _inputNbRose;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  var sendHasBetNotification;

  int initBetValue;

  DefiDialog(this.initBetValue, this.nbRosesMax, this.sendHasBetNotification);

  @override
  Widget build(BuildContext context) {
    _inputNbRose = TextEditingController(text: initBetValue.toString());
    return new AlertDialog(
      title: new Text("Nombre de roses que vous pensez trouver : "),
      content: new Form(
        key: _formKey,
        child: new Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new RaisedButton(
              elevation: 5.0,
              shape: new CircleBorder(),
              child: new Icon(Icons.remove_circle),
              onPressed: () {
                minus();
              },
            ),
            new Container(
                width: 25,
                child: TextFormField(
                  controller: _inputNbRose,
                  keyboardType: TextInputType.number,
                  validator: _validateNbRoses,
                  onSaved: (String value) {
                    _inputNbRose.text = value;
                  },
                )),
            new RaisedButton(
              elevation: 5.0,
              shape: new CircleBorder(),
              child: new Icon(Icons.add_circle),
              onPressed: () {
                plus();
              },
            ),
          ],
        ),
      ),
      actions: <Widget>[
        RaisedButton.icon(
          onPressed: () {
            Navigator.pop(context);
          },
          color: Colors.grey,
          icon: Icon(Icons.cancel),
          label: Text('Annuler'),
        ),
        RaisedButton.icon(
          label: Text('Valider'),
          color: Colors.blue,
          icon: Icon(Icons.check),
          onPressed: () => _submit(context),
        )
      ],
    );
  }

  String _validateNbRoses(String value) {
    if (int.parse(value) > nbRosesMax) {
      return "Il n'y a pas autant de cartes sur la table";
    } else {
      return null;
    }
  }

  void minus() {
    int value = int.parse(_inputNbRose.text);
    value = (value == initBetValue ? nbRosesMax : value - 1);
    _inputNbRose.text = value.toString();
  }

  void plus() {
    int value = int.parse(_inputNbRose.text);
    value = (value == nbRosesMax ? initBetValue : value + 1);
    _inputNbRose.text = value.toString();
  }

  void _submit(BuildContext context) {
    if (_formKey.currentState.validate()) {
      Navigator.popUntil(context, ModalRoute.withName(GamePage.routeName));
      sendHasBetNotification(_inputNbRose.text);
    }
  }
}
