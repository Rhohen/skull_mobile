class GameMessage {
  String message;
  String currentPlayer;
  String nextPlayer;

  GameMessage(this.message, this.currentPlayer, this.nextPlayer);

  factory GameMessage.from(Map json) {
    return new GameMessage(
        json['message'], json['currentPlayer'], json['nextPlayer']);
  }

  toJson() {
    return {
      "message": message,
      "currentPlayer": currentPlayer,
      "nextPlayer": nextPlayer
    };
  }
}
