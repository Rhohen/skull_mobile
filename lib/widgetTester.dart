import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'dart:developer' as LOGGER;

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

  List<String> cards = [
    "img/rose.png",
    "img/rose.png",
    "img/rose.png",
    "img/skull.png"
  ];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    double cardSize = MediaQuery.of(context).size.height * 0.21;

    return MaterialApp(
      debugShowCheckedModeBanner: true,
      title: 'Skull Mobile', // App name visible on task manager
      home: Scaffold(
        body: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: cardSize + 20,
            width: MediaQuery.of(context).size.width,
            child: Swiper(
              onTap: (int index) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    // return object of type Dialog
                    return AlertDialog(
                      title: new Text("Card"),
                      content: new Text("<${cards[index]}> card"),
                      actions: <Widget>[
                        // usually buttons at the bottom of the dialog
                        new FlatButton(
                          child: new Text("Close"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              itemCount: cards.length,
              itemWidth: cardSize,
              itemHeight: cardSize,
              layout: SwiperLayout.STACK,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  decoration: new BoxDecoration(
                    shape: BoxShape.circle,
                    image: new DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage(cards[index]),
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
        ),
      ),
    );
  }
}
