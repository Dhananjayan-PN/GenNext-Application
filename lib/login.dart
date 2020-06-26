import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'main.dart';
import 'package:page_transition/page_transition.dart';
import 'student/home.dart';
import 'counselor/home.dart';
import 'signup.dart';
import 'usermodel.dart';

Route logoutRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => LoginPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(0.0, -1.0);
      var end = Offset.zero;
      var curve = Curves.ease;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final _scafKey = GlobalKey<ScaffoldState>();
  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();

  String _username;
  String _password;
  User user;

  Route homepageRoute(String role) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => role == 'S'
          ? StudentHomeScreen(user: user)
          : role == 'C'
              ? CounselorHomeScreen(user: user)
              : role == 'R'
                  ? Container() //University Rep Page
                  : role == 'A'
                      ? Container() //Admin Page
                      : null,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(0.0, 1.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  Future<void> _loginUser(String uname, String pass) async {
    try {
      final http.Response result = await http.post(
        domain + 'authenticate/login/',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{'username': uname, 'password': pass}),
      );
      if (result.statusCode == 200) {
        token = json.decode(result.body)['token'];
        final response = await http.get(
          domain + 'authenticate/$uname',
          headers: {HttpHeaders.authorizationHeader: "Token $token"},
        );
        if (response.statusCode == 200) {
          user = User.fromJson(json.decode(response.body));
          Navigator.pop(context);
          Route route = homepageRoute(user.usertype);
          if (route != null) {
            Navigator.of(context).push(route);
          } else {
            username.clear();
            password.clear();
            Navigator.pop(context);
            _error();
          }
        }
      } else {
        username.clear();
        password.clear();
        Navigator.pop(context);
        _wrongCreds();
      }
    } catch (e) {
      username.clear();
      password.clear();
      Navigator.pop(context);
      _error();
    }
  }

  void validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      _signingIn();
      Future.delayed(Duration(milliseconds: 100), () {
        _loginUser(username.text, password.text).timeout(Duration(seconds: 8),
            onTimeout: () {
          username.clear();
          password.clear();
          Navigator.pop(context);
          _error();
        });
      });
    } else {
      print("Form Is Invalid");
    }
  }

  _signingIn() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(0),
          elevation: 20,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          content: Container(
            height: 150,
            width: 80,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xff00AEEF), Color(0xff0072BC)]),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 50,
                    width: 50,
                    child: SpinKitWave(
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 23.0),
                    child: Text(
                      "Signing you in...",
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  _error() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(0),
          elevation: 20,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          content: Container(
            height: 150,
            width: 80,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xff00AEEF), Color(0xff0072BC)]),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.error_outline,
                    size: 40,
                    color: Colors.red.withOpacity(0.9),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(
                      'Unable to establish a connection with our servers.\nCheck your connection and try again later.',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  _wrongCreds() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(0),
          elevation: 20,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          content: Container(
            height: 150,
            width: 80,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xff00AEEF), Color(0xff0072BC)]),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.sentiment_dissatisfied,
                    size: 40,
                    color: Colors.red.withOpacity(0.9),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(
                      'Invalid login credentials!\nCheck your credentials and try again',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: Color(0xff00AEEF),
        statusBarColor: Color(0xff0072BC).withAlpha(150),
      ),
      child: WillPopScope(
        onWillPop: () async => Future.value(false),
        child: Scaffold(
          key: _scafKey,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0xff00AEEF), Color(0xff0072BC)]),
            ),
            child: ListView(
              children: <Widget>[
                Padding(
                  padding:
                      EdgeInsets.only(top: 70, right: 90, left: 0, bottom: 0),
                  child: Transform.scale(
                    scale: 1.2,
                    child: Container(
                      alignment: Alignment.centerLeft,
                      height: 45,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xff2fbdf5), Color(0xff0062be)]),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.cyan[900],
                            blurRadius: 8.0,
                            spreadRadius: 0.1,
                            offset: Offset(
                              5.0,
                              5.0,
                            ),
                          ),
                        ],
                        color: Color(0xff36d1dc),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 1.3),
                          child: Text(
                            'Are you future-ready ?  ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w300,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 28.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 00, left: 5),
                        child: RotatedBox(
                            quarterTurns: -1,
                            child: Text(
                              'Sign In',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 45,
                                fontWeight: FontWeight.w500,
                              ),
                            )),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 0, left: 0),
                        child: Image.asset(
                          'images/gennextlonglogo-4.png',
                          height: 110,
                          width: 290,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ],
                  ),
                ),
                Form(
                  key: formKey,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 35, left: 30, right: 50),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            primaryColor: Colors.blue[900],
                          ),
                          child: TextFormField(
                            key: ValueKey('Username'),
                            controller: username,
                            validator: (value) {
                              return value.isEmpty
                                  ? 'Enter your username'
                                  : null;
                            },
                            onSaved: (value) => _username = value,
                            style: TextStyle(
                              color: Colors.white,
                            ),
                            decoration: InputDecoration(
                              icon: Icon(Icons.person),
                              labelText: 'Username',
                              labelStyle: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 20, left: 30, right: 50),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            primaryColor: Colors.blue[900],
                          ),
                          child: TextFormField(
                            key: ValueKey('Password'),
                            controller: password,
                            validator: (String value) {
                              return value.isEmpty
                                  ? 'Enter your password'
                                  : null;
                            },
                            onSaved: (value) => _password = value,
                            style: TextStyle(
                              color: Colors.white,
                            ),
                            obscureText: true,
                            decoration: InputDecoration(
                              icon: Icon(Icons.vpn_key),
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
                  padding: EdgeInsets.only(top: 45, right: 50),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      height: 40,
                      width: 100,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.cyan[900],
                            blurRadius: 10.0,
                            spreadRadius: 1.0,
                            offset: Offset(
                              5.0,
                              5.0,
                            ),
                          ),
                        ],
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: FlatButton(
                        splashColor: Colors.blue[900],
                        onPressed: () {
                          validateAndSave();
                        },
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 1),
                            child: Text(
                              'Sign In',
                              key: ValueKey('button'),
                              style: TextStyle(
                                color: Color(0xff00AEEF),
                                fontSize: 19,
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 30, left: 55, right: 55),
                  child: Container(
                    alignment: Alignment.topRight,
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
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            splashColor: Colors.cyan,
                            onTap: () {
                              formKey.currentState.reset();
                              Navigator.push(
                                  context,
                                  PageTransition(
                                      type: PageTransitionType.rightToLeft,
                                      child: SignUpPage()));
                            },
                            child: Text(
                              'Register',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.left,
                            ),
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
      ),
    );
  }
}
