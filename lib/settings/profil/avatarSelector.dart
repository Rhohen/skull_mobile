import 'dart:math';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class AvatarSelector extends StatefulWidget {
  var sendAvatar;
  final String avatar;

  AvatarSelector(this.sendAvatar, this.avatar);

  @override
  _AvatarSelectorState createState() =>
      new _AvatarSelectorState(this.sendAvatar, this.avatar);
}

class _AvatarSelectorState extends State<AvatarSelector> {
  int _key;
  String myAvatar;
  var sendAvatar;

  List<String> avatars = [
    'assets/pic-1.png',
    'assets/pic-2.png',
    'assets/pic-3.png',
    'assets/pic-4.png',
    'assets/pic-5.png',
    'assets/pic-6.png'
  ];

  _AvatarSelectorState(this.sendAvatar, this.myAvatar);

  @override
  void initState() {
    super.initState();
    _collapse();
  }

  @override
  Widget build(BuildContext context) {
    return _buildTiles(context);
  }

  Widget _avatarItems() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: avatars.map(
        (avatar) {
          return IconButton(
            icon: new Image.asset(avatar),
            onPressed: () => setAvatar(avatar),
          );
        },
      ).toList(),
    );
  }

  Widget _buildTiles(BuildContext context) {
    return ExpansionTile(
      key: Key(_key.toString()),
      title: showLogo(),
      children: <Widget>[
        _avatarItems(),
      ],
    );
  }

  Widget showLogo() {
    double size = MediaQuery.of(context).size.height / 6;
    if (MediaQuery.of(context).orientation != Orientation.portrait) {
      size = MediaQuery.of(context).size.width / 6;
    }

    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(myAvatar),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(80.0),
          border: Border.all(
            color: Colors.white,
            width: 10.0,
          ),
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

  setAvatar(String selectedAvatar) {
    setState(() {
      myAvatar = selectedAvatar;
    });
    sendAvatar(selectedAvatar);
  }
}
