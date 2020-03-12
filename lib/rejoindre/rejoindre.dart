import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:skull_mobile/lobby/lobbyModel.dart';
import 'package:skull_mobile/rejoindre/dialogForm.dart';

class RejoindrePage extends StatefulWidget {
  static const routeName = '/RejoindrePage';

  @override
  _RejoindrePage createState() => _RejoindrePage();
}

class _RejoindrePage extends State<RejoindrePage> {
  DatabaseReference lobbyRef;
  Map availableRooms = new Map<String, dynamic>();
  List<LobbyModel> _lobbyList = new List();
  List<LobbyModel> _filteredLobbyList = new List();

  @override
  void initState() {
    super.initState();
    final FirebaseDatabase database = FirebaseDatabase.instance;

    lobbyRef = database.reference().child('lobbies');

    lobbyRef.once().then((DataSnapshot snapshot) {
      if (snapshot != null) {
        if (snapshot.value != null) {
          availableRooms = new Map<String, dynamic>.from(snapshot.value);
          availableRooms.forEach((k, v) {
            Map mapLobby = new Map<String, dynamic>.from(v);
            LobbyModel lobby = LobbyModel.from(k, mapLobby);
            lobby.set(mapLobby.length - 4);
            _lobbyList.add(lobby);
          });
        }
      }
      setState(() {});
    });

    lobbyRef.onChildAdded.listen(_onLobbyAdded);
    lobbyRef.onChildChanged.listen(_onLobbyChanged);
    lobbyRef.onChildRemoved.listen(_onLobbyRemoved);
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
          backgroundColor: Colors.grey[800],
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
            fillColor: Colors.grey[800],
          ),
          cursorColor: Colors.grey[800],
          textAlign: TextAlign.center,
        ));
  }

  Widget _createListView() {
    return new Flexible(
      child: new ListView.builder(
          itemCount: _lobbyList.length,
          itemBuilder: (BuildContext context, int index) {
            return new Card(
              color: Colors.grey[800],
              elevation: 5.0,
              child: new InkWell(
                splashColor: Colors.blue.withAlpha(30),
                onTap: () => showDialog(
                  context: context,
                  child: DialogForm(
                      _lobbyList[index].key, _lobbyList[index].password),
                ),
                child: ListTile(
                  leading: (_lobbyList[index].password != null &&
                          _lobbyList[index].password != "")
                      ? Icon(
                          Icons.lock,
                          size: 32,
                          color: Colors.white,
                        )
                      : null,
                  title: Text(
                    "${_lobbyList[index].name}",
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    "Joueurs ${_lobbyList[index].nbPlayers}/${_lobbyList[index].nbPlayerMax}",
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing: Icon(
                    Icons.play_circle_outline,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          }),
    );
  }

  Widget _performSearch() {
    _filteredLobbyList = new List();
    _lobbyList.forEach((lobby) => {
          if (lobby.name.toLowerCase().contains(_query.toLowerCase()))
            {_filteredLobbyList.add(lobby)}
        });
    return _createFilteredListView();
  }

  Widget _createFilteredListView() {
    return new Flexible(
      child: new ListView.builder(
          itemCount: _filteredLobbyList.length,
          itemBuilder: (BuildContext context, int index) {
            return new Card(
              color: Colors.grey[800],
              elevation: 5.0,
              child: new InkWell(
                splashColor: Colors.blue.withAlpha(30),
                onTap: () => showDialog(
                  context: context,
                  child: DialogForm(_filteredLobbyList[index].key,
                      _filteredLobbyList[index].password),
                ),
                child: ListTile(
                  leading: (_filteredLobbyList[index].password.isEmpty)
                      ? null
                      : Icon(Icons.lock, size: 32, color: Colors.white),
                  title: new Text(
                    "${_filteredLobbyList[index].name}",
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: new Text(
                    "Joueurs ${_filteredLobbyList[index].nbPlayers}/${_filteredLobbyList[index].nbPlayerMax}",
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing: Icon(
                    Icons.play_circle_outline,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          }),
    );
  }

  _onLobbyAdded(Event event) {
    if (this.mounted) {
      if (event.snapshot != null) {
        if (event.snapshot.value != null) {
          availableRooms = new Map<String, dynamic>.from(event.snapshot.value);
          setState(() {});
        }
      }
    }
  }

  _onLobbyChanged(Event event) {
    if (this.mounted) {
      if (event.snapshot != null) {
        if (event.snapshot.value != null) {
          availableRooms = new Map<String, dynamic>.from(event.snapshot.value);
          setState(() {});
        }
      }
    }
  }

  _onLobbyRemoved(Event event) {
    if (this.mounted) {
      if (event.snapshot != null) {
        if (event.snapshot.value != null) {
          availableRooms = new Map<String, dynamic>.from(event.snapshot.value);
          setState(() {});
        }
      }
    }
  }
}
