import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skull_mobile/game/playerModel.dart';

class GamePage extends StatefulWidget {
  static const routeName = '/GamePage';
  final String lobbyId;
  final Player currentPlayer;

  GamePage(this.lobbyId, this.currentPlayer, {Key key}) : super(key: key);

  @override
  GamePageState createState() {
    return new GamePageState(lobbyId, currentPlayer);
  }
}

class GamePageState extends State<GamePage> {
  DatabaseReference gameRef;
  String lobbyId;
  Player currentPlayer;
  BuildContext lobbiesContext;

  GamePageState(this.lobbyId, this.currentPlayer);

  @override
  void initState() {
    super.initState();

    final FirebaseDatabase database = FirebaseDatabase.instance;

    gameRef =
        database.reference().child('lobbies').child(lobbyId).child("game");

    gameRef.onChildAdded.listen(_onEntryAddedUser);
    gameRef.onChildChanged.listen(_onEntryChangedUser);
    gameRef.onChildRemoved.listen(_onEntryRemovedUser);
    gameRef.onChildMoved.listen(_onChildMovedUser);
  }

  void _onEntryAddedUser(Event event) {}
  void _onEntryChangedUser(Event event) {}
  void _onEntryRemovedUser(Event event) {}
  void _onChildMovedUser(Event event) {}

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Skull Game',
      home: SizedBox.expand(
        child: Container(
          decoration: new BoxDecoration(color: Colors.white),
          child: new Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  currentPlayer.toJson().toString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      fontFamily: 'Open Sans',
                      fontSize: 10),
                ),
                OutlineButton(
                  color: Colors.white,
                  borderSide: BorderSide(
                    style: BorderStyle.solid,
                    width: 1.2,
                  ),
                  onPressed: null,
                  child: Text('Send request to other player'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
