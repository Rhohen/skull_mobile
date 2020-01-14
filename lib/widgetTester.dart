import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game/playerModel.dart';

class WidgetTester extends StatefulWidget {
  WidgetTester({Key key}) : super(key: key);
  static const routeName = '/WidgetTester';

  @override
  _WidgetTesterState createState() => _WidgetTesterState();
}

class _WidgetTesterState extends State<WidgetTester> {
  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    Map<String, Player> players = new LinkedHashMap();

    for (int i = 0; i < 5; i++) {
      players["toto$i"] = Player.generate();
    }

    return Scaffold(
      body: Container(),
    );
  }
}
