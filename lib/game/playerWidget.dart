import 'package:flutter/material.dart';
import 'package:flutter_badge/flutter_badge.dart';

class PlayerWidget extends StatelessWidget {
  final double top;
  final double left;
  final double maxWidthContainer;
  final bool isPlayerTurn;
  final bool isChallengeMode;
  final double iconSize;
  final bool hasScored;
  final String profileImg;
  final String playerName;
  final double textSize;
  final double textScaleFactor;
  final int cardsSize;
  final bool isCurrentUserTurn;

  var sendCardFlipChoice;

  PlayerWidget(
      {Key key,
      this.top,
      this.left,
      this.maxWidthContainer,
      this.isPlayerTurn,
      this.isChallengeMode,
      this.iconSize,
      this.hasScored,
      this.profileImg,
      this.playerName,
      this.textSize,
      this.textScaleFactor,
      this.cardsSize,
      this.sendCardFlipChoice,
      this.isCurrentUserTurn})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      child: new Container(
        width: maxWidthContainer,
        //decoration: new BoxDecoration(color: Colors.red), // Debug
        child: Column(
          children: <Widget>[
            ((isPlayerTurn)
                ? Icon(
                    Icons.arrow_downward,
                    color: Colors.grey[700],
                    size: iconSize,
                  )
                : Container(
                    width: 0,
                    height: 0,
                  )),
            Badge(
              offsetX: -8,
              offsetY: -8,
              borderRadius: 5,
              backgroundColor: Colors.blue,
              text: cardsSize.toString(),
              child: Container(
                height: iconSize,
                width: iconSize,
                decoration: new BoxDecoration(
                  border: (hasScored)
                      ? Border.all(
                          color: Colors.orange[300],
                          width: 3,
                        )
                      : null,
                  shape: BoxShape.circle,
                  image: new DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage(profileImg),
                  ),
                ),
              ),
            ),
            Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: new Border.all(
                    color: Colors.grey,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(
                      2.0,
                    ),
                  ),
                ),
                child: FlatButton(
                  child: new Text(
                    playerName,
                    textScaleFactor: textScaleFactor,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      //backgroundColor: Colors.blue,
                      fontSize: textSize,
                    ),
                  ),
                  // Ajouter verification qu'on ne clique pas sur soi-même
                  onPressed:
                      (isChallengeMode && isCurrentUserTurn) ? null : null,
                )),
          ],
        ),
      ),
    );
  }
}
