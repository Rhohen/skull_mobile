import 'package:flutter/material.dart';
import 'userModel.dart';

class UserCard extends StatelessWidget {
  final User user;

  UserCard(this.user);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Card(
        color: (user.isOwner.toLowerCase() == 'true')
            ? Colors.yellow[700]
            : Colors.grey[800],
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                    width: 50.0,
                    height: 50.0,
                    decoration: new BoxDecoration(
                        shape: BoxShape.circle,
                        image: new DecorationImage(
                            fit: BoxFit.cover,
                            image: AssetImage(user.profileImg)))),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    user.name,
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Text(
                    'top ${user.rank}',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  )
                ],
              ),
              Spacer(),
              RawMaterialButton(
                onPressed: null,
                child: new Icon(
                  (user.isReady.toLowerCase() == 'true')
                      ? Icons.check
                      : Icons
                          .close, // TODO: mettre en jaune l'owner + voir si ya pas moyen de le rajouter au niveau du lobby
                  color: Colors.white,
                  size: 35.0,
                ),
                shape: new CircleBorder(),
                elevation: 2.0,
                fillColor: (user.isReady.toLowerCase() == 'true')
                    ? Colors.green
                    : Colors.redAccent,
                padding: const EdgeInsets.all(15.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
