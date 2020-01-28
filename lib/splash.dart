import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/scheduler.dart';
import 'package:skull_mobile/connexion/login.dart';
import 'accueil.dart';

class SplashPage extends StatefulWidget {
  SplashPage({Key key}) : super(key: key);

  @override
  _SplashPage createState() => _SplashPage();
}

class _SplashPage extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = new AnimationController(
      vsync: this,
      duration: new Duration(seconds: 5),
    );
    animationController.repeat();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new FutureBuilder<FirebaseUser>(
      future: FirebaseAuth.instance.currentUser(),
      builder: (context, AsyncSnapshot<FirebaseUser> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          snapshot.hasData
              ? SchedulerBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushReplacementNamed(
                      context, AccueilPage.routeName);
                })
              : SchedulerBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushReplacementNamed(context, LoginPage.routeName);
                });
          return Container();
        } else {
          return loadingScreen();
        }
      },
    );
  }

  Widget loadingScreen() {
    return new Scaffold(
      backgroundColor: Colors.grey[800],
      body: new Center(
        child: new Container(
          child: new AnimatedBuilder(
            animation: animationController,
            child: new Container(
              height: 150.0,
              width: 150.0,
              child: new Image.asset('assets/skull.png'),
            ),
            builder: (BuildContext context, Widget _widget) {
              return new Transform.rotate(
                angle: animationController.value * 6.3,
                child: _widget,
              );
            },
          ),
        ),
      ),
    );
  }
}
