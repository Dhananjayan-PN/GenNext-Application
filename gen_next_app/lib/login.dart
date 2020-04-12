import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'student/home.dart';
import 'signup.dart';

class CustomDialog extends StatelessWidget {
  final String title, description, buttonText;

  CustomDialog({
    @required this.title,
    @required this.description,
    @required this.buttonText,
  });

  dialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(
            top: 24,
            bottom: 16,
            left: 16,
            right: 16,
          ),
          decoration: new BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: const Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // To make the card compact
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
              SizedBox(height: 24.0),
              Align(
                alignment: Alignment.bottomRight,
                child: FlatButton(
                  shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(9.0), side: BorderSide(color: Colors.cyan[600])),
                  color: Colors.cyanAccent[400],
                  splashColor: Colors.blueAccent,
                  onPressed: () {
                    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                  },
                  child: Text(buttonText),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.cyan[600]),
      ),
      elevation: 2.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();

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
            gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Color(0xff36d1dc), Color(0xff19547b)]),
          ),
          child: ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 70, right: 90, left: 0, bottom: 0),
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
                      color: Color(0xff36d1dc),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Are you future-ready ?   ',
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
                    padding: const EdgeInsets.only(top: 30, left: 5),
                    child: RotatedBox(
                        quarterTurns: -1,
                        child: Text(
                          'Sign In',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 45,
                            fontWeight: FontWeight.w900,
                          ),
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 0, left: 0),
                    child: Image.asset(
                      'images/gennextlonglogo-3.png',
                      height: 90,
                      width: 245,
                      fit: BoxFit.fill,
                    ),
                  ),
                ],
              ),
              Form(
                key: formKey,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 40, left: 30, right: 50),
                      child: TextFormField(
                        validator: (value) {
                          return value.isEmpty ? 'Enter valid username' : null;
                        },
                        onSaved: (value) => _email = value,
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
                    Padding(
                      padding: const EdgeInsets.only(top: 20, left: 30, right: 50),
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
                          icon: Icon(Icons.vpn_key),
                          labelText: 'Password',
                          labelStyle: TextStyle(
                            color: Colors.white,
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
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor: Colors.cyan,
                          onTap: () {
                            formKey.currentState.reset();
                            Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: SignUpPage()));
                          },
                          child: Text(
                            'Sign Up',
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
    );
  }
}
