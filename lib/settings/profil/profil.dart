import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:skull_mobile/settings/localUser.dart';

import 'avatarSelector.dart';

class ProfilPage extends StatefulWidget {
  static const routeName = '/ProfilPage';

  @override
  State<StatefulWidget> createState() => new _ProfilPage();
}

class _ProfilPage extends State<ProfilPage> {
  String _avatar;
  TextEditingController _pseudo = TextEditingController();

  @override
  void initState() {
    _pseudo.text = "";
    LocalUser.getPseudo().then((pseudo) => setState(() {
          _pseudo.text = pseudo;
        }));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(FlutterI18n.translate(context, "profil_title")),
      ),
      body: new Container(
        padding: EdgeInsets.all(16.0),
        child: new ListView(
          shrinkWrap: true,
          children: <Widget>[
            new AvatarSelector(sendAvatar),
            pseudoEditor(),
            saveButton(),
          ],
        ),
      ),
    );
  }

  Widget pseudoEditor() {
    return new TextFormField(
      controller: _pseudo,
      keyboardType: TextInputType.text,
      onSaved: (String value) {
        _pseudo.text = value;
      },
    );
  }

  Widget saveButton() {
    return RaisedButton.icon(
      label: Text('Valider'),
      color: Colors.blue,
      icon: Icon(Icons.check),
      onPressed: () => _submit(context),
    );
  }

  void _submit(BuildContext context) {
    if (_pseudo.text != null && _pseudo.text.length > 3) {
      LocalUser.setPseudo(_pseudo.text);
    }
    if (_avatar != null && _avatar != '') {
      LocalUser.setAvatar(_avatar);
    }
  }

  sendAvatar(String value) {
    _avatar = value;
  }
}
