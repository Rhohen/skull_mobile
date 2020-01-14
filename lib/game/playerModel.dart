import 'package:faker/faker.dart';
import 'package:skull_mobile/lobby/userModel.dart';

final faker = new Faker();

class Player {
  String key;
  String name;
  String profileImg;
  String fcmKey;
  List<String> cards;
  bool hasScored;
  String isOwner;
  bool isTurn;
  String isReady;

  Player(this.key, this.name, this.profileImg, this.fcmKey, this.cards,
      this.hasScored, this.isOwner, this.isTurn, this.isReady);

  factory Player.from(Map<String, dynamic> json) {
    return new Player(
        json['key'],
        json['name'],
        json['profileImg'],
        json['fcmKey'],
        json['cards'],
        json['hasScored'],
        json['isOwner'],
        json['isTurn'],
        json['isReady']);
  }

  factory Player.fromUser(User user) {
    return new Player(user.key, user.name, user.profileImg, user.fcmKey,
        ["rose", "skull"], false, user.isOwner, false, user.isReady);
  }

  toJson() {
    return {
      "name": name,
      "profileImg": profileImg,
      "cards": cards,
      "hasScored": hasScored,
      "isOwner": isOwner,
      "fcmKey": fcmKey,
      "isTurn": isTurn,
      "isReady": isReady
    };
  }

  void copyFrom(Player player) {
    this.cards = player.cards;
    this.isOwner = player.isOwner;
    this.profileImg = player.profileImg;
    this.hasScored = player.hasScored;
    this.name = player.name;
    this.isTurn = player.isTurn;
    this.isReady = player.isReady;
    if (player.fcmKey != '0') this.fcmKey = player.fcmKey;
  }

  void copyFromUser(User user) {
    this.cards = ["rose", "skull"];
    this.isOwner = user.isOwner;
    this.profileImg = user.profileImg;
    this.hasScored = false;
    this.name = user.name;
    this.isTurn = false;
    this.isReady = user.isReady;
    if (user.fcmKey != '0') this.fcmKey = user.fcmKey;
  }

  factory Player.generate() {
    String photo = 'assets/pic-' +
        faker.randomGenerator.integer(7, min: 1).toString() +
        '.png';
    List<String> cards = ["rose", "skull"];
    return new Player("-1", faker.person.name(), photo, "0", cards,
        faker.randomGenerator.boolean(), "false", false, "true");
  }
}
