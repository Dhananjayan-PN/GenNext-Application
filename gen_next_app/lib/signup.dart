import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
//import 'package:page_transition/page_transition.dart';
//import 'student/home.dart';

class SignUpPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SignUpPageState();
}

class SignUpPageState extends State<SignUpPage> {
  final registerFormKey = GlobalKey<FormState>();
  final signupformKey = GlobalKey<FormState>();
  final TextEditingController _pass = TextEditingController();
  final TextEditingController _confirmpass = TextEditingController();
  int _selectedIndex = 0;

  String _usertype;
  String _firstname;
  String _lastname;
  DateTime _dob;
  String _username;
  String _email;
  String _password;
  String _confpassword;
  String _country;
  String _degreelevel;
  String _grade;
  String _school;
  String _major;

  void registerUser() {
    //talk to API and register user
  }

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
                "Our goal is to help students dash through the college admission process, with the help of our talented team and this feature-packed app",
                style: TextStyle(color: Colors.white, fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 50, left: 10, right: 10),
              child: Text(
                "Click start to begin your journey with us.\n"
                "If you're a counsellor or a college representative looking to use this platform to help students,\nwe're happy to welcome you.",
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
              padding: EdgeInsets.only(top: 50),
              child: Icon(Icons.person, size: 55, color: Colors.white),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                'Account Information',
                style: TextStyle(color: Colors.white, fontSize: 33, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            Form(
              key: registerFormKey,
              autovalidate: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 30, left: 20, right: 50),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        canvasColor: Color(0xff19547b),
                      ),
                      child: DropdownButtonFormField(
                        decoration: InputDecoration(
                          icon: Icon(Icons.person),
                        ),
                        icon: Icon(
                          Icons.arrow_drop_down,
                          size: 25,
                          color: Colors.white,
                        ),
                        style: TextStyle(color: Colors.white),
                        hint: Text(
                          "Tell us who you are",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        itemHeight: kMinInteractiveDimension,
                        items: [
                          DropdownMenuItem(
                              child: Text(
                                'Student',
                                style: TextStyle(fontSize: 16),
                              ),
                              value: 'Student'),
                          DropdownMenuItem(
                              child: Text(
                                'Counsellor',
                                style: TextStyle(fontSize: 16),
                              ),
                              value: 'Counsellor'),
                          DropdownMenuItem(
                              child: Text(
                                'College Representative',
                                style: TextStyle(fontSize: 16),
                              ),
                              value: 'CollegeRep'),
                        ],
                        value: _usertype,
                        validator: (value) => value == null ? 'This field is important' : null,
                        isExpanded: true,
                        onChanged: (value) {
                          setState(() {
                            _usertype = value;
                          });
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30, left: 60, right: 50),
                    child: TextFormField(
                      validator: (value) {
                        return value.isEmpty ? 'Enter your first name' : null;
                      },
                      onSaved: (value) => _firstname = value,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        labelText: "First Name",
                        labelStyle: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30, left: 60, right: 50),
                    child: TextFormField(
                      validator: (value) {
                        return value.isEmpty ? 'Enter your last name' : null;
                      },
                      onSaved: (value) => _lastname = value,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        labelText: "Last Name",
                        labelStyle: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30, left: 60, right: 50),
                    child: TextFormField(
                      validator: (value) {
                        return value.isEmpty ? 'Enter desired username' : null;
                      },
                      onSaved: (value) => _username = value,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        labelText: "Username",
                        labelStyle: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30, left: 20, right: 50),
                    child: TextFormField(
                      validator: (value) {
                        return value.isEmpty ? 'Enter a valid Email ID' : null;
                      },
                      onSaved: (value) => _email = value,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        icon: Icon(Icons.email),
                        labelText: 'Email',
                        labelStyle: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30, left: 20, right: 50),
                    child: DateTimeField(
                      validator: (value) {
                        return value == null ? 'Enter your date of birth' : null;
                      },
                      style: TextStyle(color: Colors.white),
                      format: DateFormat("MM-dd-yyyy"),
                      decoration: InputDecoration(
                        icon: Icon(Icons.calendar_today),
                        labelText: 'Date of Birth',
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                      onShowPicker: (context, _dob) {
                        return showDatePicker(
                            context: context, firstDate: DateTime(1900), initialDate: _dob == null ? DateTime.now() : _dob, lastDate: DateTime(2100));
                      },
                      onChanged: (value) {
                        setState(() {
                          _dob = value;
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30, left: 20, right: 50),
                    child: TextFormField(
                      validator: (String value) {
                        return value.isEmpty ? 'Enter your country of residence' : null;
                      },
                      onSaved: (value) => _country = value,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        icon: Icon(Icons.public),
                        labelText: 'Country',
                        labelStyle: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30, left: 20, right: 50),
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
                        icon: Icon(Icons.vpn_key),
                        labelText: 'Password',
                        labelStyle: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30, left: 60, right: 50),
                    child: TextFormField(
                      controller: _confirmpass,
                      validator: (String value) {
                        if (value.isEmpty) {
                          return "Confirm your password";
                        }
                        if (value != _pass.text) {
                          _confirmpass.clear();
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
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 30, bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: FlatButton(
                      splashColor: Color(0xff19547b),
                      onPressed: () {
                        setState(() {
                          if (registerFormKey.currentState.validate()) {
                            registerFormKey.currentState.reset();
                            print('valid');
                            //registerUser();
                            _selectedIndex += 1;
                          }
                        });
                      },
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              "NEXT",
                              style: TextStyle(color: Colors.white, fontSize: 15),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 25,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      if (_usertype == 'Student') ...[
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Color(0xff36d1dc), Color(0xff19547b)]),
          ),
          child: ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 80),
                child: Text(
                  'Tell us a little more about yourself',
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
                      padding: EdgeInsets.only(top: 30, left: 50, right: 50),
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          canvasColor: Color(0xff19547b),
                        ),
                        child: DropdownButton(
                          style: TextStyle(color: Colors.white),
                          hint: Text(
                            "Select Intended Degree Level",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          itemHeight: kMinInteractiveDimension,
                          items: [
                            DropdownMenuItem(
                                child: Text(
                                  'Undergraduate',
                                  style: TextStyle(fontSize: 16),
                                ),
                                value: 'UG'),
                            DropdownMenuItem(
                                child: Text(
                                  'Graduate',
                                  style: TextStyle(fontSize: 16),
                                ),
                                value: 'G'),
                          ],
                          value: _degreelevel,
                          isExpanded: true,
                          onChanged: (value) {
                            setState(() {
                              _degreelevel = value;
                            });
                          },
                        ),
                      ),
                    ),
                    if (_degreelevel == 'UG') ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 20, left: 50, right: 50),
                        child: TextFormField(
                          validator: (value) {
                            return null;
                          },
                          onSaved: (value) => _school = value,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            labelText: "School",
                            labelStyle: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 30, left: 50, right: 50),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            canvasColor: Color(0xff19547b),
                          ),
                          child: DropdownButton(
                            style: TextStyle(color: Colors.white),
                            hint: Text(
                              "Select Grade",
                              style: TextStyle(fontSize: 16),
                            ),
                            itemHeight: kMinInteractiveDimension,
                            items: [
                              DropdownMenuItem(
                                  child: Text(
                                    'Below 9th',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  value: '<9'),
                              DropdownMenuItem(
                                  child: Text(
                                    '9th',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  value: '9'),
                              DropdownMenuItem(
                                  child: Text(
                                    '10th',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  value: '10'),
                              DropdownMenuItem(
                                  child: Text(
                                    '11th',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  value: '11'),
                              DropdownMenuItem(
                                  child: Text(
                                    '12th',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  value: '12'),
                              DropdownMenuItem(
                                  child: Text(
                                    'Gap Year Student',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  value: 'GY'),
                            ],
                            value: _grade,
                            isExpanded: true,
                            onChanged: (value) {
                              setState(() {
                                _grade = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                    Padding(
                      padding: const EdgeInsets.only(top: 20, left: 50, right: 50),
                      child: TextFormField(
                        validator: (value) {
                          return null;
                        },
                        onSaved: (value) => _major = value,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          labelText: "Intended Major (Optional)",
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
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(right: 15),
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
                                if (signupformKey.currentState.validate()) {
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
                    'Page 4',
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 320, bottom: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(right: 15),
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
      ]
    ];

    return Scaffold(
      body: _pageOptions[_selectedIndex],
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
