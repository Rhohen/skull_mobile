import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:skull_mobile/game/EGameState.dart';
import 'package:skull_mobile/settings/localUser.dart';
import 'package:toast/toast.dart';
import '../glowRemover.dart';
import '../lobby/lobby.dart';
import '../lobby/lobbyArguments.dart';
import '../lobby/userModel.dart';
import 'CreerView.dart';

//Create a Form Widget
class CreerPage extends StatefulWidget {
  static const routeName = '/CreerPage';

  CreerPage({Key key}) : super(key: key);

  @override
  _CreerPage createState() => _CreerPage();
}

class _CreerPage extends State<CreerPage> {
  GlobalKey<FormState> _key = new GlobalKey();
  bool _validate = false;
  String name, password;
  double nbPlayerMax = 10;
  bool isLoading;
  DatabaseReference lobbyRef;
  CreerPageView view = new CreerPageView();

  @override
  void initState() {
    super.initState();
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          return view.getAwesomeDialog(context);
        },
        child: Scaffold(
            appBar: AppBar(
              title: Text('Créer une Partie', style: TextStyle(fontSize: 20)),
              backgroundColor: Colors.grey[800],
              leading: new IconButton(
                icon: new Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => AwesomeDialog(
                    context: context,
                    dialogType: DialogType.WARNING,
                    animType: AnimType.TOPSLIDE,
                    tittle: 'Vous êtes sûr ?',
                    desc: 'Les paramètres ne seront pas sauvegardés',
                    btnCancelOnPress: () {},
                    btnOkOnPress: () {
                      Navigator.pop(context);
                    }).show(),
              ),
            ),
            body: ScrollConfiguration(
              behavior: GlowRemover(),
              child: Container(
                margin: EdgeInsets.only(left: 46.0, right: 46.0),
                child: Form(
                  key: _key,
                  autovalidate: _validate,
                  child: formUI(),
                ),
              ),
            )));
  }

  Widget formUI() {
    double logoSize = MediaQuery.of(context).size.height * 0.3;
    return Container(
      alignment: Alignment.center,
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(8.0),
        children: <Widget>[
          view.getImage('assets/skull.png', logoSize),
          TextFormField(
            decoration: view.getNameDecorator(),
            maxLength: 32,
            validator: validateName,
            onSaved: (String val) {
              name = val;
            },
          ),
          TextFormField(
              decoration: view.getPasswordDecorator(),
              keyboardType: TextInputType.text,
              maxLength: 32,
              onSaved: (String val) {
                password = val;
              }),
          Container(child: view.getNumberPlayerText()),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Slider(
                activeColor: Colors.grey[800],
                inactiveColor: Colors.grey[400],
                min: 3,
                max: 10,
                onChanged: (_value) {
                  setState(() => nbPlayerMax = _value);
                },
                value: nbPlayerMax,
              ),
              Text(nbPlayerMax.toInt().toString()),
            ],
          ),
          SizedBox(height: 15.0),
          _submitButton(context),
        ],
      ),
    );
  }

  _submitButton(BuildContext context) {
    return isLoading
        ? view.getHourglassLoading()
        : RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(30.0),
            ),
            onPressed: () => _submit(context),
            //createLobby(),
            textColor: Colors.white,
            color: Colors.grey[800],
            child: view.getSubmitButtonText(),
          );
  }

  _submit(BuildContext context) {
    if (_key.currentState.validate()) {
      // No any error in validation
      _key.currentState.save();
      _createLobby(context);
    } else {
      // validation error
      setState(() {
        _validate = true;
      });
    }
  }

  _createLobby(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    final FirebaseDatabase database = FirebaseDatabase.instance;
    lobbyRef = database.reference().child('lobbies').push();
    lobbyRef
        .set({
          "name": name,
          "password": password,
          "nbPlayerMax": nbPlayerMax.toInt(),
          "state": EGameState.INITIALIZING,
        })
        .whenComplete(() => {_redirectToLobby(context, lobbyRef.key)})
        .timeout(Duration(seconds: 5), onTimeout: () {
          setState(() {
            isLoading = false;
          });
          Toast.show("Erreur de connexion avec la base de données", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        });
  }

  _redirectToLobby(BuildContext context, String id) async {
    LocalUser().getUser().then((userValue) {
      User user = userValue;
      user.isOwner = 'true';
      LobbyArguments lobbyArgs = new LobbyArguments(
        id,
        user,
        context,
      );
      Navigator.pushNamed(context, Lobby.routeName, arguments: lobbyArgs);
    });
  }

  String validateName(String value) {
    if (value.length == 0) {
      return "Le nom est obligatoire";
    }
    return null;
  }
}
