import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'userModel.dart';

class UserCard extends StatelessWidget {
  final User user;
  final User currentUser;
  final DatabaseReference lobbyRef;
  final BuildContext lobbyContext;

  UserCard(this.user, this.lobbyRef, this.lobbyContext, this.currentUser);

  _removeUser() {
    lobbyRef.child(user.key).remove();
  }

  @override
  Widget build(BuildContext context) {
    List actions = [
      new InkWell(
        onTap: () => AwesomeDialog(
          context: context,
          animType: AnimType.SCALE,
          customHeader: Container(
            width: 100.0,
            height: 100.0,
            decoration: new BoxDecoration(
              shape: BoxShape.circle,
              image: new DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage(user.profileImg),
              ),
            ),
          ),
          tittle: user.name,
          desc: 'My name is ${user.name} and i\'m top ${user.rank}',
          btnOk: FlatButton(
            shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(18.0),
                side: BorderSide(color: Colors.grey)),
            child: Text('Close'),
            onPressed: () {
              Navigator.of(lobbyContext).pop();
            },
          ),
          //this is ignored
          btnOkOnPress: () {},
        ).show(),
        child: new Container(
          decoration: new BoxDecoration(
            color: Colors.blueAccent,
            borderRadius: new BorderRadius.circular(10.0),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Icon(Icons.person, color: Colors.white),
                new Text("Profile",
                    style: Theme.of(context)
                        .primaryTextTheme
                        .caption
                        .copyWith(color: Colors.white)),
              ],
            ),
          ),
        ),
      )
    ];

    if (currentUser.isOwner == 'true') {
      actions.add(new InkWell(
        onTap: _removeUser,
        child: new Container(
          decoration: new BoxDecoration(
            color: Colors.redAccent,
            borderRadius: new BorderRadius.circular(10.0),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Icon(Icons.exit_to_app, color: Colors.white),
                new Text("Eject",
                    style: Theme.of(context)
                        .primaryTextTheme
                        .caption
                        .copyWith(color: Colors.white)),
              ],
            ),
          ),
        ),
      ));
    }
    Widget cardComponent = Container(
      decoration: new BoxDecoration(
          color: (user.isOwner.toLowerCase() == 'true')
              ? Colors.orange[300]
              : Colors.grey[800],
          borderRadius: new BorderRadius.all(Radius.circular(10.0))),
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
            MaterialButton(
              onPressed: null,
              child: !(user.isReady.toLowerCase() == 'false')
                  ? new Icon(Icons.check, color: Colors.green, size: 35.0)
                  : new Icon(Icons.close, color: Colors.redAccent, size: 35.0),
              shape: new CircleBorder(),
              elevation: 2.0,
              padding: const EdgeInsets.all(15.0),
            ),
          ],
        ),
      ),
    );

    if (user.key == currentUser.key) {
      return Padding(
        padding: const EdgeInsets.only(left: 8),
        child: cardComponent,
      );
    } else {
      return Container(
        margin: const EdgeInsets.only(left: 8, bottom: 8, right: 8),
        child: Slidable(
          actionPane: SlidableBehindActionPane(),
          enabled: true,
          closeOnScroll: false,
          actions: <Widget>[...actions],
          key: new ObjectKey(0),
          child: cardComponent,
        ),
      );
    }
  }
}
