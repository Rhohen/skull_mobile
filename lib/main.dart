import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n_delegate.dart';
import 'package:page_transition/page_transition.dart';
import 'package:skull_mobile/connexion/login.dart';
import 'package:skull_mobile/game/game.dart';
import 'package:skull_mobile/jouer.dart';
import 'package:skull_mobile/lobby/lobby.dart';
import 'package:skull_mobile/lobby/lobbyArguments.dart';
import 'package:skull_mobile/rejoindre/rejoindre.dart';
import 'package:skull_mobile/settings/settings.dart';
import 'package:skull_mobile/splash.dart';
import 'accueil.dart';
import 'creerLobby/creer.dart';
import 'game/gameArguments.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future main() async {
  final FlutterI18nDelegate flutterI18nDelegate = FlutterI18nDelegate(
      useCountryCode: false,
      fallbackFile: 'en',
      path: 'assets/i18n',
      forcedLocale: new Locale('fr'));
  WidgetsFlutterBinding.ensureInitialized();
  await flutterI18nDelegate.load(null);
  runApp(new MyApp(flutterI18nDelegate));
}

class MyApp extends StatelessWidget {
  static const routeName = '/root';
  final FlutterI18nDelegate flutterI18nDelegate;

  MyApp(this.flutterI18nDelegate);

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
          case CreerPage.routeName:
            return PageTransition(
              child: CreerPage(),
              type: PageTransitionType.fade,
              settings: settings,
            );
            break;
          case LoginPage.routeName:
            return PageTransition(
              child: LoginPage(),
              type: PageTransitionType.fade,
              settings: settings,
            );
            break;
          case AccueilPage.routeName:
            return PageTransition(
              child: AccueilPage(),
              type: PageTransitionType.fade,
              settings: settings,
            );
            break;
          case SettingsPage.routeName:
            return PageTransition(
              child: SettingsPage(),
              type: PageTransitionType.fade,
              settings: settings,
            );
            break;
          default:
            return null;
        }
      },
      title: 'Skull Mobile', // App name visible on task manager
      localizationsDelegates: [
        flutterI18nDelegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      theme: ThemeData(
        primaryColor: Colors.grey[700],
        cursorColor: Colors.grey[800],
        accentColor: Colors.grey[600],
        textSelectionHandleColor: Colors.grey[800],
      ),
      home: Scaffold(
        appBar: AppBar(
          title: new Text('Skull mobile', style: TextStyle(fontSize: 20)),
          backgroundColor: Colors.grey[800],
        ),
        body: SplashPage(),
      ),
    );
  }
}
