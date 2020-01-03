import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:skull_mobile/lobby/userModel.dart';

class GamePage extends StatefulWidget {
  static const routeName = '/GamePage';
  final String lobbyId;
  final User currentUser;

  GamePage(this.lobbyId, this.currentUser, {Key key}) : super(key: key);

  @override
  GamePageState createState() {
    return new GamePageState(lobbyId, currentUser);
  }
}

class GamePageState extends State<GamePage> {
  DatabaseReference lobbyRef;
  String lobbyId;
  User currentUser;
  BuildContext lobbiesContext;
  FirebaseMessaging _fcm = new FirebaseMessaging();
  Map<String, User> users;
  GamePageState(this.lobbyId, this.currentUser);

  // Http connection
  var client;
  final String googleFcmUrl = "https://fcm.googleapis.com/fcm/send";
  final String apiServerToken =
      "AAAAzzE1LVc:APA91bHBNf5-GKxFHb4A5XSV02rckWY_KVaNoP-qqrK8OcNX8A2A7gF_u4tqezPOWxj3xdQg1Y3E6XGs9fLqrrBpPLAf7ycpQM2MvU-jZ7MH0pmI6pLH9x31UrvymlYNcUcKugGipZxJ";
  Map<String, String> headersMap;

  @override
  void initState() {
    super.initState();

    final FirebaseDatabase database = FirebaseDatabase.instance;

    lobbyRef = database.reference().child('lobbies').child(lobbyId);

    users = new HashMap();

    lobbyRef.onChildChanged.listen(_onEntryChangedUser);

    client = http.Client();

    headersMap = {
      HttpHeaders.authorizationHeader: "key=$apiServerToken",
      HttpHeaders.contentTypeHeader: ContentType.json.value
    };

    _fcm.getToken().then((token) {
      currentUser.fcmKey = token;
      lobbyRef.child(currentUser.key).set(currentUser.toJson());
    });

    // If isOwner faire trucs spécifiques comme initialiser les cartes ou l'ordre de jeu

    _fcm.configure(
      onMessage: (Map<String, dynamic> message) {
        print('onMessage called: $message');
        // If isOwner faire trucs spécifiques
        return null;
      },
      onResume: (Map<String, dynamic> message) {
        print('onResume called: $message');

        return null;
      },
      onLaunch: (Map<String, dynamic> message) {
        print('onLaunch called: $message');

        return null;
      },
    );
  }

  void _onEntryChangedUser(Event event) {
    if (this.mounted) {
      if (event.snapshot != null &&
          event.snapshot.value != null &&
          event.snapshot.key != 'state' &&
          event.snapshot.key != currentUser.key) {
        Map mapUser = new Map<String, dynamic>.from(event.snapshot.value);
        users[event.snapshot.key] = User.from(mapUser);
        print("user " +
            event.snapshot.key +
            " added - " +
            users.length.toString());
      }
    }
  }

  void _sendPostNotification() {
    users.forEach((k, v) {
      Map<String, Object> jsonMap = {
        "to": v.fcmKey,
        "notification": {
          "title": "Titre de la notif",
          "body": "Brodcast test message",
          "click_action": "FLUTTER_NOTIFICATION_CLICK"
        },
        "priority": 10
      };
      client.post(googleFcmUrl, body: jsonEncode(jsonMap), headers: headersMap);
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    client.close();
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
                  currentUser.toJson().toString(),
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
                  onPressed: _sendPostNotification,
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
