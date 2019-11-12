import 'package:flutter/material.dart';

class RejoindrePage extends StatefulWidget {
  @override
  _RejoindrePage createState() => _RejoindrePage();
}

class _RejoindrePage extends State<RejoindrePage> {
  var _searchview = new TextEditingController();

  final List<String> _nebulae = [
    "Orion",
    "Boomerang",
    "Cat's Eye",
    "Pelican",
    "Ghost Head",
    "Witch Head",
    "Snake",
    "Ant",
    "Bernad 68",
    "Flame",
    "Eagle",
    "Horse Head",
    "Elephant's Trunk",
    "Butterfly"
  ];
  List<String> _filterList;
  final List<int> colorCodes = <int>[600, 500, 400, 300, 200, 100];

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
          itemCount: _nebulae.length,
          itemBuilder: (BuildContext context, int index) {
            return new Card(
              color: Colors.white,
              elevation: 5.0,
              child: new Container(
                margin: EdgeInsets.all(15.0),
                child: new Text("${_nebulae[index]}"),
              ),
            );
          }),
    );
  }

  Widget _performSearch() {
    _filterList = new List<String>();
    for (int i = 0; i < _nebulae.length; i++) {
      var item = _nebulae[i];

      if (item.toLowerCase().contains(_query.toLowerCase())) {
        _filterList.add(item);
      }
    }
    return _createFilteredListView();
  }

  Widget _createFilteredListView() {
    return new Flexible(
      child: new ListView.builder(
          itemCount: _filterList.length,
          itemBuilder: (BuildContext context, int index) {
            return new Card(
              color: Colors.white,
              elevation: 5.0,
              child: new Container(
                margin: EdgeInsets.all(15.0),
                child: new Text("${_filterList[index]}"),
              ),
            );
          }),
    );
  }
}
