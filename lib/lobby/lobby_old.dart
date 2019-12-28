import 'package:flutter/material.dart';
/*
class Lobby extends StatefulWidget {
  @override
  _Lobby createState() => _Lobby();
}

class Person {
  String name;
  String profileImg;
  String rank;

  Person({this.name, this.profileImg, this.rank});
}

class _Lobby extends State<Lobby> {
  List<Person> persons = [
    Person(name: 'Player 1', profileImg: 'img/pic-1.png', rank: "top 128"),
    Person(name: 'Player 2', profileImg: 'img/pic-2.png', rank: "top 3"),
    Person(name: 'Player 3', profileImg: 'img/pic-3.png', rank: "top 2"),
    Person(name: 'Player 4', profileImg: 'img/pic-4.png', rank: "top 1123")
  ];

  Widget personDetailCard(Person p) {
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
                            fit: BoxFit.cover,
                            image: AssetImage(p.profileImg)))),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    p.name,
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Text(
                    p.rank,
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lobby Page', style: TextStyle(fontSize: 20)),
        backgroundColor: Colors.grey[800],
      ),
      body: Padding(
          padding: const EdgeInsets.fromLTRB(10,10, 10, 10),
          child: Column(
              children: persons.map((p) {
                return personDetailCard(p);
              }).toList())),
    );
  }
}
*/
