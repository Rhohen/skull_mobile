import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:skull_mobile/game/game.dart';
import 'package:skull_mobile/jouer.dart';
import 'package:skull_mobile/lobby/devFloatingButton.dart';
import 'userModel.dart';
import 'userCard.dart';
import 'package:firebase_database/firebase_database.dart';
// ignore: unused_import
import 'dart:developer' as LOGGER;

class Lobby extends StatefulWidget {
  static const routeName = '/Lobby';

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

    lobbyRef.once().then((DataSnapshot snapshot) {
      if (snapshot != null && snapshot.value == null) {
        currentUser.isOwner = 'true';
      }
      var generatedReference = lobbyRef.push();
      currentUser.key = generatedReference.key;
      generatedReference.set(currentUser.toJson());
      setState(() {});
    });

    lobbyRef.onChildAdded.listen(_onEntryAddedUser);
    lobbyRef.onChildChanged.listen(_onEntryChangedUser);
    lobbyRef.onChildRemoved.listen(_onEntryRemovedUser);
    lobbyRef.onChildMoved.listen(_onChildMovedUser);
  }

  _onEntryAddedUser(Event event) {}

  _onEntryChangedUser(Event event) {
    if (this.mounted) {
      if (event.snapshot != null && currentUser != null) {
        if (currentUser.key == event.snapshot.key) {
          Map userData = new Map<String, dynamic>.from(event.snapshot.value);
          currentUser.copyFrom(User.from(userData));
        }
        setState(() {});
      }
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
        }).show();
  }

  _onEntryRemovedUser(Event event) {
    if (this.mounted) {
      if (event.snapshot != null &&
          currentUser != null &&
          currentUser.key == event.snapshot.key) {
        if (currentUser.isOwner == 'true') {
          lobbyRef.once().then(
            (DataSnapshot snapshot) {
              if (snapshot != null &&
                  snapshot.value != null &&
                  snapshot.value is Map<dynamic, dynamic>) {
                Map lobbyMap = new Map<String, dynamic>.from(snapshot.value);
                lobbyMap.removeWhere((k, v) => k == currentUser.key);
                if (lobbyMap.entries.length > 0) {
                  Map userData = new Map<String, dynamic>.from(
                      lobbyMap.entries.first.value);
                  User user = User.from(userData);
                  user.isOwner = 'true';
                  lobbyRef.child(lobbyMap.entries.first.key).set(user.toJson());
                }
              }
            },
          );
        }
        Navigator.popUntil(context, ModalRoute.withName(JouerPage.routeName));
      }
    }
  }

  _onChildMovedUser(Event event) {}

  bool _isUserCorrect(User user) {
    return user != null &&
        user.isOwner != null &&
        user.isReady != null &&
        user.name != null &&
        user.rank != null &&
        user.profileImg != null;
  }

  @override
  Widget build(BuildContext ctx) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Lobby Page', style: TextStyle(fontSize: 20)),
          backgroundColor: Colors.grey[800],
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => AwesomeDialog(
                context: context,
                dialogType: DialogType.WARNING,
                animType: AnimType.TOPSLIDE,
                tittle: 'Are you sure?',
                desc: 'You are going to exit the lobby.',
                btnCancelOnPress: () {},
                btnOkOnPress: () {
                  lobbyRef.child(currentUser.key).remove();
                }).show(),
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(top: 8),
              color: /*Colors.grey[400]*/ Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
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
                    padding: EdgeInsets.all(12),
                  ),
                ],
              ),
            ),
            Divider(
              indent: 15,
              endIndent: 15,
            ),
            Expanded(
              child: StreamBuilder(
                stream: lobbyRef.onValue,
                builder: (context, snap) {
                  if (snap.hasData &&
                      !snap.hasError &&
                      snap.data.snapshot.value != null) {
                    Map data = snap.data.snapshot.value;

                    // This list will contain every user except current user
                    users = [];

                    int numberOfReady = 0;
                    data.forEach((index, data) {
                      if (data is Map<dynamic, dynamic>) {
                        Map userData = new Map<String, dynamic>.from(
                            {"key": index, ...data});

                        User user = User.from(userData);
                        if (_isUserCorrect(user)) {
                          if (user.key != currentUser.key) users.add(user);
                          if (user.isReady == 'true') numberOfReady++;
                        } else {
                          lobbyRef.child(user.key).remove();
                        }
                      }
                    });

                    // If there is not only the currentUser
                    if (users.length > 0) {
                      List<Widget> listUnderCurrentUser = [];

                      // Minimum 2 players and everybody is ready
                      if (numberOfReady == users.length + 1 &&
                          users.length >= 1) {
                        listUnderCurrentUser.add(
                          FlatButton(
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(18.0),
                                side: BorderSide(color: Colors.green)),
                            child: Text('Start the game'),
                            color: Colors.green,
                            textTheme: ButtonTextTheme.primary,
                            onPressed: () {
                              Navigator.popAndPushNamed(
                                  context, GamePage.routeName);
                            },
                          ),
                        );
                        listUnderCurrentUser.add(
                          SizedBox(height: 8),
                        );
                      }

                      listUnderCurrentUser.add(Expanded(
                        child: ListView.builder(
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            return UserCard(
                                users[index], lobbyRef, ctx, currentUser);
                          },
                        ),
                      ));

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[...listUnderCurrentUser],
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
