import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:skull_mobile/settings/settings.dart';

class LanguageSelector extends StatefulWidget {
  @override
  _LanguageSelectorState createState() => new _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  Locale curentLang;
  int _key;

  List<Locale> availablesLagages = [Locale('en'), Locale('fr')];

  @override
  void initState() {
    super.initState();
    new Future.delayed(Duration.zero, () async {
      setState(() {
        curentLang = FlutterI18n.currentLocale(context);
      });
    });
    _collapse();
  }

  @override
  Widget build(BuildContext context) {
    return _buildTiles(context);
  }

  List<Widget> _languageItems() {
    List<Widget> list = [];

    availablesLagages.forEach((lang) {
      list.add(new ListTile(
        title: new Text(lang.languageCode),
        trailing: curentLang.languageCode == lang.languageCode
            ? new Icon(Icons.check, color: Colors.green)
            : null,
        selected: curentLang.languageCode == lang.languageCode,
        onTap: () async {
          changeLanguage(lang);
        },
      ));
    });

    return list;
  }

  Widget _buildTiles(BuildContext context) {
    return new ExpansionTile(
      key: new Key(_key.toString()),
      initiallyExpanded: false,
      title: new Row(
        children: [new Text(FlutterI18n.translate(context, "langues"))],
      ),
      children: _languageItems(),
    );
  }

  _collapse() {
    int newKey;
    do {
      _key = new Random().nextInt(10000);
    } while (newKey == _key);
  }

  changeLanguage(Locale lang) async {
    await FlutterI18n.refresh(context, lang);
    setState(() {
      curentLang = lang;
      _collapse();
    });
    Navigator.pushNamed(context, SettingsPage.routeName);
  }
}
