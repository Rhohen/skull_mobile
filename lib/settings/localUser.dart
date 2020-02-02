import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:skull_mobile/connexion/login.dart';
import 'package:skull_mobile/lobby/userModel.dart';

class LocalUser {
  static Future<FirebaseUser> getPlayer() {
    return FirebaseAuth.instance.currentUser();
  }

  static Future getPseudo() async {
    String pseudo;
    await getPlayer().then((onValue) => FirebaseDatabase.instance
        .reference()
        .child('users')
        .child(onValue.uid)
        .child('pseudo')
        .once()
        .then((snapshot) => pseudo = snapshot.value));
    return pseudo;
  }

  static Future setPseudo(String pseudo) {
    return getPseudo().then((onValue) => getPlayer().then((onUser) =>
        FirebaseDatabase.instance
            .reference()
            .child('users')
            .child(onUser.uid)
            .update({'pseudo': pseudo})));
  }

  static Future getAvatar() async {
    String avatar;
    await getPlayer().then((onValue) => FirebaseDatabase.instance
        .reference()
        .child('users')
        .child(onValue.uid)
        .child('avatar')
        .once()
        .then((snapshot) => avatar = snapshot.value));
    return avatar;
  }

  static Future setAvatar(String avatar) {
    return getAvatar().then((onValue) => getPlayer().then((onUser) =>
        FirebaseDatabase.instance
            .reference()
            .child('users')
            .child(onUser.uid)
            .update({'avatar': avatar})));
  }

  static Future getScore() async {
    int score;
    await getPlayer().then((onValue) => FirebaseDatabase.instance
        .reference()
        .child('users')
        .child(onValue.uid)
        .child('score')
        .once()
        .then((snapshot) => score = snapshot.value));
    return score;
  }

  static Future setScore() async {
    getScore().then((onValue) => getPlayer().then((onUser) => FirebaseDatabase
        .instance
        .reference()
        .child('users')
        .child(onUser.uid)
        .update({'score': (onValue + 1)})));
  }

  static Future getUser() async {
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

  static logout(BuildContext context) {
    FirebaseAuth.instance.signOut().then((onValue) => {
          Navigator.popUntil(context, ModalRoute.withName(LoginPage.routeName))
        });
  }
}
