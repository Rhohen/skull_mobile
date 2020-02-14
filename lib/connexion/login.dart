import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:email_validator/email_validator.dart';
import 'package:skull_mobile/accueil.dart';
import 'dart:developer' as LOGGER;

import '../glowRemover.dart';

class LoginPage extends StatefulWidget {
  static const routeName = '/LoginPage';

  @override
  State<StatefulWidget> createState() => new _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  final _formKey = new GlobalKey<FormState>();
  DatabaseReference userRef;

  String _email;
  String _pseudo;
  String _password;
  String _errorMessage;

  bool _isLoading;
  bool _isLoginForm;

  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    } else {
      _isLoading = false;
      return false;
    }
  }

  void validateAndSubmit() async {
    setState(() {
      _errorMessage = "";
      _isLoading = true;
    });
    if (validateAndSave()) {
      try {
        if (_isLoginForm) {
          await FirebaseAuth.instance
              .signInWithEmailAndPassword(
                email: _email,
                password: _password,
              )
              .then(
                (user) => {
                  Navigator.pushNamed(context, AccueilPage.routeName),
                },
              );
        } else {
          await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
                  email: _email, password: _password)
              .then(
                (user) => {
                  FirebaseDatabase.instance
                      .reference()
                      .child('users')
                      .child(user.uid)
                      .set(
                    {
                      "mail": _email,
                      "pseudo": _pseudo,
                      "avatar": 'assets/pic-5.png',
                      "score": 0
                    },
                  ).then(
                    (onValue) =>
                        {Navigator.pushNamed(context, AccueilPage.routeName)},
                  )
                },
              );
        }
        setState(() {
          _isLoading = false;
        });
      } catch (e) {
        LOGGER.log("Error: $e");
        setState(() {
          _isLoading = false;
          _errorMessage = e.message;
        });
      }
    }
  }

  @override
  void initState() {
    _errorMessage = "";
    _isLoading = false;
    _isLoginForm = true;
    super.initState();
  }

  void resetForm() {
    _formKey.currentState.reset();
    _errorMessage = "";
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Connexion"),
      ),
      body: Stack(
        children: <Widget>[
          showForm(),
          showCircularProgress(),
        ],
      ),
    );
  }

  Widget showCircularProgress() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return Container(height: 0.0, width: 0.0);
  }

  Widget showForm() {
    return Container(
      padding: EdgeInsets.only(left: 16.0, right: 16.0),
      child: new Form(
        key: _formKey,
        child: ScrollConfiguration(
          behavior: GlowRemover(),
          child: new ListView(
            shrinkWrap: true,
            children: <Widget>[
              SizedBox(height: 20),
              showLogo(),
              showEmailInput(),
              showPseudoInput(),
              showPasswordInput(),
              showPrimaryButton(),
              showSecondaryButton(),
              showErrorMessage(),
            ],
          ),
        ),
      ),
    );
  }

  Widget showLogo() {
    return new Hero(
      tag: 'hero',
      child: Padding(
        padding: EdgeInsets.fromLTRB(0.0, 25.0, 0.0, 0.0),
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 48.0,
          child: Image.asset('assets/skull.png'),
        ),
      ),
    );
  }

  Widget showEmailInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 25.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: new InputDecoration(
          hintText: 'Email',
          icon: new Icon(
            Icons.email,
            color: Colors.grey,
          ),
        ),
        validator: (value) =>
            !EmailValidator.validate(value, true) ? 'Not a valid email.' : null,
        onSaved: (value) => _email = value.trim(),
      ),
    );
  }

  Widget showPseudoInput() {
    return Visibility(
      visible: !_isLoginForm,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
        child: new TextFormField(
          maxLines: 1,
          keyboardType: TextInputType.text,
          autofocus: false,
          decoration: new InputDecoration(
            hintText: 'Pseudo',
            icon: new Icon(
              Icons.account_circle,
              color: Colors.grey,
            ),
          ),
          validator: (value) => value.isEmpty ? 'Pseudo can\'t be empty' : null,
          onSaved: (value) => _pseudo = value,
        ),
      ),
    );
  }

  Widget showPasswordInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        decoration: new InputDecoration(
          hintText: 'Password',
          icon: new Icon(
            Icons.lock,
            color: Colors.grey,
          ),
        ),
        validator: (value) => value.isEmpty ? 'Password can\'t be empty' : null,
        onSaved: (value) => _password = value.trim(),
      ),
    );
  }

  Widget showPrimaryButton() {
    return new Padding(
      padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
      child: SizedBox(
        height: 40.0,
        child: new RaisedButton(
          elevation: 5.0,
          shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(30.0),
          ),
          color: Colors.blue,
          child: new Text(
            _isLoginForm ? 'Login' : 'Create account',
            style: new TextStyle(
              fontSize: 20.0,
              color: Colors.white,
            ),
          ),
          onPressed: validateAndSubmit,
        ),
      ),
    );
  }

  Widget showSecondaryButton() {
    return new FlatButton(
      child: new Text(
        _isLoginForm ? 'Create an account' : 'Have an account? Sign in',
        style: new TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.w300,
        ),
      ),
      onPressed: toggleFormMode,
    );
  }

  void toggleFormMode() {
    resetForm();
    setState(() {
      _isLoginForm = !_isLoginForm;
    });
  }

  Widget showErrorMessage() {
    if (_errorMessage != null && _errorMessage.length > 0) {
      return new Text(
        _errorMessage,
        style: TextStyle(
          fontSize: 13.0,
          color: Colors.red,
          height: 1.0,
          fontWeight: FontWeight.w300,
        ),
      );
    } else {
      return new Container(
        height: 0.0,
      );
    }
  }
}
