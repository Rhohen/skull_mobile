class GameMessage {
  String from;
  String message;

  GameMessage(this.from, this.message);

  factory GameMessage.from(Map json) {
    return new GameMessage(json['from'], json['message']);
  }

  toJson() {
    return {"message": message, "from": from};
  }
}
