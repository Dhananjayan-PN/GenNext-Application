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
  final signupformKey = new GlobalKey<FormState>();
  final TextEditingController _pass = TextEditingController();
  final TextEditingController _confirmPass = TextEditingController();
  int _selectedIndex = 0;

  String _name;
  String _email;
  String _password;
  String _confpassword;
  String _country;

  void finishAndSave() {}

  @override
  Widget build(BuildContext context) {
    List<Widget> _pageOptions = <Widget>[
      Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Color(0xff36d1dc), Color(0xff19547b)]),
        ),
        child: ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 160),
              child: Text(
                "Hi there !",
                style: TextStyle(color: Colors.white, fontSize: 50, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20, left: 10, right: 10),
              child: Text(
                "Welcome to Gen Next Edu's App !",
                style: TextStyle(color: Colors.white, fontSize: 23),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 40, left: 20, right: 20),
              child: Text(
                "Our goal is to help students like you dash through the college admission process, with the help of our talented team and this feature-packed app",
                style: TextStyle(color: Colors.white, fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 60, left: 10, right: 10),
              child: Text(
                "Click start to begin your journey with us.\nBear in mind that none of your information\nwill be released without your permission",
                style: TextStyle(color: Colors.white70, fontSize: 15),
                textAlign: TextAlign.center,
              ),
            ),
            Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 30, left: 130),
                  child: Text(
                    "START",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 30, right: 15),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_forward,
                      size: 30,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedIndex += 1;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Color(0xff36d1dc), Color(0xff19547b)]),
        ),
        child: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 80),
              child: Text(
                'Account Information',
                style: TextStyle(color: Colors.white, fontSize: 33, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            Form(
              key: signupformKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 30, left: 50, right: 50),
                    child: TextFormField(
                      validator: (value) {
                        return value.isEmpty ? 'Enter your full name' : null;
                      },
                      onSaved: (value) => _name = value,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        labelText: "Full Name",
                        labelStyle: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30, left: 50, right: 50),
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
                  Padding(
                    padding: const EdgeInsets.only(top: 30, left: 50, right: 50),
                    child: TextFormField(
                      controller: _pass,
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
                  Padding(
                    padding: const EdgeInsets.only(top: 30, left: 50, right: 50),
                    child: TextFormField(
                      controller: _confirmPass,
                      validator: (String value) {
                        if (value.isEmpty) {
                          return "Confirm your password";
                        }
                        if (value != _pass.text) {
                          _confirmPass.clear();
                          return "Passwords don't match";
                        }
                        return null;
                      },
                      onSaved: (value) => _confpassword = value,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        labelStyle: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30, left: 50, right: 50),
                    child: TextFormField(
                      validator: (String value) {
                        return value.isEmpty ? 'Enter your country of residence' : null;
                      },
                      onSaved: (value) => _country = value,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Country',
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
              padding: EdgeInsets.only(top: 50, bottom: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(),
                    child: Row(
                      children: <Widget>[
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            size: 30,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            signupformKey.currentState.reset();
                            _pass.clear();
                            _confirmPass.clear();
                            setState(() {
                              _selectedIndex -= 1;
                            });
                          },
                        ),
                        Text(
                          "BACK",
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 170),
                    child: Row(
                      children: <Widget>[
                        Text(
                          "NEXT",
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                          textAlign: TextAlign.right,
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.arrow_forward,
                            size: 30,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              final form = signupformKey.currentState;
                              if (form.validate()) {
                                _selectedIndex += 1;
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Color(0xff36d1dc), Color(0xff19547b)]),
        ),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 300),
              child: Center(
                child: Text(
                  'Page 3',
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 320, bottom: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(),
                    child: Row(
                      children: <Widget>[
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            size: 30,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedIndex -= 1;
                            });
                          },
                        ),
                        Text(
                          "BACK",
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 170),
                    child: Row(
                      children: <Widget>[
                        Text(
                          "NEXT",
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                          textAlign: TextAlign.right,
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.arrow_forward,
                            size: 30,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedIndex += 1;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Color(0xff36d1dc), Color(0xff19547b)]),
        ),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 300),
              child: Center(
                child: Text(
                  'Page 4',
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 320, bottom: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(),
                    child: Row(
                      children: <Widget>[
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            size: 30,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedIndex -= 1;
                            });
                          },
                        ),
                        Text(
                          "BACK",
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 170),
                    child: Row(
                      children: <Widget>[
                        Text(
                          "FINISH",
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                          textAlign: TextAlign.right,
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.arrow_forward,
                            size: 30,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedIndex += 0;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    ];

    return Scaffold(
      body: _pageOptions.elementAt(_selectedIndex),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(canvasColor: Color(0xff36d1dc)),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.fiber_manual_record),
              title: Text(''),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fiber_manual_record),
              title: Text(''),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fiber_manual_record),
              title: Text(''),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fiber_manual_record),
              title: Text(''),
            ),
          ],
          unselectedItemColor: Colors.cyan[100],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.cyan[900],
        ),
      ),
    );
  }
}
