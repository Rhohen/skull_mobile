import 'package:faker/faker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:radial_button/widget/circle_floating_button.dart';
import 'dart:developer' as LOGGER;

final databaseReference = FirebaseDatabase.instance.reference();
final faker = new Faker();

class DevFloatingButton extends StatelessWidget {
  final String lobbyId;

  DevFloatingButton(this.lobbyId);

  @override
  Widget build(BuildContext context) {
    var itemsActionBar = [
      FloatingActionButton(
        heroTag: "nuke",
        backgroundColor: Colors.redAccent,
        onPressed: () {
          databaseReference.child('lobbies').child(lobbyId).remove();
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
              String lastKey = lobbyMap.entries.last.key;
              if (lastKey != null)
                databaseReference
                    .child('lobbies')
                    .child(lobbyId)
                    .child(lastKey)
                    .remove();
            }
          });
        },
        child: Icon(Icons.remove),
      ),
      FloatingActionButton(
        heroTag: "add",
        backgroundColor: Colors.lightGreen,
        onPressed: () {
          String photo = 'img/pic-' +
              faker.randomGenerator.integer(7, min: 1).toString() +
              '.png';
          String name = faker.person.name();
          String rank = faker.randomGenerator.integer(101, min: 1).toString();

          databaseReference
              .child('lobbies')
              .child(lobbyId)
              .push()
              .set({'name': name, 'profileImg': photo, 'rank': rank});
        },
        child: Icon(Icons.add),
      ),
      FloatingActionButton(
        heroTag: "generate",
        backgroundColor: Colors.blueAccent,
        onPressed: () {
          databaseReference.child('lobbies').child(lobbyId).remove();

          int nbUser = faker.randomGenerator.integer(7, min: 1);

          for (int i = 0; i < nbUser; i++) {
            String photo = 'img/pic-' +
                faker.randomGenerator.integer(7, min: 1).toString() +
                '.png';
            String name = faker.person.name();
            String rank = faker.randomGenerator.integer(101, min: 1).toString();

            databaseReference
                .child('lobbies')
                .child(lobbyId)
                .push()
                .set({'name': name, 'profileImg': photo, 'rank': rank});
          }
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
