import 'package:awesome_dialog/animated_button.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:page_transition/page_transition.dart';
import 'package:skull_mobile/jouer.dart';
import 'package:skull_mobile/lobby/devFloatingButton.dart';
import 'userModel.dart';
import 'userCard.dart';
import 'package:firebase_database/firebase_database.dart';
// ignore: unused_import
import 'dart:developer' as LOGGER;

class Lobby extends StatefulWidget {
  final String lobbyId;
  final User currentUser;
  final BuildContext lobbiesContext;

  Lobby(this.lobbyId, this.currentUser, this.lobbiesContext);

  @override
  _Lobby createState() => _Lobby(lobbyId, currentUser, lobbiesContext);
}

class _Lobby extends State<Lobby> {
  DatabaseReference lobbyRef;
  String lobbyId;
  List<User> users;
  User currentUser;
  BuildContext lobbiesContext;

  _Lobby(this.lobbyId, this.currentUser, this.lobbiesContext);

  @override
  void initState() {
    super.initState();
    final FirebaseDatabase database = FirebaseDatabase.instance;

    lobbyRef = database.reference().child('lobbies').child(lobbyId);

    var generatedReference = lobbyRef.push();
    currentUser.key = generatedReference.key;
    generatedReference.set(currentUser.toJson());

    lobbyRef.onChildAdded.listen(_onEntryAddedUser);
    lobbyRef.onChildChanged.listen(_onEntryChangedUser);
    lobbyRef.onChildRemoved.listen(_onEntryRemovedUser);
    lobbyRef.onChildMoved.listen(_onChildMovedUser);
  }

  _onEntryAddedUser(Event event) {}

  _onEntryChangedUser(Event event) {
    if (this.mounted) {
      if (event.snapshot != null &&
          currentUser != null &&
          currentUser.key == event.snapshot.key) setState(() {});
    }
  }

  Future<bool> _onBackPressed() {
    return AwesomeDialog(
        context: context,
        dialogType: DialogType.WARNING,
        animType: AnimType.TOPSLIDE,
        tittle: 'Are you sure?',
        desc: 'You are going to exit the lobby.',
        btnCancelOnPress: () {},
        btnOkOnPress: () {
          lobbyRef.child(currentUser.key).remove();
          // FIXME: Il va falloir trouver un moyen de gérer la navigation plus proprement, actuellement ça s'ajoute à l'infini
          Navigator.pop(
            context,
            PageTransition(
              type: PageTransitionType.fade,
              child: JouerPage(),
            ),
          );
        }).show();
  }

  _onEntryRemovedUser(Event event) {
    if (this.mounted) {
      if (event.snapshot != null &&
          currentUser != null &&
          currentUser.key == event.snapshot.key) {
        // FIXME: Il va falloir trouver un moyen de gérer la navigation plus proprement, actuellement ça s'ajoute à l'infini
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => JouerPage()));
      }
    }
  }

  _onChildMovedUser(Event event) {}

  //TODO : Ce sera possible de gérer l'attribution automatique du isOwner (Dans un salon vide ou lorsque l'owner part) lorsqu'il y aura eu la mise en place de sessions
/*
  bool _isUserOwner(String key) {
    assert(key != null);
    for (int index = 0; index < users.length; index++) {
      Map userData = new Map<String, dynamic>.from(users[index]);
      User user = User.from(userData);
      if (key == user.key) {
        return user.isOwner.toLowerCase() == 'true';
      }
    }
    return false;
  }

  bool _isLobbyEmpty() {
    LOGGER.log("lobby : ${users.length <= 1}");
    return users.length <= 1;
  }

  _onEntryRemovedUser(Event event) {
    if (this.mounted) {
      bool isOwner = _isUserOwner(event.snapshot.key);
      if (isOwner) {
        lobbyRef.once().then(
          (DataSnapshot snapshot) {
            if (snapshot != null && snapshot.value != null) {
              Map lobbyMap = new Map<String, dynamic>.from(snapshot.value);
              lobbyMap.removeWhere((k, v) {
                return k == event.snapshot.key;
              });

              String firstKey = lobbyMap.keys.first;
              if (firstKey != null) {
                Map userData =
                    new Map<String, dynamic>.from(lobbyMap[firstKey]);
                User user = User.from(userData);
                user.isOwner = true.toString();
                lobbyRef.child(firstKey).set(user.toJson());
              }
            }
          },
        );
      }
    }
  }

  _onEntryAddedUser(Event event) {
    if (this.mounted) {
      if (_isLobbyEmpty()) {
        Map userData = new Map<String, dynamic>.from(event.snapshot.value);
        User user = User.from(userData);
        user.isOwner = true.toString();
        lobbyRef.child(event.snapshot.key).set(user.toJson());
      }
    }
  }
*/

  @override
  Widget build(BuildContext ctx) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Lobby Page', style: TextStyle(fontSize: 20)),
          backgroundColor: Colors.grey[800],
        ),
        body: Column(
          children: <Widget>[
            Container(
              color: /*Colors.grey[400]*/ Colors.white,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: UserCard(currentUser, lobbyRef, ctx, currentUser),
                  ),
                  MaterialButton(
                    onPressed: () {
                      currentUser.isReady =
                          (currentUser.isReady == 'false').toString();
                      lobbyRef.child(currentUser.key).set(currentUser.toJson());
                    },
                    color: (currentUser.isReady.toLowerCase() == 'true')
                        ? Colors.green
                        : Colors.redAccent,
                    child: (currentUser.isReady.toLowerCase() == 'true')
                        ? new Icon(Icons.check, color: Colors.white, size: 35.0)
                        : new Icon(Icons.close,
                            color: Colors.white, size: 35.0),
                    shape: new CircleBorder(),
                    elevation: 2.0,
                    padding: const EdgeInsets.all(15.0),
                  ),
                ],
              ),
            ),
            Divider(
              color: Colors.grey[800],
            ),
            Expanded(
              child: StreamBuilder(
                stream: lobbyRef.onValue,
                builder: (context, snap) {
                  if (snap.hasData &&
                      !snap.hasError &&
                      snap.data.snapshot.value != null) {
                    Map data = snap.data.snapshot.value;
                    users = [];

                    data.forEach((index, data) {
                      Map userData = new Map<String, dynamic>.from(
                          {"key": index, ...data});
                      User user = User.from(userData);
                      if (user != null && user.key != currentUser.key) {
                        users.add(user);
                      }
                    });
                    // If there is not only the currentUser
                    if (users.length > 0) {
                      return ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          return UserCard(
                              users[index], lobbyRef, ctx, currentUser);
                        },
                      );
                    }
                  }

                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SpinKitPouringHourglass(color: Colors.grey[800]),
                        Text("Waiting for players to join.."),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: DevFloatingButton(lobbyId, currentUser),
      ),
    );
  }
}
