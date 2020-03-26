import 'package:flutter/material.dart';
import 'home.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = new GlobalKey<FormState>();

  String _email;
  String _password;

  void validateAndSave() {
    final form = formKey.currentState;

    if (form.validate()) {
      form.save();
      if (_email == "gennext@edu.com") {
        if (_password == "gennext") {
          Navigator.push(context,
              new MaterialPageRoute(builder: (context) => HomeScreen()));
        } else {
          print("Invalid");
        }
      } else {
        print("Invalid");
      }
    } else {
      print("Form Is Invalid");
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.blue]),
        ),
        child: Container(
            padding: EdgeInsets.all(16.0),
            child: new Form(
              key: formKey,
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  new TextFormField(
                    decoration: InputDecoration(labelText: "Email"),
                    validator: (value) =>
                        value.isEmpty ? 'Enter a valid Email ID' : null,
                    onSaved: (value) => _email = value,
                  ),
                  new TextFormField(
                    decoration: InputDecoration(labelText: "Password"),
                    obscureText: true,
                    validator: (value) =>
                        value.isEmpty ? 'Enter a valid Email ID' : null,
                    onSaved: (value) => _password = value,
                  ),
                  new RaisedButton(
                    color: Colors.blueGrey,
                    child: new Text('Login'),
                    onPressed: validateAndSave,
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
