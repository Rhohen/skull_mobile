import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:vector_math/vector_math.dart' hide Colors;

/// Creates a card stack
class CardStack extends StatelessWidget {
  final String cardPath;
  final double cardRadius;
  final int nbCardsOnTable;
  final double cardBorderWidth;
  final double spaceBetween;
  final double playerAngle;

  CardStack({
    Key key,
    @required this.cardPath,
    this.cardRadius = 25,
    @required this.nbCardsOnTable,
    this.cardBorderWidth = 2,
    this.spaceBetween = 0.17,
    @required this.playerAngle,
  })  : assert(cardPath != null),
        super(key: key);

  Vector2 getPosition(Vector2 center, double radius, double angle) {
    double playerX = (center.x + radius * cos(radians(angle)));
    double playerY = (center.y + radius * sin(radians(angle)));
    return new Vector2(playerX, playerY);
  }

  @override
  Widget build(BuildContext context) {
    List cards = List<Widget>();
    cards.add(
      Positioned(
        child: circularCard(cardPath),
      ),
    );

    for (int i = 0; i < nbCardsOnTable - 1; i++) {
      Vector2 circlePosition = getPosition(new Vector2(0, 0),
          spaceBetween * cardRadius * (i + 1.0), playerAngle);

      cards.add(
        Positioned(
          top: circlePosition.x,
          left: circlePosition.y,
          child: circularCard(cardPath),
        ),
      );
    }
    return Container(
      child: (nbCardsOnTable > 0)
          ? Stack(
              overflow: Overflow.visible,
              textDirection: TextDirection.rtl,
              children: cards,
            )
          : SizedBox(),
    );
  }

  Widget circularCard(String cardPath) {
    return Container(
      height: cardRadius,
      width: cardRadius,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: Container(
        decoration: new BoxDecoration(
          shape: BoxShape.circle,
          image: new DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage(cardPath),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.white38,
              blurRadius: 0.1,
              spreadRadius: 0.3,
            )
          ],
        ),
      ),
    );
  }
}
