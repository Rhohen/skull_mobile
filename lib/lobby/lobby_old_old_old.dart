import 'package:flutter/material.dart';
import 'dart:developer' as LOGGER;
/*
class Lobby extends StatefulWidget {
  @override
  _Lobby createState() => _Lobby();
}

class Person extends SliverPersistentHeaderDelegate {
  String name;
  String profileImg;
  String rank;

  Person({this.name, this.profileImg, this.rank});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Card(
        color: Colors.grey[800],
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                    width: 50.0,
                    height: 50.0,
                    decoration: new BoxDecoration(
                        shape: BoxShape.circle,
                        image: new DecorationImage(
                            fit: BoxFit.cover, image: AssetImage(profileImg)))),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    name,
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Text(
                    rank,
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 100.0;

  @override
  double get minExtent => 100.0;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

class _Lobby extends State<Lobby> {
  List<Person> persons = [
    Person(name: 'Player 1', profileImg: 'img/pic-1.png', rank: "top 128"),
    Person(name: 'Player 2', profileImg: 'img/pic-2.png', rank: "top 3"),
    Person(name: 'Player 3', profileImg: 'img/pic-3.png', rank: "top 2"),
    Person(name: 'Player 4', profileImg: 'img/pic-4.png', rank: "top 1123")
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lobby Page', style: TextStyle(fontSize: 20)),
        backgroundColor: Colors.grey[800],
      ),
      body: new Column(
        children: <Widget>[
          new Expanded(
              child: new ListView.builder(
                  itemCount: persons.length,
                  itemBuilder: (BuildContext ctxt, int Index) {
                    return new SliverPersistentHeader(delegate: persons[Index]);
                  }))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          persons.removeLast();
        },
        child: Icon(Icons.navigation),
        backgroundColor: Colors.green,
      ),
    );
  }
}
*/
