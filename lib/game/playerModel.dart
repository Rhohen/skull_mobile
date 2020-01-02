import 'package:faker/faker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:skull_mobile/lobby/userModel.dart';

final faker = new Faker();

class Player {
  String key;
  String name;
  String profileImg;
  String isOwner;

  Player(this.key, this.name, this.profileImg, this.isOwner);

  factory Player.from(Map<String, dynamic> json) {
    return new Player(
        json['key'], json['name'], json['profileImg'], json['isOwner']);
  }

  factory Player.fromUser(User user) {
    return new Player(user.key, user.name, user.profileImg, user.isOwner);
  }

  Player.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        name = snapshot.value['name'],
        profileImg = snapshot.value['profileImg'],
        isOwner = snapshot.value['isOwner'];

  toJson() {
    return {"name": name, "profileImg": profileImg, "isOwner": isOwner};
  }

  factory Player.generate(String name) {
    String photo = 'img/pic-' +
        faker.randomGenerator.integer(7, min: 1).toString() +
        '.png';
    return new Player("-1", name, photo, "false");
  }

  void copyFrom(Player player) {
    this.isOwner = player.isOwner;
    this.profileImg = player.profileImg;
    this.name = player.name;
  }
}
