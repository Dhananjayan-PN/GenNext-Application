import 'package:flutter/cupertino.dart';
//import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
//import 'package:page_transition/page_transition.dart';
//import 'student/home.dart';

class SignUpPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SignUpPageState();
}

class SignUpPageState extends State<SignUpPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.bottomLeft, end: Alignment.topRight, colors: [Colors.cyan[300], Colors.blueGrey[800]]),
            ),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 250),
                  child: Text(
                    "Hi there !",
                    style: TextStyle(color: Colors.white, fontSize: 50, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10, left: 10, right: 10),
                  child: Text(
                    "Welcome to Gen Next Edu's App !",
                    style: TextStyle(color: Colors.white, fontSize: 23),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10, left: 20, right: 20),
                  child: Text(
                    "Our goal is to help students like you dash through the college admission process, with the help of our talented team and this feature-packed app",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 60, left: 15, right: 15),
                  child: Text(
                    "We're currently not registering new users for development purposes. Come back soon!",
                    style: TextStyle(color: Colors.white70, fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      size: 30,
                      color: Colors.cyan[100],
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                )
              ],
            )));
  }
}
