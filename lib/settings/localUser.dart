import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:skull_mobile/connexion/login.dart';
import 'package:skull_mobile/lobby/userModel.dart';

class LocalUser {
  String _pseudo = "";
  int _score = -1;
  String _avatar = "";

  static final LocalUser _singleton = LocalUser._internal();

  factory LocalUser() {
    return _singleton;
  }

  /// Constructeur privé interne
  LocalUser._internal();

  Future<FirebaseUser> getPlayer() {
    return FirebaseAuth.instance.currentUser();
  }

  Future getPseudo() async {
    await getPlayer().then((onValue) => FirebaseDatabase.instance
        .reference()
        .child('users')
        .child(onValue.uid)
        .child('pseudo')
        .once()
        .then((snapshot) => _pseudo = snapshot.value));
    return _pseudo;
  }

  Future setPseudo(String pseudo) {
    return getPseudo().then((onValue) => getPlayer().then((onUser) =>
        FirebaseDatabase.instance
            .reference()
            .child('users')
            .child(onUser.uid)
            .update({'pseudo': pseudo})));
  }

  Future getAvatar() async {
    await getPlayer().then((onValue) => FirebaseDatabase.instance
        .reference()
        .child('users')
        .child(onValue.uid)
        .child('avatar')
        .once()
        .then((snapshot) => _avatar = snapshot.value));
    return _avatar;
  }

  Future setAvatar(String avatar) {
    return getAvatar().then((onValue) => getPlayer().then((onUser) =>
        FirebaseDatabase.instance
            .reference()
            .child('users')
            .child(onUser.uid)
            .update({'avatar': avatar})));
  }

  Future getScore() async {
    await getPlayer().then((onValue) => FirebaseDatabase.instance
        .reference()
        .child('users')
        .child(onValue.uid)
        .child('score')
        .once()
        .then((snapshot) => _score = snapshot.value));
    return _score;
  }

  Future setScore() async {
    getScore().then((onValue) => getPlayer().then((onUser) => FirebaseDatabase
        .instance
        .reference()
        .child('users')
        .child(onUser.uid)
        .update({'score': (onValue + 1)})));
  }

  Future getUser() async {
    User user;
    await getPlayer().then((onValue) => FirebaseDatabase.instance
            .reference()
            .child('users')
            .child(onValue.uid)
            .once()
            .then((DataSnapshot snapshot) {
          user = new User(
              onValue.uid,
              snapshot.value['pseudo'],
              snapshot.value['avatar'],
              snapshot.value['score'].toString(),
              'false',
              'false',
              '0');
        }));
    return user;
  }

  logout(BuildContext context) {
    FirebaseAuth.instance.signOut().then((onValue) => {
          Navigator.popUntil(context, ModalRoute.withName(LoginPage.routeName))
        });
  }

  String getLocalPseudo() {
    return _singleton._pseudo;
  }

  int getLocalScore() {
    return _singleton._score;
  }

  String getLocalAvatar() {
    return _singleton._avatar;
  }

  void setLocalAvatar(String avatar) {
    _singleton._avatar = avatar;
  }

  void setLocalPseudo(String pseudo) {
    _singleton._pseudo = pseudo;
  }

  void setLocalScore(int score) {
    _singleton._score = score;
  }
}
