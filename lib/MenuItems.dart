import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MenuItems {
  static const String Profile = 'Profile';
  static const String SignOut = 'Sign out';

  static const Map<String, Icon> choices = const {
    Profile: Icon(
      Icons.person,
      color: Colors.black87,
    ),
    SignOut: Icon(
      Icons.exit_to_app,
      color: Colors.black87,
    ),
  };

  static Widget rowItem(String itemName, Icon icon) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Spacer(),
          icon,
          Spacer(flex: 2),
          Text(itemName),
          Spacer(),
        ],
      ),
    );
  }
}
