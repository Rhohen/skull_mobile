import 'package:flutter/material.dart';
import 'accueil.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Skull Mobile',
      home: Scaffold(
        body: WelcomePage(),
      ),
    );
  }
}
