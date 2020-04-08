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
        Navigator.pushAndRemoveUntil(
          context,
          PageTransition(type: PageTransitionType.downToUp, child: StudentHomeScreen()),
          (Route<dynamic> route) => false,
        );
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
    return WillPopScope(
      onWillPop: () async => Future.value(false),
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.bottomLeft, end: Alignment.topRight, colors: [Colors.cyan[500], Colors.blueGrey[600]]),
          ),
          child: ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 70, right: 90, left: 0, bottom: 10),
                child: Transform.scale(
                  scale: 1.2,
                  child: Container(
                    alignment: Alignment.centerLeft,
                    height: 45,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyan[900],
                          blurRadius: 8.0, // has the effect of softening the shadow
                          spreadRadius: 0.1, // has the effect of extending the shadow
                          offset: Offset(
                            5.0, // horizontal, move right 10
                            5.0, // vertical, move down 10
                          ),
                        ),
                      ],
                      color: Color(0xff00b0c9),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Are you future ready ?   ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 20, left: 5),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 5, left: 5),
                        child: Image.asset(
                          'images/gennextlonglogo-3.png',
                          height: 90,
                          width: 245,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Form(
                key: formKey,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 40, left: 50, right: 50),
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
                        color: Colors.cyan[900],
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
      ),
    );
  }
}
