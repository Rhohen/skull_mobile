import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:skull_mobile/game/game.dart';
import 'package:skull_mobile/jouer.dart';
import 'package:skull_mobile/lobby/lobby.dart';
import 'package:skull_mobile/lobby/lobbyArguments.dart';
import 'package:skull_mobile/rejoindre/rejoindre.dart';
import 'accueil.dart';
import 'game/gameArguments.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  static const routeName = '/root';

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case JouerPage.routeName:
            return PageTransition(
              child: JouerPage(),
              type: PageTransitionType.fade,
              settings: settings,
            );
            break;
          case RejoindrePage.routeName:
            return PageTransition(
              child: RejoindrePage(),
              type: PageTransitionType.fade,
              settings: settings,
            );
            break;
          case Lobby.routeName:
            LobbyArguments lobbyArguments = settings.arguments;
            return PageTransition(
              child: Lobby(lobbyArguments.lobbyId, lobbyArguments.currentUser,
                  lobbyArguments.lobbiesContext),
              type: PageTransitionType.fade,
              settings: settings,
            );
            break;
          case GamePage.routeName:
            GameArguments gameArguments = settings.arguments;
            return PageTransition(
              child: GamePage(gameArguments.lobbyId, gameArguments.currentUser),
              type: PageTransitionType.fade,
              settings: settings,
            );
            break;
          default:
            return null;
        }
      },
      title: 'Skull Mobile', // App name visible on task manager
      home: Scaffold(
        appBar: AppBar(
          title: Text('Skull Mobile', style: TextStyle(fontSize: 20)),
          backgroundColor: Colors.grey[800],
        ),
        body: AccueilPage(),
      ),
    );
  }
}
