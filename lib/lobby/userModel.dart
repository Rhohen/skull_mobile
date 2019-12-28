import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/src/widgets/framework.dart';

class User {
  String key;
  String name;
  String profileImg;
  String rank;
  String isReady;
  String isOwner;

  User(this.name, this.profileImg, this.rank, this.isReady, this.isOwner);

  factory User.from(Map<String, dynamic> json) {
    return new User(json['name'], json['profileImg'], json['rank'],
        json['isReady'], json['isOwner']);
  }

  User.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        name = snapshot.value['name'],
        profileImg = snapshot.value['profileImg'],
        rank = snapshot.value['rank'],
        isReady = snapshot.value['isReady'],
        isOwner = snapshot.value['isOwner'];
}
