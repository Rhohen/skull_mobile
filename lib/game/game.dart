import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:faker/faker.dart';
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
  /// Lobby database reference
  DatabaseReference lobbyRef;

  /// Lobby Id
  String lobbyId;

  /// Current cellphone user
  User currentUser;

  /// Firebase notifications system
  final FirebaseMessaging _fcm = new FirebaseMessaging();

  /// Current players list <playerKey, player>
  Map<String, Player> players;

  /// True when its your turn, false otherwise, it allows the user to play a card
  bool isNotificationAllowed;

  /// Actual turn index, only useful for the game owner to make the "nextTurn" system work
  int indexTurn;

  /// Object providing an implicit lock
  var lock = Lock();

  /// Boolean to know if the game can start
  bool gameCanStart;

  /// Boolean to know if a challenge occured
  bool challengeOccurred;

  /// Http connection towards google fcmUrl
  BaseClient client;

  /// Google fcm url
  final String googleFcmUrl = "https://fcm.googleapis.com/fcm/send";

  /// Current project api server token (Firebase -> Paramètres du projet -> Cloud Messaging -> Clé de serveur)
  final String apiServerToken =
      "AAAAzzE1LVc:APA91bHBNf5-GKxFHb4A5XSV02rckWY_KVaNoP-qqrK8OcNX8A2A7gF_u4tqezPOWxj3xdQg1Y3E6XGs9fLqrrBpPLAf7ycpQM2MvU-jZ7MH0pmI6pLH9x31UrvymlYNcUcKugGipZxJ";

  /// Headers list that needs to be given for each google fcm request
  Map<String, String> headersMap;

  /// Boolean to know if the game need to be closed or not
  bool closeGame = false;

  /// Assats location cards
  final Map<String, String> cardsAssets = {
    "rose": "assets/rose.png",
    "skull": "assets/skull.png"
  };

  /// Players cards length <playerKey, current turn cards number>
  Map<String, int> cardsOnTable;

  /// Current player card deck
  List<String> myCardsOnTable;

  /// Current player card index
  int currentIndex;

  GamePageState(this.lobbyId, this.currentUser);

  @override
  void initState() {
    super.initState();
    isNotificationAllowed = false;
    gameCanStart = false;
    challengeOccurred = true;
    currentIndex = 0;
    indexTurn = 0;
    cardsOnTable = new HashMap();
    myCardsOnTable = new List();

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
      onMessage: (Map<String, dynamic> message) async {
        var action = message['notification']['title'];
        Map body = json.decode(message['notification']['body'].toString());
        GameMessage gameMessage = GameMessage.from(body);

        await lock.synchronized(() async {
          switch (action) {
            case 'PLAYER_HAS_PLAYED':
              cardsOnTable[gameMessage.currentPlayer]--;
              players[gameMessage.currentPlayer].isTurn = false;

              if (body != null &&
                  currentUser.key != gameMessage.currentPlayer) {
                LOGGER.log(
                    "Player ${gameMessage.currentPlayer} played a ${gameMessage.message}");
              } else {
                LOGGER.log('Message sent successfully');
              }
              if (currentUser.isOwner == 'true') {
                _sendNextTurn(players.values.elementAt(indexTurn).key);
              }
              setState(() {});
              break;
            case 'NEXT_TURN':
              if (body != null) {
                gameCanStart = true;
                if (gameMessage.currentPlayer.isNotEmpty) {
                  LOGGER
                      .log("Previous player was " + gameMessage.currentPlayer);
                  players[gameMessage.currentPlayer].isTurn = false;
                }
                LOGGER.log("Next player is " + gameMessage.nextPlayer);
                players[gameMessage.nextPlayer].isTurn = true;
                isNotificationAllowed =
                    (gameMessage.nextPlayer == currentUser.key);
              }
              setState(() {});
              break;
            case 'CHALLENGE_TIME':
              challengeOccurred = true;

              // Actuellement le message reçu correspond à la key de la personne ayant perdu le challenge
              List<String> cardsList = players[gameMessage.message].cards;

              // ==== Cette partie là est temporaire, il faudra coder l'interface de challenge === //

              if (cardsList.length > 0) {
                int cardIndex =
                    new Faker().randomGenerator.integer(cardsList.length);
                LOGGER.log(gameMessage.message +
                    " carte a supprimer : n° " +
                    cardIndex.toString());
                players[gameMessage.message].cards.removeAt(cardIndex);
              }

              // ================================================================================= //

              if (currentUser.isOwner == 'true' && cardsList.length > 0) {
                _sendNextTurn(players.values.elementAt(indexTurn).key);
              }

              if (currentUser.key == gameMessage.message &&
                  cardsList.length <= 0) {
                _sendEliminatedNotification();
              }
              setState(() {});
              break;
            case 'PLAYER_IS_ELIMINATED':
              indexTurn =
                  (((indexTurn - 1) % players.length) + players.length) %
                      players.length; // only useful for the game owner
              players.remove(gameMessage.message);

              setState(() {});
              if (players.length <= 1) {
                AwesomeDialog(
                  customHeader: Container(
                    width: 100.0,
                    height: 100.0,
                    decoration: new BoxDecoration(
                      shape: BoxShape.circle,
                      image: new DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage((players[currentUser.key] != null)
                            ? 'assets/winner.png'
                            : 'assets/looser.jpeg'),
                      ),
                    ),
                  ),
                  context: context,
                  animType: AnimType.TOPSLIDE,
                  tittle: (players[currentUser.key] != null)
                      ? 'You are the winner !'
                      : 'You just lost THE GAME !',
                  desc: (players[currentUser.key] != null)
                      ? 'So pleased to see you accomplishing great things.'
                      : 'Maybe the truth is, there\'s a little bit of loser in all of us... ',
                  btnOk: FlatButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(18.0),
                        side: BorderSide(color: Colors.grey)),
                    child: Text('Leave game'),
                    onPressed: () {
                      Navigator.popUntil(
                          context, ModalRoute.withName(JouerPage.routeName));
                    },
                  ),
                  //this is ignored
                  btnOkOnPress: () {},
                ).show();
              } else {
                if (currentUser.isOwner == 'true') {
                  _sendNextTurn("");
                }
              }
              break;
            default:
              LOGGER.log('onMessage undefined: $message ');
              break;
          }
        });
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
            _sendNextTurn(players.values.elementAt(indexTurn).key);
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
    return nextPlayer;
  }

  Player getPreviousPlayer() {
    int playersSize = players.length;
    int previousPlayerIndex = players.keys.toList().indexOf(currentUser.key);
    previousPlayerIndex =
        ((((previousPlayerIndex - 1) % playersSize) + playersSize) %
            playersSize);
    Player previousPlayer = players.values.elementAt(previousPlayerIndex);
    LOGGER.log("Previous player = ${previousPlayer.key}");

    return previousPlayer;
  }

  void _sendNextTurn(String currentPlayerKey) {
    GameMessage gameMessage =
        new GameMessage("", currentPlayerKey, getNextPlayer().key);

    players.forEach((k, v) {
      Map<String, Object> jsonMap = {
        "to": v.fcmKey,
        "notification": {
          "title": "NEXT_TURN",
          "body": gameMessage.toJson(),
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

  Vector2 getPosition(Vector2 center, double radius, double angle) {
    double playerX = (center.x + radius * cos(radians(angle)));
    double playerY = (center.y + radius * sin(radians(angle)));
    return new Vector2(playerX, playerY);
  }

  bool allPlayedOnce(
      Map<String, int> cardsOnTable, Map<String, Player> players) {
    String currentUserKey = currentUser.key;
    Player currentPlayer = players[currentUserKey];

    if (currentPlayer != null) {
      return (cardsOnTable[currentUser.key] < currentPlayer.cards.length - 1) ||
          (currentPlayer.isTurn &&
              cardsOnTable[currentUser.key] < currentPlayer.cards.length);
    }
    return false;
  }

  Future<void> _sendHasPlayedNotification() async {
    await lock.synchronized(() async {
      if (isNotificationAllowed) {
        isNotificationAllowed = false;
        GameMessage gameMessage = new GameMessage(
            myCardsOnTable.elementAt(currentIndex), currentUser.key, "");
        myCardsOnTable.removeAt(currentIndex);

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

  Future<void> _sendChallengeNotification() async {
    await lock.synchronized(() async {
      if (!challengeOccurred) {
        challengeOccurred = true;
        isNotificationAllowed = false;

        GameMessage gameMessage = new GameMessage(
            players.values
                .elementAt(new Faker().randomGenerator.integer(players.length))
                .key,
            "",
            "");

        players.forEach((k, v) {
          Map<String, Object> jsonMap = {
            "to": v.fcmKey,
            "notification": {
              "title": "CHALLENGE_TIME",
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

  Future<void> _sendEliminatedNotification() async {
    await lock.synchronized(() async {
      GameMessage gameMessage = new GameMessage(currentUser.key, "", "");

      players.forEach((k, v) {
        Map<String, Object> jsonMap = {
          "to": v.fcmKey,
          "notification": {
            "title": "PLAYER_IS_ELIMINATED",
            "body": gameMessage.toJson(),
            "click_action": "FLUTTER_NOTIFICATION_CLICK"
          },
          "priority": 10
        };
        client.post(googleFcmUrl,
            body: jsonEncode(jsonMap), headers: headersMap);
      });

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    Widget mainGameWidget;
    if (gameCanStart) {
      if (challengeOccurred) {
        players.forEach((k, v) {
          cardsOnTable[k] = v.cards.length;
          if (k == currentUser.key) myCardsOnTable = List.of(v.cards);
        });
        challengeOccurred = false;
      }
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
            cardsSize: cardsOnTable[player.key],
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
                        onPressed:
                            (isNotificationAllowed && myCardsOnTable.length > 0)
                                ? _sendHasPlayedNotification
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
                        onPressed: (allPlayedOnce(cardsOnTable, players) &&
                                !challengeOccurred)
                            ? _sendChallengeNotification
                            : null,
                        child: Text("Lancer un défi"),
                      ),
                    ),
                  ],
                ),
                Container(
                  height: containerCardsHeight,
                  width: MediaQuery.of(context).size.width,
                  child: (myCardsOnTable.length > 0)
                      ? Swiper(
                          onIndexChanged: (int index) {
                            currentIndex = index;
                          },
                          itemCount: myCardsOnTable.length,
                          itemWidth: cardDiameter,
                          itemHeight: cardDiameter,
                          layout: SwiperLayout.STACK,
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
                              decoration: new BoxDecoration(
                                shape: BoxShape.circle,
                                image: new DecorationImage(
                                  fit: BoxFit.cover,
                                  image: AssetImage(cardsAssets[
                                      myCardsOnTable.elementAt(index)]),
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
                        )
                      : Container(
                          width: 0,
                          height: 0,
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
