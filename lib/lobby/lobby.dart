import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:skull_mobile/lobby/devFloatingButton.dart';
import 'userModel.dart';
import 'userCard.dart';
import 'package:firebase_database/firebase_database.dart';
// ignore: unused_import
import 'dart:developer' as LOGGER;

class Lobby extends StatefulWidget {
  final String lobbyId;
  Lobby(this.lobbyId);

  @override
  _Lobby createState() => _Lobby(lobbyId);
}

class _Lobby extends State<Lobby> {
  DatabaseReference lobbyRef;
  String lobbyId;
  List users;

  _Lobby(this.lobbyId);

  @override
  void initState() {
    super.initState();
    final FirebaseDatabase database = FirebaseDatabase.instance;
    lobbyRef = database.reference().child('lobbies').child(lobbyId);
    lobbyRef.onChildAdded.listen(_onEntryAddedUser);
    lobbyRef.onChildChanged.listen(_onEntryChangedUser);
    lobbyRef.onChildRemoved.listen(_onEntryRemovedUser);
    lobbyRef.onChildMoved.listen(_onChildMovedUser);
  }

  _onEntryAddedUser(Event event) {}
  _onEntryChangedUser(Event event) {}
  _onEntryRemovedUser(Event event) {}
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Lobby Page', style: TextStyle(fontSize: 20)),
        backgroundColor: Colors.grey[800],
      ),
      body: StreamBuilder(
        stream: lobbyRef.onValue,
        builder: (context, snap) {
          if (snap.hasData &&
              !snap.hasError &&
              snap.data.snapshot.value != null) {
            Map data = snap.data.snapshot.value;
            users = [];

            data.forEach((index, data) => users.add({"key": index, ...data}));
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                Map userData = new Map<String, dynamic>.from(users[index]);
                User user = User.from(userData);
                return UserCard(user, lobbyRef, ctx);
              },
            );
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SpinKitPouringHourglass(color: Colors.grey[800]),
                  Text("Waiting for players to join.."),
                ],
              ),
            );
          }
        },
      ),
      floatingActionButton: DevFloatingButton(lobbyId),
    );
  }
}
