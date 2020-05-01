import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'main.dart';
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
                  shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(9.0),
                      side: BorderSide(color: Colors.cyan[600])),
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
  final _scafKey = GlobalKey<ScaffoldState>();
  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();

  String loginresult;
  String _username;
  String _password;

  Future<void> _loginUser(String uname, String pass) async {
    final http.Response result = await http.post(
      'https://gennext.ml/authenticate/login/',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'username': uname, 'password': pass}),
    );
    print(json.decode(result.body));
    if (result.statusCode == 200) {
      token = json.decode(result.body)['token'];
      Navigator.pushAndRemoveUntil(
        context,
        PageTransition(
            type: PageTransitionType.downToUp,
            child: StudentHomeScreen(username: uname)),
        (Route<dynamic> route) => false,
      );
    } else {
      print('failed to login');
      username.clear();
      password.clear();
      _scafKey.currentState.showSnackBar(
        SnackBar(
          content: Text(
            'Invalid credentials. Try again',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }

  void validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            elevation: 20,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Container(
              height: 150,
              width: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xff00AEEF), Color(0xff0072BC)]),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 50,
                    width: 50,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 3.0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      "Loading",
                      style: TextStyle(color: Colors.white, fontSize: 25),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
      Future.delayed(Duration(seconds: 3), () {
        Navigator.pop(context); //pop dialog
        _loginUser(username.text, password.text);
      });
    } else {
      print("Form Is Invalid");
    }
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
                  padding: const EdgeInsets.only(
                      top: 70, right: 90, left: 0, bottom: 0),
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
                          padding: EdgeInsets.only(bottom: 4),
                          child: Text(
                            'Are you future-ready ?   ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
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
                        padding: const EdgeInsets.only(top: 00, left: 5),
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
                        padding:
                            const EdgeInsets.only(top: 35, left: 30, right: 50),
                        child: TextFormField(
                          controller: username,
                          validator: (value) {
                            return value.isEmpty
                                ? 'Enter valid username'
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
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 20, left: 30, right: 50),
                        child: TextFormField(
                          controller: password,
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
                  padding: const EdgeInsets.only(top: 45, right: 55, left: 205),
                  child: Container(
                    alignment: Alignment.bottomRight,
                    height: 40,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      //gradient: LinearGradient(end: Alignment.bottomCenter, begin: Alignment.topCenter, colors: [Color(0xff36d1dc), Color(0xff19547b)]),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyan[900],
                          blurRadius:
                              10.0, // has the effect of softening the shadow
                          spreadRadius:
                              1.0, // has the effect of extending the shadow
                          offset: Offset(
                            5.0, // horizontal, move right 10
                            5.0, // vertical, move down 10
                          ),
                        ),
                      ],
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: FlatButton(
                      splashColor: Colors.cyanAccent[400],
                      onPressed: () {
                        validateAndSave();
                      },
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            'Sign In',
                            style: TextStyle(
                              color: Color(0xff36d1dc),
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
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
                              Navigator.push(
                                  context,
                                  PageTransition(
                                      type: PageTransitionType.rightToLeft,
                                      child: SignUpPage()));
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
      ),
    );
  }
}
