import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'student/home.dart';

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
      if (_email == "jake.adams@gmail.com" && _password == 'gennext') {
        Navigator.push(context, PageTransition(type: PageTransitionType.downToUp, child: StudentHomeScreen()));
      }
      if (_email == "counsellor@gennext.edu" && _password == 'gennext') {
        print('Hey Counsellor');
      }
      if (_email == "university@gennext.edu" && _password == 'gennext') {
        print('Hey University');
      } else {
        print("Invalid");
      }
    } else {
      print("Form Is Invalid");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Colors.blueGrey[500], Colors.cyan[500]]),
        ),
        child: ListView(
          children: <Widget>[
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 60, left: 10),
                  child: RotatedBox(
                      quarterTurns: -1,
                      child: Text(
                        'Sign In',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                        ),
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30.0, left: 10.0),
                  child: Container(
                    //color: Colors.green,
                    height: 200,
                    width: 200,
                    child: Column(
                      children: <Widget>[
                        Container(
                          height: 60,
                        ),
                        Center(
                          child: Text(
                            'A world of possibility in an app',
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Form(
              key: formKey,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 50, left: 50, right: 50),
                    child: Container(
                      height: 60,
                      width: MediaQuery.of(context).size.width,
                      child: TextFormField(
                        validator: (value) {
                          return value.isEmpty ? 'Enter a valid Email ID' : null;
                        },
                        onSaved: (value) => _email = value,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20, left: 50, right: 50),
                    child: Container(
                      height: 60,
                      width: MediaQuery.of(context).size.width,
                      child: TextFormField(
                        validator: (String value) {
                          return value.isEmpty ? 'Enter a password' : null;
                        },
                        onSaved: (value) => _password = value,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 40, right: 50, left: 200),
              child: Container(
                alignment: Alignment.bottomRight,
                height: 47,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyan[800],
                      blurRadius: 10.0, // has the effect of softening the shadow
                      spreadRadius: 1.0, // has the effect of extending the shadow
                      offset: Offset(
                        5.0, // horizontal, move right 10
                        5.0, // vertical, move down 10
                      ),
                    ),
                  ],
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: FlatButton(
                  splashColor: Colors.cyanAccent[400],
                  onPressed: validateAndSave,
                  child: Center(
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                        color: Colors.lightBlueAccent,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30, left: 55, right: 55),
              child: Container(
                alignment: Alignment.topRight,
                //color: Colors.red,
                height: 25,
                child: Row(
                  children: <Widget>[
                    Text(
                      'Your first time here? ',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                    InkWell(
                      splashColor: Colors.cyan.withAlpha(0),
                      onTap: () {},
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
