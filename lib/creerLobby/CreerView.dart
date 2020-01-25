import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CreerPageView {
  Future<bool> getAwesomeDialog(BuildContext context) {
    return AwesomeDialog(
        context: context,
        dialogType: DialogType.WARNING,
        animType: AnimType.TOPSLIDE,
        tittle: 'Vous êtes sûr ?',
        desc: 'Les paramètres ne seront pas sauvegardés',
        btnCancelOnPress: () {},
        btnOkOnPress: () {
          Navigator.pop(context);
        }).show();
  }

  getNameDecorator() {
    return InputDecoration(
      labelText: 'Nom de la partie',
      labelStyle: TextStyle(color: Colors.grey[700]),
      enabledBorder:
          UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[700])),
      focusedBorder:
          UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[700])),
    );
  }

  getPasswordDecorator() {
    return InputDecoration(
      labelText: 'Mot de passe',
      labelStyle: TextStyle(color: Colors.grey[700]),
      enabledBorder:
          UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[700])),
      focusedBorder:
          UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[700])),
    );
  }

  Widget getNumberPlayerText() {
    return Text(
      '\n Nombre de joueurs Max:',
      style: TextStyle(
        fontSize: 17,
        color: Colors.grey[700],
      ),
    );
  }

  Widget getImage(String path, double logoSize) {
    return Image(
      image: AssetImage(path),
      height: logoSize,
      width: logoSize,
    );
  }

  Widget getHourglassLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SpinKitPouringHourglass(color: Colors.grey[800]),
          Text("Création de la partie..."),
        ],
      ),
    );
  }

  Widget getSubmitButtonText() {
    return Text(
      'Créer la Partie',
      style: TextStyle(fontSize: 20),
    );
  }
}
