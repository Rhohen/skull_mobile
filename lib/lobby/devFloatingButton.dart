import 'package:faker/faker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:radial_button/widget/circle_floating_button.dart';
import 'package:skull_mobile/game/EGameState.dart';
import 'package:skull_mobile/lobby/userModel.dart';

final databaseReference = FirebaseDatabase.instance.reference();
final faker = new Faker();

class DevFloatingButton extends StatelessWidget {
  final String lobbyId;
  final User currentUser;

  DevFloatingButton(this.lobbyId, this.currentUser);

  @override
  Widget build(BuildContext context) {
    var itemsActionBar = [
      FloatingActionButton(
        heroTag: "nuke",
        backgroundColor: Colors.redAccent,
        onPressed: () {
          databaseReference
              .child('lobbies')
              .child(lobbyId)
              .once()
              .then((DataSnapshot snapshot) {
            if (snapshot != null && snapshot.value != null) {
              Map lobbyMap = new Map<String, dynamic>.from(snapshot.value);
              lobbyMap.removeWhere(
                  (k, v) => (k == currentUser.key || k == 'state'));
              if (lobbyMap.entries.length > 0) {
                lobbyMap.entries.forEach((entry) {
                  if (entry.key != null) {
                    databaseReference
                        .child('lobbies')
                        .child(lobbyId)
                        .child(entry.key)
                        .remove();
                  }
                });
              }
            }
          });
        },
        child: Icon(Icons.delete_forever),
      ),
      FloatingActionButton(
        heroTag: "remove",
        backgroundColor: Colors.orangeAccent,
        onPressed: () {
          databaseReference
              .child('lobbies')
              .child(lobbyId)
              .once()
              .then((DataSnapshot snapshot) {
            if (snapshot != null && snapshot.value != null) {
              Map lobbyMap = new Map<String, dynamic>.from(snapshot.value);
              lobbyMap.removeWhere(
                  (k, v) => (k == currentUser.key || k == 'state'));

              if (lobbyMap.entries.length > 0) {
                String lastKey = lobbyMap.entries.last.key;
                if (lastKey != null)
                  databaseReference
                      .child('lobbies')
                      .child(lobbyId)
                      .child(lastKey)
                      .remove();
              }
            }
          });
        },
        child: Icon(Icons.remove),
      ),
      FloatingActionButton(
        heroTag: "add",
        backgroundColor: Colors.lightGreen,
        onPressed: () {
          String photo = 'assets/pic-' +
              faker.randomGenerator.integer(7, min: 1).toString() +
              '.png';
          String name = faker.person.firstName();
          String rank = faker.randomGenerator.integer(101, min: 1).toString();
          String isReady = (faker.randomGenerator.integer(3, min: 1) == 1)
              ? 'true'
              : 'false';
          String isOwner = 'false';

          databaseReference.child('lobbies').child(lobbyId).push().set({
            'name': name,
            'profileImg': photo,
            'rank': rank,
            'isReady': isReady,
            'isOwner': isOwner,
            'fcmKey': "0"
          });
        },
        child: Icon(Icons.add),
      ),
      FloatingActionButton(
        heroTag: "generate",
        backgroundColor: Colors.blueAccent,
        onPressed: () {
          bool isCurrentUserOwner = false;

          databaseReference
              .child('lobbies')
              .child(lobbyId)
              .once()
              .then((DataSnapshot snapshot) {
            if (snapshot != null && snapshot.value != null) {
              Map lobbyMap = new Map<String, dynamic>.from(snapshot.value);
              lobbyMap.removeWhere((k, v) {
                if (k != currentUser.key) {
                  return false;
                } else {
                  Map userData = new Map<String, dynamic>.from(v);
                  isCurrentUserOwner = (User.from(userData).isOwner == 'true');
                  return true;
                }
              });
              if (lobbyMap.entries.length > 0) {
                lobbyMap.entries.forEach((entry) {
                  if (entry.key != null) {
                    databaseReference
                        .child('lobbies')
                        .child(lobbyId)
                        .child(entry.key)
                        .remove();
                  }
                });
              }
              databaseReference
                  .child('lobbies')
                  .child(lobbyId)
                  .child("state")
                  .set(EGameState.INITIALIZING);
            }
          }).then((t) {
            int nbUser = faker.randomGenerator.integer(6, min: 1);
            int ownerNumber = (isCurrentUserOwner)
                ? -1
                : faker.randomGenerator.integer(nbUser, min: 0);
            for (int i = 0; i < nbUser; i++) {
              String photo = 'assets/pic-' +
                  faker.randomGenerator.integer(7, min: 1).toString() +
                  '.png';
              String name = faker.person.firstName();
              String rank =
                  faker.randomGenerator.integer(101, min: 1).toString();
              String isReady = (faker.randomGenerator.integer(3, min: 1) == 1)
                  ? 'true'
                  : 'false';
              String isOwner = 'false';
              if (i == ownerNumber) isOwner = 'true';

              databaseReference.child('lobbies').child(lobbyId).push().set({
                'name': name,
                'profileImg': photo,
                'rank': rank,
                'isReady': isReady,
                'isOwner': isOwner,
                'fcmKey': "0"
              });
            }
          });
        },
        child: Icon(Icons.people),
      ),
    ];
    return CircleFloatingButton.floatingActionButton(
        items: itemsActionBar,
        color: Colors.purple,
        icon: Icons.code,
        duration: Duration(milliseconds: 200),
        curveAnim: Curves.ease);
  }
}
