import 'dart:math';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class FlippedCards extends StatelessWidget {
  final List<String> flippedCards;
  final int betNumber;

  FlippedCards({
    Key key,
    @required this.flippedCards,
    @required this.betNumber,
  })  : assert(flippedCards != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> cards = new List();

    double cardRadius = min(MediaQuery.of(context).size.width / betNumber, 55);

    for (int i = 0; i < betNumber; i++) {
      cards.add(
        Spacer(),
      );

      if (i < flippedCards.length) {
        cards.add(circularCard("assets/${flippedCards[i]}.png", cardRadius));
      } else {
        cards.add(
          DottedBorder(
            borderType: BorderType.Circle,
            dashPattern: [4],
            child: Container(
              height: cardRadius - sqrt(cardRadius),
              width: cardRadius - sqrt(cardRadius),
              decoration: new BoxDecoration(
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      }
    }
    cards.add(
      Spacer(),
    );
    return Row(
      // This next line does the trick.
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[...cards],
    );
  }

  Widget circularCard(String cardPath, double cardRadius) {
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
