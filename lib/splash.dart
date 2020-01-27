import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
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
    sleep(new Duration(seconds: 5));
    print('Sleep over');
    checkUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      body: Center(
        child: Container(
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

  void checkUser() async {
    FirebaseAuth.instance.currentUser().then((currentUser) => {
          if (currentUser == null)
            {Navigator.pushNamed(context, LoginPage.routeName)}
          else
            {Navigator.pushNamed(context, AccueilPage.routeName)}
        });
  }
}
