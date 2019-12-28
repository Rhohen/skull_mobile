import 'package:flutter/material.dart';
/*
class Lobby extends StatelessWidget {
  List<Widget> users = [];

  @override
  Widget build(BuildContext context) {

    LOGGER.log('log me', name: 'Lobby build context');


    users.add(SliverPersistentHeader(
      delegate: Person(
          name: 'Player 1',profileImg: 'img/pic-1.png',rank: "top 128"),
    ));

    return Scaffold(
      appBar: AppBar(
        title: Text('Lobby Page', style: TextStyle(fontSize: 20)),
        backgroundColor: Colors.grey[800],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10,10, 10, 10),
        child: CustomScrollView(
          slivers: users,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          users.removeAt(2);
        },
        child: Icon(Icons.navigation),
        backgroundColor: Colors.green,
      ),
    );
  }
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
*/
