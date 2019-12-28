import 'dart:async';

import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_database/ui/firebase_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:radial_button/widget/circle_floating_button.dart';
import 'package:skull_mobile/lobby/devFloatingButton.dart';
import 'userModel.dart';
import 'userCard.dart';
import 'package:firebase_database/firebase_database.dart';
// ignore: unused_import
import 'dart:developer' as LOGGER;
/*
class Lobby extends StatefulWidget {
  final String lobbyId;
  Lobby(this.lobbyId);

  @override
  _Lobby createState() => _Lobby(lobbyId);
}

class _Lobby extends State<Lobby> {
  List<User> users = new List();

  DatabaseReference lobbyRef;
  String lobbyId;

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

  int _indexForKey(String key) {
    assert(key != null);
    for (int index = 0; index < users.length; index++) {
      if (key == users[index].key) {
        return index;
      }
    }
    return null;
  }

  _onChildMovedUser(Event event) {
    if (this.mounted) {
      final int fromIndex = _indexForKey(event.snapshot.key);
      if (fromIndex != null) {
        setState(() {
          users.removeAt(fromIndex);
        });
        int toIndex = 0;
        if (event.previousSiblingKey != null) {
          final int prevIndex = _indexForKey(event.previousSiblingKey);
          if (prevIndex != null) {
            toIndex = prevIndex + 1;
          }
        }
        users.insert(toIndex, User.fromSnapshot(event.snapshot));
      }
    }
  }

  _onEntryRemovedUser(Event event) {
    if (this.mounted) {
      final int index = _indexForKey(event.snapshot.key);
      if (index != null) {
        users.removeAt(index);
      }
    }
  }

  _onEntryAddedUser(Event event) {
    if (this.mounted) {
      int index = 0;
      if (event.previousSiblingKey != null) {
        index = _indexForKey(event.previousSiblingKey) + 1;
      }
      if (index == null) {
        index = 0;
      }
      users.insert(index, User.fromSnapshot(event.snapshot));
    }
  }

  _onEntryChangedUser(Event event) {
    if (this.mounted) {
      final int index = _indexForKey(event.snapshot.key);
      if (index != null) {
        users[index] = User.fromSnapshot(event.snapshot);
      }
    }
  }
  // ignore: unused_element
  /* _onEntryAdded(Event event) {
    LOGGER.log("Des données ont été ajoutées - " + this.widget.hashCode.toString());
    if (this.mounted) {
      users.add(User.fromSnapshot(event.snapshot));
    }
  }*/

  // ignore: unused_element
  /*_onEntryChanged(Event event) {
    LOGGER.log("Les données ont changé - " + this.widget.hashCode.toString());
    var oldEntry = users.singleWhere((entry) {
      return entry.id == event.snapshot.key;
    });
    if (this.mounted) {
      users[users.indexOf(oldEntry)] = User.fromSnapshot(event.snapshot);
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lobby Page', style: TextStyle(fontSize: 20)),
        backgroundColor: Colors.grey[800],
      ),
      body: new Column(
        children: <Widget>[
          new Flexible(
            child: new FirebaseAnimatedList(
              query: lobbyRef,
              itemBuilder: (_, DataSnapshot snapshot,
                  Animation<double> animation, int index) {
                if (snapshot != null &&
                    snapshot.key != null &&
                    snapshot.value != null) {
                  /* Map lobbyMap = new Map<String, dynamic>.from(snapshot.value);

                List users = lobbyMap.entries
                    .map(
                      (entry) {
                        if (entry.value is Map<dynamic, dynamic>) {
                          Map valVal =
                              new Map<String, dynamic>.from(entry.value);
                          return User.from(valVal);
                        }
                        return null;
                      },
                    )
                    .where((x) => x != null)
                    .toList();
*/

                  return new FutureBuilder<DataSnapshot>(
                    future: lobbyRef.child(snapshot.key).once(),
                    builder: (BuildContext context, snapshot) {
                      return snapshot.hasData
                          ? UserCard(users[index])
                          : SpinKitPouringHourglass(color: Colors.grey[800]);
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

                return Column(
                  children: <Widget>[
                    new Flexible(
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: users.length,
                        padding: const EdgeInsets.only(top: 10.0),
                        itemBuilder: (context, index) {
                          return UserCard(users[index]);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: DevFloatingButton(lobbyId),
    );
  }
}
*/
/*

 body: new Column(children: <Widget>[
        new Flexible(
          child: new FirebaseAnimatedList(
              query: lobbyRef,
              itemBuilder: (_, DataSnapshot snapshot,
                  Animation<double> animation, int index) {
                return new ListTile(
                  title: new Text(snapshot.value['name']),
                  subtitle: new Text(users[index].rank),
                );
              }),
        ),
      ]),
 */
