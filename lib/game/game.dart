import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart';
import 'package:screen_state/screen_state.dart';
import 'package:skull_mobile/game/gameMessage.dart';
import 'package:skull_mobile/game/playerModel.dart';
import 'package:skull_mobile/game/playerWidget.dart';
import 'package:skull_mobile/lobby/userModel.dart';
import 'package:skull_mobile/settings/localUser.dart';
import 'package:synchronized/synchronized.dart';
import 'package:vector_math/vector_math.dart' hide Colors;
import 'package:skull_mobile/utils/Stack.dart' as StackUtils;
import 'dart:developer' as LOGGER;
import 'components/cardStack.dart';
import '../jouer.dart';
import 'EGameState.dart';
import 'components/defiDialog.dart';
import 'components/flippedCards.dart';

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
  /// To track the screen state, if locked then leave lobby
  StreamSubscription<ScreenStateEvent> _subscription;

  /// The current screen state
  Screen _screen;

  /// Timer used to retry connection
  Timer timer;

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

  /// Current lobby player (with losers)
  Map<String, String> lobbyPlayers;

  /// Actual turn index, only useful for the game owner to make the "nextTurn" system work
  int indexTurn;

  /// Object providing an implicit lock
  var lock = Lock();

  /// Boolean to know if the game can start
  bool gameCanStart;

  /// Boolean to know if a bet occured
  bool betOccurred;

  /// Boolean to know if its the challenge time (pick cards turn)
  bool challengeTime;

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

  /// Players stack cards on table<playerKey, current turn cards number>
  Map<String, StackUtils.Stack<String>> cardsOnTable;

  /// Players cards length on hand <playerKey, current turn cards number>
  Map<String, int> cardsOnHand;

  /// Current player card deck
  List<String> myCardsOnHand;

  /// Last gambler flipped cards
  List<String> flippedCards;

  /// Current player card index
  int currentIndex;

  /// Number of card currently on the table
  int nbCarteJouer;

  /// Bool to init current player card if its a new turn
  bool newTurn;

  /// Last gambler key
  String lastGamblerKey;

  /// Last gambler value
  int lastGamblerValue;

  /// The flushbar
  Flushbar flushbar;

  GamePageState(this.lobbyId, this.currentUser);

  @override
  void initState() {
    super.initState();
    gameCanStart = false;
    betOccurred = false;
    challengeTime = false;
    newTurn = true;
    flushbar = Flushbar();
    cardsOnTable = new HashMap();
    currentIndex = 0;
    indexTurn = 0;
    nbCarteJouer = 0;
    lastGamblerValue = 0;
    lastGamblerKey = "";
    cardsOnHand = new HashMap();
    lobbyPlayers = new HashMap();
    myCardsOnHand = new List();
    flippedCards = new List();
    timer = Timer.periodic(Duration(seconds: 3), (Timer t) => setState(() {}));

    startListening();

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
              nbCarteJouer++;
              cardsOnHand[gameMessage.currentPlayer]--;
              players[gameMessage.currentPlayer].isTurn = false;

              cardsOnTable[gameMessage.currentPlayer].push(gameMessage.message);

              if (currentUser.key != gameMessage.currentPlayer) {
                LOGGER.log(
                    "Player ${players[gameMessage.currentPlayer].name} played a ${gameMessage.message}");
              } else {
                LOGGER.log(
                    'Message sent successfully, you played a ${gameMessage.message}');
              }
              if (currentUser.isOwner == 'true') {
                _sendNextTurn(players.values.elementAt(indexTurn).key);
              }
              setState(() {});
              break;
            case 'NEXT_TURN':
              gameCanStart = true;
              if (gameMessage.currentPlayer.isNotEmpty) {
                LOGGER.log(
                    "Previous player was ${players[gameMessage.currentPlayer].name}");
                players[gameMessage.currentPlayer].isTurn = false;
              }
              if (gameMessage.nextPlayer == currentUser.key) {
                showFlushMessage("C'est à votre tour de jouer",
                    Colors.blue[300], Duration(seconds: 5));
              } else {
                showFlushMessage(
                    "C'est le tour de ${players[gameMessage.nextPlayer].name}",
                    Colors.blue[300],
                    Duration(seconds: 5));
              }
              LOGGER.log(
                  "Next player is ${players[gameMessage.nextPlayer].name}");
              players[gameMessage.nextPlayer].isTurn = true;
              setState(() {});
              break;
            case 'PLAYER_IS_ELIMINATED':
              indexTurn = (indexTurn == 0 ? players.length - 1 : indexTurn - 1);

              showFlushMessage("${players[gameMessage.message].name} a perdu",
                  Colors.red[500], null);

              players.remove(gameMessage.message);

              setState(() {});
              if (players.length <= 1) {
                showFlushMessage(
                    "${players[players.keys.first].name} a GAGNÉ !",
                    Colors.orange[300],
                    null);
                showEndGamePopup(players.keys.first);
              } else {
                if (currentUser.isOwner == 'true') {
                  _sendNextTurn("");
                }
              }
              break;
            case 'PLAYER_HAS_BET':
              betOccurred = true;
              players[gameMessage.currentPlayer].isTurn = false;

              lastGamblerKey = gameMessage.currentPlayer;
              lastGamblerValue = int.parse(gameMessage.message);

              if (currentUser.key != gameMessage.currentPlayer) {
                LOGGER.log(
                    "Player ${players[gameMessage.currentPlayer].name} bet ${gameMessage.message}");
              } else {
                LOGGER.log('Bet sent successfully');
              }
              if (currentUser.isOwner == 'true') {
                if (betCanContinue()) {
                  LOGGER.log('Bet can continue');
                  _sendNextBet(players.values.elementAt(indexTurn).key,
                      gameMessage.message);
                } else {
                  LOGGER.log('Bet stopped');
                  _sendBetEndedNotification(
                      lastGamblerKey, lastGamblerValue.toString());
                }
              }
              setState(() {});
              break;
            case 'NEXT_BET':
              players[gameMessage.nextPlayer].isTurn = true;

              if (gameMessage.message.isNotEmpty) {
                LOGGER.log(
                    "Previous player was ${players[gameMessage.currentPlayer].name} and bet ${gameMessage.message}, next player is ${players[gameMessage.nextPlayer].name}");

                if (gameMessage.nextPlayer == currentUser.key) {
                  showFlushMessage(
                      "${players[gameMessage.currentPlayer].name} a parié ${gameMessage.message}, à votre tour !",
                      Colors.blue[300],
                      null);
                } else {
                  showFlushMessage(
                      "${players[gameMessage.currentPlayer].name} a parié ${gameMessage.message}, à ${players[gameMessage.nextPlayer].name} de parier !",
                      Colors.blue[300],
                      null);
                }
              } else {
                LOGGER.log(
                    "Previous player was ${players[gameMessage.currentPlayer].name} and skipped, next player is ${players[gameMessage.nextPlayer].name}");
                showFlushMessage(
                    "${players[gameMessage.currentPlayer].name} passe son tour, à ${players[gameMessage.nextPlayer].name} de parier !",
                    Colors.blue[300],
                    Duration(seconds: 5));
              }
              setState(() {});
              break;
            case 'PLAYER_HAS_SKIPPED':
              LOGGER.log(
                  "Player ${players[gameMessage.currentPlayer].name} has skipped");
              players[gameMessage.currentPlayer].isTurn = false;
              players[gameMessage.currentPlayer].hasSkipped = true;

              if (currentUser.isOwner == 'true') {
                if (betCanContinue()) {
                  _sendNextBet(players.values.elementAt(indexTurn).key,
                      gameMessage.message);
                } else {
                  _sendBetEndedNotification(
                      lastGamblerKey, lastGamblerValue.toString());
                }
              }

              setState(() {});
              break;
            case 'BET_TIME_ENDED':
              lastGamblerValue = int.parse(gameMessage.message);
              lastGamblerKey = gameMessage.currentPlayer;
              nbCarteJouer = 0;
              betOccurred = false;
              challengeTime = true;
              players[lastGamblerKey].isTurn = true;

              players.forEach((key, player) {
                players[key].hasSkipped = false;
              });

              if (lastGamblerKey == currentUser.key) {
                showFlushMessage(
                    "Vous avez $lastGamblerValue roses à trouver !",
                    Colors.blue[300],
                    Duration(seconds: 5));
                flipOwnCardsFirst();
              } else {
                showFlushMessage(
                    "${players[lastGamblerKey].name} a $lastGamblerValue roses à trouver !",
                    Colors.blue[300],
                    Duration(seconds: 5));
              }

              setState(() {});
              break;
            case 'CARD_FLIPPED':
              if (flippedCards.length < lastGamblerValue) {
                flippedCards.add(gameMessage.message);

                if (currentUser.key != gameMessage.nextPlayer) {
                  cardsOnTable[gameMessage.currentPlayer].pop();
                }
                if (gameMessage.message == 'skull') {
                  showFlushMessage(
                      "Perdu ! ${players[gameMessage.nextPlayer].name} perd une carte !",
                      Colors.red[500],
                      Duration(seconds: 5));

                  List<String> cardsList =
                      players[gameMessage.nextPlayer].cards;

                  if (cardsList.length > 0) {
                    int cardIndex = new Random().nextInt(cardsList.length);
                    LOGGER.log(players[gameMessage.nextPlayer].name +
                        " perd la carte : n° " +
                        cardIndex.toString());
                    players[gameMessage.nextPlayer].cards.removeAt(cardIndex);
                  }
                  if (currentUser.isOwner == 'true') {
                    Future.delayed(const Duration(seconds: 3), () {
                      setState(() {
                        _sendChallengeEndedNotification();
                      });
                    });
                  }
                } else if (flippedCards.length >= lastGamblerValue) {
                  if (players[gameMessage.nextPlayer].hasScored) {
                    showFlushMessage(
                        "${players[gameMessage.nextPlayer].name} a GAGNÉ !",
                        Colors.orange[300],
                        Duration(seconds: 5));
                    showEndGamePopup(gameMessage.nextPlayer);
                  } else {
                    showFlushMessage(
                        "Un point de marqué pour ${players[gameMessage.nextPlayer].name} !",
                        Colors.orange[300],
                        Duration(seconds: 5));
                    players[gameMessage.nextPlayer].hasScored = true;

                    if (currentUser.isOwner == 'true') {
                      Future.delayed(const Duration(seconds: 3), () {
                        setState(() {
                          _sendChallengeEndedNotification();
                        });
                      });
                    }
                  }
                }
              }
              setState(() {});
              break;
            case 'CHALLENGE_TIME_ENDED':
              lastGamblerValue = 0;
              challengeTime = false;
              newTurn = true;
              players[gameMessage.currentPlayer].isTurn = false;

              List<String> cardsList = players[gameMessage.currentPlayer].cards;

              if (currentUser.isOwner == 'true') {
                if (cardsList.length <= 0)
                  _sendEliminatedNotification(gameMessage.currentPlayer);
                else
                  _sendNextTurn(players.values.elementAt(indexTurn).key);
              }
              setState(() {});
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

                if (players.containsKey(k)) {
                  players[k].copyFromUser(updatedUser);
                } else {
                  players[k] = Player.fromUser(updatedUser);
                }
                lobbyPlayers[k] = updatedUser.fcmKey;
              });

              currentUser.isReady = 'true';
              lobbyRef.child(currentUser.key).set(currentUser.toJson());
            }
          }
        });
      });
    });
  }

  void onData(ScreenStateEvent event) {
    if (ScreenStateEvent.SCREEN_OFF == event) _onBackPressed();
  }

  void startListening() {
    _screen = new Screen();
    try {
      _subscription = _screen.screenStateStream.listen(onData);
    } on ScreenStateException catch (exception) {
      print(exception);
    }
  }

  void stopListening() {
    _subscription.cancel();
  }

  void showEndGamePopup(String winnerKey) {
    if (currentUser.key == winnerKey) LocalUser().setScore();
    AwesomeDialog(
      customHeader: Container(
        width: 100.0,
        height: 100.0,
        decoration: new BoxDecoration(
          shape: BoxShape.circle,
          image: new DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage((currentUser.key == winnerKey)
                ? 'assets/winner.png'
                : 'assets/looser.jpeg'),
          ),
        ),
      ),
      context: context,
      animType: AnimType.TOPSLIDE,
      tittle: (currentUser.key == winnerKey)
          ? 'Vous avez gagné !'
          : 'Tu as PERDU !',
      desc: (currentUser.key == winnerKey)
          ? 'Je suis ravi de vous voir accomplir de grandes choses.'
          : 'En vérité il y a peut être un peu de perdant en chacun de nous...',
      btnOk: FlatButton(
        shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(18.0),
            side: BorderSide(color: Colors.grey)),
        child: Text('Quitter la partie'),
        onPressed: () {
          if (!closeGame) lobbyRef.child("state").set(EGameState.FINISHED);
          SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
          client.close();
          stopListening();
          lobbyRef.child(currentUser.key).remove();
          Navigator.popUntil(context, ModalRoute.withName(JouerPage.routeName));
        },
      ),
      //this is ignored
      btnOkOnPress: () {},
    ).show();
  }

  void flipOwnCardsFirst() {
    int nbIter = min(lastGamblerValue, cardsOnTable[currentUser.key].size());
    ListQueue tempoStack = cardsOnTable[currentUser.key].getList();

    for (int i = 0; i < nbIter; i++) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _sendFlipNotification(currentUser.key);
      });
      String card = tempoStack.last;
      tempoStack.removeLast();
      if (card == 'skull') {
        break;
      }
    }
  }

  bool betCanContinue() {
    if (lastGamblerValue >= nbCarteJouer) {
      return false;
    }

    int nbPlayersOnTable = 0;

    players.values.forEach((player) {
      if (player.hasSkipped == false) {
        nbPlayersOnTable++;
      }
    });
    LOGGER.log("There is $nbPlayersOnTable players on table");
    return nbPlayersOnTable >= 2;
  }

  Future<void> showFlushMessage(
      String message, Color color, Duration duration) async {
    await lock.synchronized(() async {
      flushbar.dismiss().then((onValue) {
        flushbar = Flushbar(
          flushbarPosition: FlushbarPosition.TOP,
          icon: Icon(
            Icons.info_outline,
            size: 28.0,
            color: color,
          ),
          title: "Action !",
          leftBarIndicatorColor: color,
          message: "$message",
          duration: duration,
          isDismissible: true,
          dismissDirection: FlushbarDismissDirection.HORIZONTAL,
        );
        flushbar.show(context);
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

          if (players.containsKey(event.snapshot.key)) {
            players[event.snapshot.key].copyFromUser(updatedUser);
          } else {
            players[event.snapshot.key] = Player.fromUser(updatedUser);
          }
          lobbyPlayers[event.snapshot.key] = updatedUser.fcmKey;

          if (currentUser.isOwner == 'true' && allUsersReady()) {
            gameCanStart = true;
            LOGGER.log("The game can start, sending orders to next player...");
            _sendNextTurn(players.values.elementAt(indexTurn).key);
          }
        });
      } else if (event.snapshot.key == 'state' &&
          event.snapshot.value == EGameState.STOPPED) {
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
    return nextPlayer;
  }

  void _sendBetEndedNotification(
      String _lastGamblerKey, String _lastGamblerValue) {
    GameMessage gameMessage = new GameMessage(
      _lastGamblerValue,
      _lastGamblerKey,
      "",
    );

    lobbyPlayers.forEach((k, fcmKey) {
      Map<String, Object> jsonMap = {
        "to": fcmKey,
        "notification": {
          "title": "BET_TIME_ENDED",
          "body": gameMessage.toJson(),
          "click_action": "FLUTTER_NOTIFICATION_CLICK"
        },
        "priority": 10
      };
      client.post(googleFcmUrl, body: jsonEncode(jsonMap), headers: headersMap);
    });
    setState(() {});
  }

  void _sendChallengeEndedNotification() {
    GameMessage gameMessage = new GameMessage(
      "",
      lastGamblerKey,
      "",
    );

    lobbyPlayers.forEach((k, fcmKey) {
      Map<String, Object> jsonMap = {
        "to": fcmKey,
        "notification": {
          "title": "CHALLENGE_TIME_ENDED",
          "body": gameMessage.toJson(),
          "click_action": "FLUTTER_NOTIFICATION_CLICK"
        },
        "priority": 10
      };
      client.post(googleFcmUrl, body: jsonEncode(jsonMap), headers: headersMap);
    });
    setState(() {});
  }

  void _sendNextBet(String currentPlayerKey, String value) {
    GameMessage gameMessage = new GameMessage(
      value,
      currentPlayerKey,
      getNextPlayer().key,
    );

    lobbyPlayers.forEach((k, fcmKey) {
      Map<String, Object> jsonMap = {
        "to": fcmKey,
        "notification": {
          "title": "NEXT_BET",
          "body": gameMessage.toJson(),
          "click_action": "FLUTTER_NOTIFICATION_CLICK"
        },
        "priority": 10
      };
      client.post(googleFcmUrl, body: jsonEncode(jsonMap), headers: headersMap);
    });
    setState(() {});
  }

  void _sendNextTurn(String currentPlayerKey) {
    GameMessage gameMessage = new GameMessage(
      "",
      currentPlayerKey,
      getNextPlayer().key,
    );

    lobbyPlayers.forEach((k, fcmKey) {
      Map<String, Object> jsonMap = {
        "to": fcmKey,
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

  void _sendHasBetNotification(String value) {
    players[currentUser.key].isTurn = false;
    GameMessage gameMessage = new GameMessage(
      value,
      currentUser.key,
      "",
    );

    lobbyPlayers.forEach((k, fcmKey) {
      Map<String, Object> jsonMap = {
        "to": fcmKey,
        "notification": {
          "title": "PLAYER_HAS_BET",
          "body": gameMessage.toJson(),
          "click_action": "FLUTTER_NOTIFICATION_CLICK"
        },
        "priority": 10
      };
      client.post(googleFcmUrl, body: jsonEncode(jsonMap), headers: headersMap);
    });
    setState(() {});
  }

  Future<void> _sendFlipNotification(String userSelected) async {
    await lock.synchronized(() async {
      LOGGER.log("I selected user ${players[userSelected].name}");
      if (cardsOnTable[userSelected].isNotEmpty) {
        String cardFlipped = cardsOnTable[userSelected].pop();

        if (cardFlipped == 'skull') {
          setState(() {
            players[currentUser.key].isTurn = false;
          });
        }
        GameMessage gameMessage = new GameMessage(
          cardFlipped,
          userSelected,
          currentUser.key,
        );

        lobbyPlayers.forEach((k, fcmKey) {
          Map<String, Object> jsonMap = {
            "to": fcmKey,
            "notification": {
              "title": "CARD_FLIPPED",
              "body": gameMessage.toJson(),
              "click_action": "FLUTTER_NOTIFICATION_CLICK"
            },
            "priority": 10
          };
          client.post(googleFcmUrl,
              body: jsonEncode(jsonMap), headers: headersMap);
        });
      } else {
        LOGGER.log("Plus de cartes sur la table");
        if (userSelected == currentUser.key) {
          showFlushMessage(
              "Tu n'as plus de carte devant toi, essaye un autre joueur !",
              Colors.blue[300],
              Duration(seconds: 3));
        } else {
          showFlushMessage(
              "${players[userSelected].name} n'a plus de cartes devant lui, essaye un autre joueur !",
              Colors.blue[300],
              Duration(seconds: 3));
        }
      }
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
      lobbyRef.child("state").set(EGameState.STOPPED);
    }
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    client.close();
    stopListening();
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
      Map<String, int> _cardsOnHand, Map<String, Player> players) {
    String currentUserKey = currentUser.key;
    Player currentPlayer = players[currentUserKey];

    if (currentPlayer != null) {
      return (_cardsOnHand[currentUser.key] < currentPlayer.cards.length - 1) ||
          (currentPlayer.isTurn &&
              _cardsOnHand[currentUser.key] < currentPlayer.cards.length);
    }
    return false;
  }

  Future<void> _sendHasPlayedNotification() async {
    players[currentUser.key].isTurn = false;
    await lock.synchronized(() async {
      if (currentIndex == myCardsOnHand.length) {
        currentIndex--;
      }
      GameMessage gameMessage = new GameMessage(
        myCardsOnHand.elementAt(currentIndex),
        currentUser.key,
        "",
      );
      myCardsOnHand.removeAt(currentIndex);
      //currentIndex = (currentIndex == 0 ? myCardsOnHand.length : currentIndex - 1);

      lobbyPlayers.forEach((k, fcmKey) {
        Map<String, Object> jsonMap = {
          "to": fcmKey,
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
    });
  }

  Future<void> _sendSkipTurnNotification() async {
    players[currentUser.key].isTurn = false;
    await lock.synchronized(() async {
      GameMessage gameMessage = new GameMessage(
        "",
        currentUser.key,
        "",
      );

      lobbyPlayers.forEach((k, fcmKey) {
        Map<String, Object> jsonMap = {
          "to": fcmKey,
          "notification": {
            "title": "PLAYER_HAS_SKIPPED",
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

  Future<void> openPopup() {
    return showDialog(
      context: context,
      child: DefiDialog(
          lastGamblerValue + 1, nbCarteJouer, _sendHasBetNotification),
    );
  }

  Future<void> _sendEliminatedNotification(String eliminatedPlayer) async {
    await lock.synchronized(() async {
      GameMessage gameMessage = new GameMessage(eliminatedPlayer, "", "");

      lobbyPlayers.forEach((k, fcmKey) {
        Map<String, Object> jsonMap = {
          "to": fcmKey,
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
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    Widget mainGameWidget;
    if (gameCanStart) {
      timer?.cancel();
      if (newTurn) {
        flippedCards = new List();
        players.forEach((k, v) {
          cardsOnTable[k] = new StackUtils.Stack();
          cardsOnHand[k] = v.cards.length;
          if (k == currentUser.key) myCardsOnHand = List.of(v.cards);
        });
        newTurn = false;
      }

      /*
      // === DEBUG === //

      players.clear();
      cardsOnHand.clear();
      for (int i = 0;i<5;i++){
        players[i.toString()] = Player.generate();
        players[i.toString()].key = i.toString();
        cardsOnHand[i.toString()] = 0;
      }
      players[currentUser.key] = Player.generate();
      players[currentUser.key].key = currentUser.key;
      cardsOnHand[currentUser.key] = 0;
      // =========== //
      */

      bool isPortrait =
          MediaQuery.of(context).orientation == Orientation.portrait;
      double tableDiameter;
      double sizeMultiplier;
      Vector2 tablePosition = new Vector2(0.0, 0.0);
      double imgSize = 36.0;
      double cardsSize = 30;
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
      List<Widget> cardsStacks = new List();

      int numberOfPlayers = players.length;

      double spacePlayer = 360 / numberOfPlayers;
      double textSize = 14, textScaleFactor = 1;
      double heightTextSize = textSize * textScaleFactor;
      double widthContainerSize = 80;

      bool isCurrentChallenge = false;
      if (challengeTime && players.containsKey(currentUser.key)) {
        isCurrentChallenge = players[currentUser.key].isTurn;
      }

      for (int i = 0; i < numberOfPlayers; i++) {
        Player player = players.values.elementAt(i);
        Vector2 playerPosition = getPosition(
            tablePosition, (tableDiameter / 2) + 20, spacePlayer * i);

        Vector2 cardsPosition = getPosition(tablePosition, 35, spacePlayer * i);

        double centeredHorizontalValue =
            max(imgSize / 2, widthContainerSize / 2);
        double centeredVerticalValue = imgSize / 2 +
            heightTextSize / 2 +
            ((player.isTurn) ? imgSize / 2 : 0);

        int nbCardsOnTable = cardsOnTable[player.key].size();
        cardsStacks.add(
          Positioned(
            top: (cardsPosition.x - cardsSize / 2),
            left: (cardsPosition.y - (cardsSize / 2)),
            child: CardStack(
              cardPath: "assets/rose.png",
              cardRadius: cardsSize,
              playerAngle: spacePlayer * i,
              cardBorderWidth: 0,
              nbCardsOnTable: nbCardsOnTable,
            ),
          ),
        );
        playersIcon.add(
          PlayerWidget(
            userKey: player.key,
            top: (playerPosition.x - centeredVerticalValue),
            left: (playerPosition.y - centeredHorizontalValue),
            maxWidthContainer: widthContainerSize,
            isPlayerTurn: player.isTurn,
            iconSize: imgSize,
            hasScored: player.hasScored,
            profileImg: player.profileImg,
            playerName: player.name,
            textSize: textSize,
            textScaleFactor: textScaleFactor,
            cardsSize: cardsOnHand[player.key],
            sendCardFlipChoice: _sendFlipNotification,
            isIconClickable: (nbCardsOnTable > 0) ? isCurrentChallenge : false,
          ),
        );
      }

      Widget flippedWidget = new Container();
      if (challengeTime) {
        flippedWidget = FlippedCards(
          flippedCards: flippedCards,
          betNumber: lastGamblerValue,
        );
      }

      List<Widget> interfaceUser = new List();
      if (players.containsKey(currentUser.key)) {
        interfaceUser.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              ButtonTheme(
                height: buttonSize,
                buttonColor: Colors.green,
                textTheme: ButtonTextTheme.primary,
                child: (!betOccurred)
                    ? RaisedButton(
                        onPressed: (players[currentUser.key].isTurn &&
                                myCardsOnHand.length > 0 &&
                                !challengeTime)
                            ? _sendHasPlayedNotification
                            : null,
                        child: Text("Poser une carte"),
                      )
                    : RaisedButton(
                        onPressed: (players[currentUser.key].isTurn)
                            ? _sendSkipTurnNotification
                            : null,
                        child: Text("Passer son tour"),
                      ),
              ),
              SizedBox(width: 20),
              ButtonTheme(
                height: buttonSize,
                buttonColor: Colors.blueAccent,
                textTheme: ButtonTextTheme.primary,
                child: (!betOccurred)
                    ? RaisedButton(
                        onPressed: (players[currentUser.key].isTurn &&
                                allPlayedOnce(cardsOnHand, players) &&
                                !challengeTime)
                            ? openPopup
                            : null,
                        child: Text("Lancer un défi"),
                      )
                    : RaisedButton(
                        onPressed: (players[currentUser.key].isTurn)
                            ? openPopup
                            : null,
                        child: Text("Parier"),
                      ),
              ),
            ],
          ),
        );
        interfaceUser.add(
          Container(
            height: containerCardsHeight,
            width: MediaQuery.of(context).size.width,
            child: (myCardsOnHand.length > 0)
                ? Swiper(
                    onIndexChanged: (int index) {
                      currentIndex = index;
                    },
                    itemCount: myCardsOnHand.length,
                    itemWidth: cardDiameter,
                    itemHeight: cardDiameter,
                    layout: SwiperLayout.STACK,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        decoration: new BoxDecoration(
                          shape: BoxShape.circle,
                          image: new DecorationImage(
                            fit: BoxFit.cover,
                            image: AssetImage(
                                cardsAssets[myCardsOnHand.elementAt(index)]),
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
                  ...cardsStacks,
                  ...playersIcon,
                ],
              ),
            ),
          ),
          Container(
            child: Column(
              children: <Widget>[
                flippedWidget,
                Divider(
                  height: dividerHeight,
                  indent: 15,
                  endIndent: 15,
                ),
                ...interfaceUser
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
                    Text("La partie se charge.."),
                  ],
                ),
              )),
      ),
    );
  }
}
