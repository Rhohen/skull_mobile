import 'package:faker/faker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/src/widgets/framework.dart';

final faker = new Faker();

class User {
  String key;
  String name;
  String profileImg;
  String rank;
  String isReady;
  String isOwner;

  User(this.key, this.name, this.profileImg, this.rank, this.isReady,
      this.isOwner);

  factory User.from(Map<String, dynamic> json) {
    return new User(json['key'], json['name'], json['profileImg'], json['rank'],
        json['isReady'], json['isOwner']);
  }

  User.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        name = snapshot.value['name'],
        profileImg = snapshot.value['profileImg'],
        rank = snapshot.value['rank'],
        isReady = snapshot.value['isReady'],
        isOwner = snapshot.value['isOwner'];

  toJson() {
    return {
      "name": name,
      "profileImg": profileImg,
      "rank": rank,
      "isReady": isReady,
      "isOwner": isOwner
    };
  }

  factory User.generate(String name) {
    String photo = 'img/pic-' +
        faker.randomGenerator.integer(7, min: 1).toString() +
        '.png';
    return new User("-1", name, photo, "-1", "false", "false");
  }

  void copyFrom(User user) {
    this.isReady = user.isReady;
    this.isOwner = user.isOwner;
    this.profileImg = user.profileImg;
    this.rank = user.rank;
    this.name = user.name;
  }
}
