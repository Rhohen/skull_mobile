import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:skull_mobile/settings/settings.dart';

import '../localUser.dart';

class AvatarSelector extends StatefulWidget {
  var sendAvatar;

  AvatarSelector(this.sendAvatar);

  @override
  _AvatarSelectorState createState() =>
      new _AvatarSelectorState(this.sendAvatar);
}

class _AvatarSelectorState extends State<AvatarSelector> {
  Locale curentLang;
  int _key;
  String _avatar;
  var sendAvatar;

  List<String> avatars = [
    'assets/pic-1.png',
    'assets/pic-2.png',
    'assets/pic-3.png',
    'assets/pic-4.png',
    'assets/pic-5.png',
    'assets/pic-6.png'
  ];

  _AvatarSelectorState(this.sendAvatar);

  @override
  void initState() {
    super.initState();
    _avatar = "assets/skull.png";
    LocalUser.getAvatar().then((avatar) => setState(() {
          _avatar = avatar;
        }));
    _collapse();
  }

  @override
  Widget build(BuildContext context) {
    return _buildTiles(context);
  }

  List<Widget> _avatarItems() {
    List<Widget> list = [];
    avatars.forEach((avatar) {
      list.add(IconButton(
        icon: new Image.asset(avatar),
        onPressed: () => setAvatar(avatar),
      ));
    });

    List<Widget> row = [];
    row.add(new Row(
      children: list,
    ));

    return row;
  }

  Widget _buildTiles(BuildContext context) {
    return new ExpansionTile(
      key: new Key(_key.toString()),
      initiallyExpanded: false,
      title: showLogo(),
      children: _avatarItems(),
    );
  }

  Widget showLogo() {
    return new Hero(
      tag: 'hero',
      child: Padding(
        padding: EdgeInsets.fromLTRB(0.0, 25.0, 0.0, 0.0),
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 48.0,
          child: Image.asset(_avatar),
        ),
      ),
    );
  }

  _collapse() {
    int newKey;
    do {
      _key = new Random().nextInt(10000);
    } while (newKey == _key);
  }

  setAvatar(String avatar) {
    setState(() {
      _avatar = avatar;
    });
    sendAvatar(avatar);
  }
}
