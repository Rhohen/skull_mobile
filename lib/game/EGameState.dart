class EGameState {
  /// The game is in "Lobby" state, its currently waiting for player to be ready or to owner to start the game
  static const String INITIALIZING = "INITIALIZING";

  /// The players are currently playing the game, the lobby is no longer available
  static const String PLAYING = "PLAYING";

  /// The game is stopped brutally
  static const String STOPPED = "STOPPED";

  /// The game is finished
  static const String FINISHED = "FINISHED";
}
