import 'package:flutter/material.dart';
import 'main.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage>{
  
  final formKey = new GlobalKey<FormState>();

  String _email;
  String _password;

  void validateAndSave(){
    final form = formKey.currentState;

    if (form.validate()){
      form.save();
      print("Email: $_email, Password: $_password");
    } else {
      print("Form Is Invalid");
    }
  }

  void registration() {

  }
  
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Colors.blue]
            ),
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
                  validator: (value) => value.isEmpty ? 'Enter a valid Email ID': null,
                  onSaved: (value) => _email = value,
                ),
                new TextFormField(
                  decoration: InputDecoration(labelText: "Password"),
                  obscureText: true,
                  validator: (value) => value.isEmpty ? 'Enter a valid Email ID': null,
                  onSaved: (value) => _password = value,
                ),  
                new RaisedButton(
                  color: Colors.blueGrey,
                  child: new Text(
                    'Login', 
                    style: GoogleFonts.b612(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  onPressed: validateAndSave, 
                ),
                new FlatButton(
                  child: new Text(
                    'Not Registered Yet? Register.',
                    style: GoogleFonts.b612Mono(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onPressed: registration,              
                ),
              ],
            ),
          )
        ),
      ),
    );  
  }
}
