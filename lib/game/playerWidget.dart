import 'package:flutter/material.dart';
import 'package:flutter_badge/flutter_badge.dart';

class PlayerWidget extends StatelessWidget {
  final double top;
  final double left;
  final double maxWidthContainer;
  final bool isPlayerTurn;
  final double iconSize;
  final bool hasScored;
  final String profileImg;
  final String playerName;
  final double textSize;
  final double textScaleFactor;

  PlayerWidget(
      {Key key,
      this.top,
      this.left,
      this.maxWidthContainer,
      this.isPlayerTurn,
      this.iconSize,
      this.hasScored,
      this.profileImg,
      this.playerName,
      this.textSize,
      this.textScaleFactor})
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
              text: '4',
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
              child: Text(
                playerName,
                textScaleFactor: textScaleFactor,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  //backgroundColor: Colors.blue,
                  fontSize: textSize,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
