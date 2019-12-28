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

  _Lobby(this.lobbyId);

  @override
  void initState() {
    super.initState();
    final FirebaseDatabase database = FirebaseDatabase.instance;
    lobbyRef = database.reference().child('lobbies').child(lobbyId);
  }

  @override
  Widget build(BuildContext context) {
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
              List item = [];

              data.forEach((index, data) => item.add({"key": index, ...data}));

              return ListView.builder(
                itemCount: item.length,
                itemBuilder: (context, index) {
                  Map userData = new Map<String, dynamic>.from(item[index]);
                  User user = User.from(userData);
                  return UserCard(user);
                },
              );
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SpinKitPouringHourglass(color: Colors.grey[800]),
                    Text("Waiting for players.."),
                  ],
                ),
              );
            }
          }),
      floatingActionButton: DevFloatingButton(lobbyId),
    );
  }
}
