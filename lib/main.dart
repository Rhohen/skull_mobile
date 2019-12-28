import 'package:flutter/material.dart';
import 'accueil.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
