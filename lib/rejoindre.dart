import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'lobby/lobby.dart';
import 'lobby/lobbyArguments.dart';
import 'lobby/userModel.dart';

class RejoindrePage extends StatefulWidget {
  static const routeName = '/RejoindrePage';

  @override
  _RejoindrePage createState() => _RejoindrePage();
}

class _RejoindrePage extends State<RejoindrePage> {
  DatabaseReference lobbyRef;
  Map availableRooms = new Map<String, dynamic>();
  Map filteredRooms;

  @override
  void initState() {
    super.initState();
    final FirebaseDatabase database = FirebaseDatabase.instance;

    lobbyRef = database.reference().child('lobbies');

    lobbyRef.once().then((DataSnapshot snapshot) {
      if (snapshot != null) {
        if (snapshot.value != null) {
          availableRooms = new Map<String, dynamic>.from(snapshot.value);
        }
      }
      setState(() {});
    });
  }

  var _searchview = new TextEditingController();

  bool _firstSearch = true;
  String _query = "";

  _RejoindrePage() {
    //Register a closure to be called when the object changes.
    _searchview.addListener(() {
      if (_searchview.text.isEmpty) {
        //Notify the framework that the internal state of this object has changed.
        setState(() {
          _firstSearch = true;
          _query = "";
        });
      } else {
        setState(() {
          _firstSearch = false;
          _query = _searchview.text;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Rejoindre Partie",
            style: TextStyle(fontSize: 20),
          ),
        ),
        body: Container(
            child: Column(
          children: <Widget>[
            _createSearchView(),
            _firstSearch ? _createListView() : _performSearch()
          ],
        )));
  }

  Widget _createSearchView() {
    return Container(
        decoration: BoxDecoration(border: Border.all(width: 1.0)),
        child: TextField(
          controller: _searchview,
          decoration: InputDecoration(
            hintText: "Search",
          ),
          textAlign: TextAlign.center,
        ));
  }

  Widget _createListView() {
    return new Flexible(
      child: new ListView.builder(
          itemCount: availableRooms.length,
          itemBuilder: (BuildContext context, int index) {
            return new Card(
              color: Colors.white,
              elevation: 5.0,
              child: new InkWell(
                  splashColor: Colors.blue.withAlpha(30),
                  onTap: () {
                    print('Lobby Selected');
                    LobbyArguments lobbyArgs = new LobbyArguments(
                        "-Lx7KJcaKvlwpe2z2dEp",
                        User.generate("admin"),
                        context);
                    Navigator.pushNamed(context, Lobby.routeName,
                        arguments: lobbyArgs);
                  },
                  child: ListTile(
                    leading: (availableRooms.length > 0)
                        ? Icon(Icons.lock, size: 32)
                        : null,
                    title: new Text("${availableRooms.keys}"),
                    subtitle: new Text("Joueurs 3/8"),
                    trailing: Icon(Icons.play_circle_outline),
                  )),
              /*child: new Container(
                margin: EdgeInsets.all(15.0),
                child: new Text("${availableRooms.keys}"),
              ),*/
            );
          }),
    );
  }

  Widget _performSearch() {
    filteredRooms = new Map<String, dynamic>();
    availableRooms.forEach((k, v) => {
          if (k.toString().toLowerCase().contains(_query.toLowerCase()))
            {filteredRooms.putIfAbsent(k, () => v)}
        });
    return _createFilteredListView();
  }

  Widget _createFilteredListView() {
    return new Flexible(
      child: new ListView.builder(
          itemCount: filteredRooms.length,
          itemBuilder: (BuildContext context, int index) {
            return new Card(
              color: Colors.white,
              elevation: 5.0,
              child: new InkWell(
                  splashColor: Colors.blue.withAlpha(30),
                  onTap: () {
                    print('Lobby Selected');
                  },
                  child: ListTile(
                    leading: (filteredRooms.length > 0)
                        ? Icon(Icons.lock, size: 32)
                        : null,
                    title: new Text("${filteredRooms.keys}"),
                    subtitle: new Text("Joueurs 3/8"),
                    trailing: Icon(Icons.play_circle_outline),
                  )),
              /*child: new Container(
                margin: EdgeInsets.all(15.0),
                child: new Text("${availableRooms.keys}"),
              ),*/
            );
          }),
    );
  }
}
