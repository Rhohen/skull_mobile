import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart';
import 'package:skull_mobile/game/gameMessage.dart';
import 'package:skull_mobile/game/playerModel.dart';
import 'package:skull_mobile/game/playerWidget.dart';
import 'package:skull_mobile/lobby/userModel.dart';
import 'package:synchronized/synchronized.dart';
import 'package:vector_math/vector_math.dart' hide Colors;
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
  Map<String, Player> players;

  bool isNotificationAllowed;
  GamePageState(this.lobbyId, this.currentUser);

  // Variables for testing purpose
  int indexTurn = 0;
  static int playersNotReady;
  var lock = Lock();
  bool gameCanStart;

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
    isNotificationAllowed = false;
    gameCanStart = false;
    currentIndex = 0;
    final FirebaseDatabase database = FirebaseDatabase.instance;

    lobbyRef = database.reference().child('lobbies').child(lobbyId);

    players = new LinkedHashMap();
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
          case 'PLAYER_HAS_PLAYED':
            Map body = json.decode(message['notification']['body'].toString());

            GameMessage gameMessage = GameMessage.from(body);
            players[gameMessage.from].isTurn = false;

            if (body != null && currentUser.key != gameMessage.from) {
              LOGGER.log("Message reçu : ${gameMessage.message}");
            } else {
              LOGGER.log('Message envoyé');
            }
            if (currentUser.isOwner == 'true') {
              _sendNextTurn();
            }
            setState(() {});
            break;
          case 'NEXT_TURN':
            if (body != null) {
              LOGGER.log("Next turn received : " + body['userKey']);
              gameCanStart = true;
              players[body['userKey']].isTurn = true;
              isNotificationAllowed = (body['userKey'] == currentUser.key);
            }
            setState(() {});

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

                if (players.containsKey(k))
                  players[k].copyFromUser(updatedUser);
                else
                  players[k] = Player.fromUser(updatedUser);
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

          if (players.containsKey(event.snapshot.key))
            players[event.snapshot.key].copyFromUser(updatedUser);
          else
            players[event.snapshot.key] = Player.fromUser(updatedUser);

          if (currentUser.isOwner == 'true' && allUsersReady()) {
            gameCanStart = true;
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

  Player getNextPlayer() {
    indexTurn = (indexTurn + 1) % players.length;
    Player nextPlayer = players.values.elementAt(indexTurn);
    LOGGER.log("Next player = ${nextPlayer.key}");

    return players.values.elementAt(indexTurn);
  }

  void _sendNextTurn() {
    Player player = getNextPlayer();
    players.forEach((k, v) {
      Map<String, Object> jsonMap = {
        "to": v.fcmKey,
        "notification": {
          "title": "NEXT_TURN",
          "body": {"userKey": player.key},
          "click_action": "FLUTTER_NOTIFICATION_CLICK"
        },
        "priority": 10
      };
      client.post(googleFcmUrl, body: jsonEncode(jsonMap), headers: headersMap);
    });
    setState(() {});
  }

  bool allUsersReady() {
    for (Player player in players.values) {
      if (player.isReady != 'true') return false;
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

  final Map<String, String> cardsAssets = {
    "rose": "assets/rose.png",
    "skull": "assets/skull.png"
  };

  var refreshFunction;
  List<String> cards;
  int currentIndex;

  Vector2 getPosition(Vector2 center, double radius, double angle) {
    double playerX = (center.x + radius * cos(radians(angle)));
    double playerY = (center.y + radius * sin(radians(angle)));
    return new Vector2(playerX, playerY);
  }

  Future<void> _sendPostNotification() async {
    await lock.synchronized(() async {
      if (isNotificationAllowed) {
        isNotificationAllowed = false;
        GameMessage gameMessage =
            new GameMessage(currentUser.key, cards[currentIndex]);

        players.forEach((k, v) {
          Map<String, Object> jsonMap = {
            "to": v.fcmKey,
            "notification": {
              "title": "PLAYER_HAS_PLAYED",
              "body": gameMessage.toJson(),
              "click_action": "FLUTTER_NOTIFICATION_CLICK"
            },
            "priority": 10
          };
          client.post(googleFcmUrl,
              body: jsonEncode(jsonMap), headers: headersMap);
        });
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    Widget mainGameWidget;
    if (gameCanStart) {
      cards = players[currentUser.key].cards;
      bool isPortrait =
          MediaQuery.of(context).orientation == Orientation.portrait;
      double tableDiameter;
      double sizeMultiplier;
      Vector2 tablePosition = new Vector2(0.0, 0.0);
      double imgSize = 36.0;
      double buttonSize = 36.0;

      if (isPortrait) {
        sizeMultiplier = 0.42;
        tableDiameter = (MediaQuery.of(context).size.width * sizeMultiplier)
            .roundToDouble();
      } else {
        sizeMultiplier = 0.32;
        tableDiameter = (MediaQuery.of(context).size.height * sizeMultiplier)
            .roundToDouble();
      }

      double cardDiameter = MediaQuery.of(context).size.height * 0.21;
      double containerCardsHeight = cardDiameter + 20;
      double dividerHeight = 16;
      double gameScreenHeight = MediaQuery.of(context).size.height -
          dividerHeight -
          containerCardsHeight -
          buttonSize;

      // Je comprend pas pourquoi ça doit être inversé
      tablePosition.x = gameScreenHeight / 2;
      tablePosition.y = MediaQuery.of(context).size.width / 2;

      double tableLeftPadding = tablePosition.y - tableDiameter / 2;
      double tableTopPadding = tablePosition.x - tableDiameter / 2;

      List<Widget> playersIcon = new List();

      int numberOfPlayers = players.length;

      double spacePlayer = 360 / numberOfPlayers;
      double textSize = 14, textScaleFactor = 1;
      double heightTextSize = textSize * textScaleFactor;
      double widthContainerSize = 80;
      for (int i = 0; i < numberOfPlayers; i++) {
        Player player = players.values.elementAt(i);
        Vector2 v = getPosition(
            tablePosition, (tableDiameter / 2) + 20, spacePlayer * i);

        double centeredHorizontalValue =
            max(imgSize / 2, widthContainerSize / 2);
        double centeredVerticalValue = imgSize / 2 +
            heightTextSize / 2 +
            ((player.isTurn) ? imgSize / 2 : 0);

        playersIcon.add(
          PlayerWidget(
            top: (v.x - centeredVerticalValue),
            left: (v.y - centeredHorizontalValue),
            maxWidthContainer: widthContainerSize,
            isPlayerTurn: player.isTurn,
            iconSize: imgSize,
            hasScored: player.hasScored,
            profileImg: player.profileImg,
            playerName: player.name,
            textSize: textSize,
            textScaleFactor: textScaleFactor,
          ),
        );
      }
      mainGameWidget = Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Expanded(
            child: new Center(
              child: new Stack(
                children: <Widget>[
                  Positioned(
                    child: Opacity(
                      opacity: 0.5,
                      child: Container(
                        decoration: new BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    top: tableTopPadding,
                    left: tableLeftPadding,
                    height: tableDiameter,
                    width: tableDiameter,
                  ),
                  ...playersIcon
                ],
              ),
            ),
          ),
          Container(
            child: Column(
              children: <Widget>[
                Divider(
                  height: dividerHeight,
                  indent: 15,
                  endIndent: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    ButtonTheme(
                      height: buttonSize,
                      buttonColor: Colors.green,
                      textTheme: ButtonTextTheme.primary,
                      child: RaisedButton(
                        onPressed: (isNotificationAllowed)
                            ? _sendPostNotification
                            : null,
                        child: Text("Poser une carte"),
                      ),
                    ),
                    SizedBox(width: 20),
                    ButtonTheme(
                      height: buttonSize,
                      buttonColor: Colors.blueAccent,
                      textTheme: ButtonTextTheme.primary,
                      child: RaisedButton(
                        onPressed: null,
                        child: Text("Lancer un défi"),
                      ),
                    ),
                  ],
                ),
                Container(
                  height: containerCardsHeight,
                  width: MediaQuery.of(context).size.width,
                  child: Swiper(
                    onIndexChanged: (int index) {
                      currentIndex = index;
                    },
                    itemCount: cards.length,
                    itemWidth: cardDiameter,
                    itemHeight: cardDiameter,
                    layout: SwiperLayout.STACK,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        decoration: new BoxDecoration(
                          shape: BoxShape.circle,
                          image: new DecorationImage(
                            fit: BoxFit.cover,
                            image: AssetImage(cardsAssets[cards[index]]),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black54,
                              blurRadius: 3.0,
                              spreadRadius: 0.8,
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        body: ((gameCanStart)
            ? mainGameWidget
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SpinKitPouringHourglass(color: Colors.grey[800]),
                    Text("The game is loading.."),
                  ],
                ),
              )),
      ),
    );
  }
}
