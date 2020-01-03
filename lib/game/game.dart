import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart';
import 'package:skull_mobile/game/gameMessage.dart';
import 'package:skull_mobile/lobby/userModel.dart';
import 'package:synchronized/synchronized.dart';
import 'dart:developer' as LOGGER;

import '../jouer.dart';
import 'EGameState.dart';

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

  // Variables for testing purpose
  bool _myTurn = false;
  String _messageReceived = '';
  final myController = TextEditingController();
  int indexTurn = 0;
  static int playersNotReady;
  var lock = Lock();

  // Http connection
  BaseClient client;
  final String googleFcmUrl = "https://fcm.googleapis.com/fcm/send";
  final String apiServerToken =
      "AAAAzzE1LVc:APA91bHBNf5-GKxFHb4A5XSV02rckWY_KVaNoP-qqrK8OcNX8A2A7gF_u4tqezPOWxj3xdQg1Y3E6XGs9fLqrrBpPLAf7ycpQM2MvU-jZ7MH0pmI6pLH9x31UrvymlYNcUcKugGipZxJ";
  Map<String, String> headersMap;
  bool closeGame = false;

  @override
  void initState() {
    super.initState();

    final FirebaseDatabase database = FirebaseDatabase.instance;

    lobbyRef = database.reference().child('lobbies').child(lobbyId);

    users = new LinkedHashMap();

    lobbyRef.onChildChanged.listen(_onEntryChangedUser);

    client = http.Client();

    headersMap = {
      HttpHeaders.authorizationHeader: "key=$apiServerToken",
      HttpHeaders.contentTypeHeader: ContentType.json.value
    };

    _fcm.configure(
      onMessage: (Map<String, dynamic> message) {
        var action = message['notification']['title'];
        Map body = json.decode(message['notification']['body'].toString());

        switch (action) {
          case 'USER_HAS_PLAYED':
            Map body = json.decode(message['notification']['body'].toString());

            GameMessage gameMessage = GameMessage.from(body);
            if (body != null && currentUser.key != gameMessage.from) {
              _messageReceived = "Message reçu : ${gameMessage.message}";
            } else {
              _messageReceived = 'Message envoyé';
            }
            if (currentUser.isOwner == 'true') {
              _sendNextTurn();
            }
            setState(() {});
            break;
          case 'NEXT_TURN':
            if (body != null && body['userKey'] == currentUser.key) {
              _myTurn = true;
              setState(() {});
            }
            break;
          default:
            LOGGER.log('onMessage undefined: $message ');
            break;
        }
        return null;
      },
      onResume: (Map<String, dynamic> message) {
        LOGGER.log('onResume called: $message');

        return null;
      },
      onLaunch: (Map<String, dynamic> message) {
        LOGGER.log('onLaunch called: $message');

        return null;
      },
    );

    _fcm.getToken().then((token) async {
      currentUser.fcmKey = token;
      await lock.synchronized(() async {
        lobbyRef.once().then((DataSnapshot snapshot) {
          if (snapshot != null &&
              snapshot.value != null &&
              snapshot.value is Map<dynamic, dynamic>) {
            Map lobbyMap = new Map<String, dynamic>.from(snapshot.value);
            lobbyMap.removeWhere((k, v) => !(v is Map<dynamic, dynamic>));
            if (lobbyMap.entries.length > 0) {
              lobbyMap.forEach((k, v) {
                Map mapUser = new Map<String, dynamic>.from(v);
                User updatedUser = User.from(mapUser);
                updatedUser.key = k;

                if (users.containsKey(k))
                  users[k].copyFrom(updatedUser);
                else
                  users[k] = updatedUser;
              });

              currentUser.isReady = 'true';
              lobbyRef.child(currentUser.key).set(currentUser.toJson());
            }
          }
        });
      });
    });
  }

  Future<void> _onEntryChangedUser(Event event) async {
    if (this.mounted) {
      if (event.snapshot != null &&
          event.snapshot.value != null &&
          event.snapshot.key != 'state') {
        await lock.synchronized(() async {
          Map mapUser = new Map<String, dynamic>.from(event.snapshot.value);
          User updatedUser = User.from(mapUser);
          updatedUser.key = event.snapshot.key;

          if (users.containsKey(event.snapshot.key))
            users[event.snapshot.key].copyFrom(updatedUser);
          else
            users[event.snapshot.key] = updatedUser;

          if (currentUser.isOwner == 'true' && allUsersReady()) {
            LOGGER.log("The game can start, sending orders to next player...");
            _sendNextTurn();
          }
        });
      } else if (event.snapshot.key == 'state' &&
          event.snapshot.value == EGameState.ENDED) {
        if (!closeGame) {
          closeGame = true;
          _onBackPressed();
        }
      }
    }
  }

  void _sendPostNotification() {
    users.forEach((k, v) {
      GameMessage gameMessage =
          new GameMessage(currentUser.key, myController.text);
      Map<String, Object> jsonMap = {
        "to": v.fcmKey,
        "notification": {
          "title": "USER_HAS_PLAYED",
          "body": gameMessage.toJson(),
          "click_action": "FLUTTER_NOTIFICATION_CLICK"
        },
        "priority": 10
      };
      client.post(googleFcmUrl, body: jsonEncode(jsonMap), headers: headersMap);
    });
    _myTurn = false;
    myController.text = "";
    setState(() {});
  }

  User getNextPlayer() {
    indexTurn = (indexTurn + 1) % users.length;
    User nextPlayer = users.values.elementAt(indexTurn);
    LOGGER.log("Next player = ${nextPlayer.key}");

    return users.values.elementAt(indexTurn);
  }

  void _sendNextTurn() {
    User user = getNextPlayer();
    Map<String, Object> jsonMap = {
      "to": user.fcmKey,
      "notification": {
        "title": "NEXT_TURN",
        "body": {"userKey": user.key},
        "click_action": "FLUTTER_NOTIFICATION_CLICK"
      },
      "priority": 10
    };
    client.post(googleFcmUrl, body: jsonEncode(jsonMap), headers: headersMap);
    setState(() {});
  }

  bool allUsersReady() {
    for (User user in users.values) {
      if (user.isReady != 'true') return false;
    }
    return true;
  }

  Future<bool> _onBackPressed() {
    if (!closeGame) {
      lobbyRef.child("state").set(EGameState.ENDED);
    }
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    client.close();
    lobbyRef.child(currentUser.key).remove();
    Navigator.popUntil(context, ModalRoute.withName(JouerPage.routeName));
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Skull Game',
        home: SizedBox.expand(
          child: Container(
            decoration: new BoxDecoration(color: Colors.white),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    _messageReceived,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Open Sans',
                        fontSize: 15),
                  ),
                  Material(
                    child: TextField(
                      maxLines: 1,
                      maxLength: 40,
                      controller: myController,
                      enabled: _myTurn,
                      decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        labelText:
                            _myTurn ? 'Enter a word to send' : 'NOT YOUR TURN',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32.0),
                        ),
                      ),
                    ),
                  ),
                  OutlineButton(
                    color: Colors.white,
                    borderSide: BorderSide(
                      style: BorderStyle.solid,
                      width: 1.2,
                    ),
                    onPressed: _myTurn ? _sendPostNotification : null,
                    child: Text('Send word to other player'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
