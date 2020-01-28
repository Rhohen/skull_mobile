import 'package:flutter/material.dart';

class DefiDialog extends StatelessWidget {
  int nbRosesMax;

  TextEditingController _inputNbRose = TextEditingController(text: "1");

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  DefiDialog(this.nbRosesMax);

  @override
  Widget build(BuildContext context) {
    return new AlertDialog(
      title: new Text("Nombre de roses que vous pensez trouvez : "),
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
                  keyboardType: TextInputType.text,
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
    value = (value == 1 ? nbRosesMax : value - 1);
    _inputNbRose.text = value.toString();
  }

  void plus() {
    int value = int.parse(_inputNbRose.text);
    value = (value % nbRosesMax) + 1;
    _inputNbRose.text = value.toString();
  }

  void _submit(BuildContext context) {
    if (_formKey.currentState.validate()) {
      Navigator.pop(context);
    }
  }
}
