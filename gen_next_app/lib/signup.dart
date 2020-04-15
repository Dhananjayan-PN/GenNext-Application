import 'package:country_currency_pickers/utils/typedefs.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:country_currency_pickers/currency_picker_dropdown.dart';
import 'package:country_currency_pickers/country.dart';
import 'package:country_currency_pickers/country_pickers.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
//import 'package:back_button_interceptor/back_button_interceptor.dart'; //will be utilised in production
import 'package:page_transition/page_transition.dart';
import 'student/home.dart';

Future<List<dynamic>> fetchCountries() async {
  var result = await http.get('https://restcountries.eu/rest/v2/all?fields=name');

  if (result.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return json.decode(result.body);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

Widget _buildCurrencyDropdownItem(Country country) => Container(
      child: Row(
        children: <Widget>[
          CountryPickerUtils.getDefaultFlagImage(country),
          SizedBox(
            width: 8.0,
          ),
          Text("${country.currencyCode}"),
        ],
      ),
    );

class SignUpPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SignUpPageState();
}

class SignUpPageState extends State<SignUpPage> with SingleTickerProviderStateMixin {
  /*
  bool myInterceptor(bool stopDefaultButtonEvent) {
    return true;
  } */
  //remove ^^^ comment in production

  AnimationController _controller;
  Animation _animation1;
  Animation _animation2;
  Animation _animation3;
  Animation _animation4;
  Animation _animation5;

  final registerFormKey = GlobalKey<FormState>();
  final signupformKey1 = GlobalKey<FormState>();
  final signupformKey2 = GlobalKey<FormState>();
  final TextEditingController _pass = TextEditingController();
  final TextEditingController _confirmpass = TextEditingController();
  ScrollController _scrollController;
  Future<List<dynamic>> _fetchCountries;
  bool _isOnTop;
  int _selectedIndex = 0;
  int _radioValue = -1;

  //basic account information
  String _usertype;
  String _firstname;
  String _lastname;
  String _username;
  String _email;
  DateTime _dob;
  String _country;
  String _password;
  String _confpassword;

  //student account information
  String _degreelevel;
  String _grade;
  String _school;
  String _college;
  String _major;
  List<String> _interests;
  bool _research;
  List<String> _collegepref;
  List<String> _countrypref;
  String _collegetownpref;
  List<int> _countryprefindexes = [];
  bool isChecked = false;
  String _budgetcurrency;
  int _budgetamount = 40000;

  //counsellor account information

  //collegerep account information

  @override
  void initState() {
    super.initState();
    //BackButtonInterceptor.add(myInterceptor);
    _fetchCountries = fetchCountries();
    _isOnTop = false;
    _scrollController = ScrollController();
    _controller = AnimationController(vsync: this, duration: Duration(seconds: 7));
    _animation1 = CurvedAnimation(
      parent: _controller,
      curve: Interval(0.0, 0.3, curve: Curves.fastOutSlowIn),
    );
    _animation2 = CurvedAnimation(
      parent: _controller,
      curve: Interval(0.2, 0.4, curve: Curves.fastOutSlowIn),
    );
    _animation3 = CurvedAnimation(
      parent: _controller,
      curve: Interval(0.4, 0.6, curve: Curves.fastOutSlowIn),
    );
    _animation4 = CurvedAnimation(
      parent: _controller,
      curve: Interval(0.6, 0.8, curve: Curves.fastOutSlowIn),
    );
    _animation5 = CurvedAnimation(
      parent: _controller,
      curve: Interval(0.8, 1.0, curve: Curves.fastOutSlowIn),
    );
    _controller.forward();
  }

  @override
  dispose() {
    //BackButtonInterceptor.remove(myInterceptor);
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void registerUser() {
    //talk to API and register user
  }

  void updateUserInfo() {
    //talk to api and update personal profile information
  }

  _scrollToTop() {
    _scrollController.animateTo(_scrollController.position.minScrollExtent, duration: Duration(milliseconds: 1000), curve: Curves.easeIn);
    setState(() => _isOnTop = true);
  }

  Widget build(BuildContext context) {
    List<Widget> _pageOptions = <Widget>[
      Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Color(0xff36d1dc), Color(0xff19547b)]),
        ),
        child: ListView(
          controller: _scrollController,
          children: <Widget>[
            FadeTransition(
              opacity: _animation1,
              child: Padding(
                padding: EdgeInsets.only(top: 160),
                child: Text(
                  "Hi there !",
                  style: TextStyle(color: Colors.white, fontSize: 50, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            FadeTransition(
              opacity: _animation2,
              child: Padding(
                padding: EdgeInsets.only(top: 20, left: 10, right: 10),
                child: Text(
                  "Welcome to Gen Next Edu's App !",
                  style: TextStyle(color: Colors.white, fontSize: 23),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            FadeTransition(
              opacity: _animation3,
              child: Padding(
                padding: EdgeInsets.only(top: 40, left: 20, right: 20),
                child: Text(
                  "Our goal is to help students dash through the college admission process, with the help of our talented team and this feature-packed app",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            FadeTransition(
              opacity: _animation4,
              child: Padding(
                padding: EdgeInsets.only(top: 50, left: 10, right: 10),
                child: Text(
                  "Click start to begin your journey with us.\n"
                  "If you're a counsellor or a college representative looking to use this platform to help students,\nwe're happy to welcome you.",
                  style: TextStyle(color: Colors.white70, fontSize: 15),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            FadeTransition(
              opacity: _animation5,
              child: Row(
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
                          _controller.reset();
                          _controller.duration = Duration(seconds: 6);
                          _controller.forward();
                          _selectedIndex += 1;
                          _scrollToTop();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Color(0xff36d1dc), Color(0xff19547b)]),
        ),
        child: ListView(
          controller: _scrollController,
          children: <Widget>[
            FadeTransition(
              opacity: _animation1,
              child: Padding(
                padding: EdgeInsets.only(top: 50),
                child: Icon(Icons.person, size: 55, color: Colors.white),
              ),
            ),
            FadeTransition(
              opacity: _animation2,
              child: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  'Account Information',
                  style: TextStyle(color: Colors.white, fontSize: 33, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            FadeTransition(
              opacity: _animation3,
              child: Form(
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
                              context: context,
                              firstDate: DateTime(1900),
                              initialDate: _dob == null ? DateTime.now() : _dob,
                              lastDate: DateTime(2100));
                        },
                        onChanged: (value) {
                          setState(() {
                            _dob = value;
                          });
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 30, left: 20, right: 10, bottom: 20),
                          child: Icon(Icons.public, color: Colors.black45),
                        ),
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 30, left: 5, right: 50, bottom: 0),
                            child: FutureBuilder<List<dynamic>>(
                              future: _fetchCountries,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  List<String> countrylist = [];
                                  List<DropdownMenuItem<String>> countries;
                                  for (var i = 0; i < snapshot.data.length; i++) {
                                    countrylist.add(snapshot.data[i]['name']);
                                  }
                                  countries = countrylist.map((String value) {
                                    return new DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    );
                                  }).toList();
                                  return SearchableDropdown.single(
                                    //menuConstraints: BoxConstraints.tight(Size.fromHeight(350)),
                                    dialogBox: true,
                                    menuBackgroundColor: Colors.white,
                                    icon: Icon(
                                      Icons.arrow_drop_down,
                                      size: 25,
                                      color: Colors.white,
                                    ),
                                    items: countries,
                                    style: TextStyle(color: Colors.white),
                                    hint: Padding(
                                      padding: const EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 15),
                                      child: Text(
                                        "Country",
                                        style: TextStyle(color: Colors.white, fontSize: 16),
                                      ),
                                    ),
                                    value: _country,
                                    searchHint: "Select a country",
                                    onChanged: (value) {
                                      setState(() {
                                        _country = value;
                                      });
                                    },
                                    isExpanded: true,
                                  );
                                } else if (snapshot.hasError) {
                                  return Text("${snapshot.error}");
                                }
                                return CircularProgressIndicator();
                              },
                            ),
                          ),
                        ),
                      ],
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
            ),
            FadeTransition(
              opacity: _animation4,
              child: Padding(
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
                              print('valid');
                              //registerUser();
                              _controller.reset();
                              _controller.duration = Duration(seconds: 8);
                              _controller.forward();
                              _selectedIndex += 1;
                              _scrollToTop();
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
                              Icons.navigate_next,
                              size: 25,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
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
            controller: _scrollController,
            children: <Widget>[
              FadeTransition(
                opacity: _animation1,
                child: Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: Icon(Icons.bubble_chart, size: 55, color: Colors.white),
                ),
              ),
              FadeTransition(
                opacity: _animation2,
                child: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    'Tell us a little more about yourself',
                    style: TextStyle(color: Colors.white, fontSize: 33, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              FadeTransition(
                opacity: _animation3,
                child: Form(
                  key: signupformKey1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 30, left: 50, right: 50),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            canvasColor: Color(0xff19547b),
                          ),
                          child: DropdownButtonFormField(
                            icon: Icon(
                              Icons.arrow_drop_down,
                              size: 25,
                              color: Colors.white,
                            ),
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
                            validator: (value) {
                              return value == null ? 'Selection of degree level is required' : null;
                            },
                          ),
                        ),
                      ),
                      if (_degreelevel == 'UG') ...[
                        Padding(
                          padding: const EdgeInsets.only(top: 20, left: 50, right: 50),
                          child: TextFormField(
                            validator: (value) {
                              return value.isEmpty ? 'Enter name of last attended school' : null;
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
                          padding: EdgeInsets.only(top: 20, left: 50, right: 50),
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              canvasColor: Color(0xff19547b),
                            ),
                            child: DropdownButtonFormField(
                              icon: Icon(
                                Icons.arrow_drop_down,
                                size: 25,
                                color: Colors.white,
                              ),
                              style: TextStyle(color: Colors.white),
                              hint: Text(
                                "Select Grade",
                                style: TextStyle(fontSize: 16, color: Colors.white),
                              ),
                              itemHeight: kMinInteractiveDimension,
                              items: <String>['6', '7', '8', '9', '10', '11', '12', 'GY'].map((String value) {
                                return new DropdownMenuItem<String>(
                                  value: value,
                                  child: value == 'GY'
                                      ? Text(
                                          'Gap Year Student',
                                          style: TextStyle(fontSize: 16),
                                        )
                                      : Text(
                                          value + 'th',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                );
                              }).toList(),
                              value: _grade,
                              isExpanded: true,
                              onChanged: (value) {
                                setState(() {
                                  _grade = value;
                                });
                              },
                              validator: (value) {
                                return value == null ? 'Select a grade' : null;
                              },
                            ),
                          ),
                        ),
                      ],
                      if (_degreelevel == 'G') ...[
                        Padding(
                          padding: const EdgeInsets.only(top: 20, left: 50, right: 50),
                          child: TextFormField(
                            validator: (value) {
                              return value.isEmpty ? 'Enter name of last attended college' : null;
                            },
                            onSaved: (value) => _college = value,
                            style: TextStyle(
                              color: Colors.white,
                            ),
                            decoration: InputDecoration(
                              labelText: "Last Attended College",
                              labelStyle: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                      Padding(
                        padding: EdgeInsets.only(top: 20, left: 50, right: 50),
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
                      Padding(
                        padding: EdgeInsets.only(top: 30, left: 30, right: 30),
                        child: ListTile(
                          title: Text('What are your interests ?', style: TextStyle(color: Colors.white, fontSize: 20)),
                          subtitle: Text(
                              'This will help our team recommend you majors or get to know more about you if you have an intended major'
                              ' (Min 3)',
                              style: TextStyle(color: Colors.white60)),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 0, left: 50, right: 50),
                        child: TextFormField(
                          validator: (value) {
                            return value.split('\n').length < 3 ? 'Add at least 3 interests' : null;
                          },
                          onSaved: (value) {
                            _interests = value.split("\n");
                            print(_interests);
                          },
                          style: TextStyle(
                            color: Colors.white,
                          ),
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                            hintText: "Add interests in seperate lines",
                            hintStyle: TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 30, left: 30, right: 30),
                        child: ListTile(
                          title: Text('Are you interested in Research ?', style: TextStyle(color: Colors.white, fontSize: 20)),
                          subtitle: Text('Let us know if you are interested in undertaking research during the course of your degree',
                              style: TextStyle(color: Colors.white60)),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 20, right: 60),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Radio(
                                  value: 1,
                                  groupValue: _radioValue,
                                  onChanged: (value) {
                                    setState(() {
                                      _radioValue = value;
                                      switch (_radioValue) {
                                        case 0:
                                          _research = false;
                                          break;
                                        case 1:
                                          _research = true;
                                          break;
                                        default:
                                          _research = null;
                                      }
                                    });
                                  },
                                ),
                                Text('Yes      ', style: TextStyle(color: Colors.white, fontSize: 16)),
                                Radio(
                                  value: 0,
                                  groupValue: _radioValue,
                                  onChanged: (value) {
                                    setState(() {
                                      _radioValue = value;
                                      switch (value) {
                                        case 0:
                                          _research = false;
                                          break;
                                        case 1:
                                          _research = true;
                                          break;
                                        default:
                                          _research = null;
                                      }
                                    });
                                  },
                                ),
                                Text('No', style: TextStyle(color: Colors.white, fontSize: 16)),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              FadeTransition(
                opacity: _animation4,
                child: Padding(
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
                              if (signupformKey1.currentState.validate()) {
                                _controller.reset();
                                _controller.duration = Duration(seconds: 8);
                                _controller.forward();
                                print('valid');
                                //updateUser();
                                _selectedIndex += 1;
                                _scrollToTop();
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
                                Icons.navigate_next,
                                size: 25,
                                color: Colors.white,
                              ),
                            ],
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
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Color(0xff36d1dc), Color(0xff19547b)]),
          ),
          child: ListView(
            children: <Widget>[
              FadeTransition(
                opacity: _animation1,
                child: Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: Icon(Icons.account_balance, size: 55, color: Colors.white),
                ),
              ),
              FadeTransition(
                opacity: _animation2,
                child: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    "Let's talk about your\ncollege preferences",
                    style: TextStyle(color: Colors.white, fontSize: 33, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              FadeTransition(
                opacity: _animation3,
                child: Form(
                  key: signupformKey2,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 30, left: 20, right: 20),
                        child: ListTile(
                          title: Text('Have any colleges in mind ?', style: TextStyle(color: Colors.white, fontSize: 20)),
                          subtitle: Text("Don't worry if you aren't sure yet, our team will help you find the best ones for you",
                              style: TextStyle(color: Colors.white60)),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 0, left: 50, right: 50),
                        child: TextFormField(
                          validator: (value) {
                            return null;
                          },
                          onSaved: (value) {
                            _collegepref = value.split("\n");
                          },
                          style: TextStyle(
                            color: Colors.white,
                          ),
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                            hintText: "Add universities in seperate lines",
                            hintStyle: TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 30, left: 20, right: 20),
                        child: ListTile(
                          title: Text('Where would you like to study ?', style: TextStyle(color: Colors.white, fontSize: 20)),
                          subtitle: Text("Don't worry if you aren't sure yet, we'll help you find the best countries for your interests",
                              style: TextStyle(color: Colors.white60)),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 0, left: 50, right: 50),
                        child: FutureBuilder<List<dynamic>>(
                          future: _fetchCountries,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              List<String> countrylist = [];
                              List<DropdownMenuItem<String>> countries;
                              for (var i = 0; i < snapshot.data.length; i++) {
                                countrylist.add(snapshot.data[i]['name']);
                              }
                              countries = countrylist.map((String value) {
                                return new DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                );
                              }).toList();
                              return SearchableDropdown.multiple(
                                //menuConstraints: BoxConstraints.tight(Size.fromHeight(350)),
                                dialogBox: true,
                                menuBackgroundColor: Colors.white,
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                  size: 25,
                                  color: Colors.white,
                                ),
                                items: countries,
                                selectedItems: _countryprefindexes,
                                style: TextStyle(color: Colors.white),
                                hint: Text(
                                  "Select countries",
                                  style: TextStyle(color: Colors.white, fontSize: 16),
                                ),
                                searchHint: "Select countries",
                                onChanged: (value) {
                                  setState(() {
                                    _countryprefindexes = value;
                                  });
                                },
                                closeButton: (selectedItems) {
                                  return (selectedItems.isNotEmpty
                                      ? "Save ${selectedItems.length == 1 ? '"' + countries[selectedItems.first].value.toString() + '"' : '(' + selectedItems.length.toString() + ')'}"
                                      : "Save without selection");
                                },
                                isExpanded: true,
                                validator: (value) => value == null ? 'Select at least one' : null,
                              );
                            } else if (snapshot.hasError) {
                              return Text("${snapshot.error}");
                            }
                            return CircularProgressIndicator();
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 20, left: 20, right: 20),
                        child: ListTile(
                          title: Text('Any college locale preference ?', style: TextStyle(color: Colors.white, fontSize: 20)),
                          subtitle: Text("What environment would you like to study in? Select 'Any' if you're okay with any type of college location",
                              style: TextStyle(color: Colors.white60)),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 0, left: 50, right: 50),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            canvasColor: Color(0xff19547b),
                          ),
                          child: DropdownButtonFormField(
                            icon: Icon(
                              Icons.arrow_drop_down,
                              size: 25,
                              color: Colors.white,
                            ),
                            style: TextStyle(color: Colors.white),
                            hint: Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: Text(
                                "Select College Town Preference",
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            ),
                            itemHeight: kMinInteractiveDimension,
                            items: [
                              DropdownMenuItem(
                                  child: Text(
                                    'Large Urban City',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  value: 'Large Urban City'),
                              DropdownMenuItem(
                                  child: Text(
                                    'Suburban City',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  value: 'Suburban City'),
                              DropdownMenuItem(
                                  child: Text(
                                    'Rural Town',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  value: 'Rural Town'),
                              DropdownMenuItem(
                                  child: Text(
                                    'Any',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  value: 'Any'),
                            ],
                            value: _collegetownpref,
                            isExpanded: true,
                            onChanged: (value) {
                              setState(() {
                                _collegetownpref = value;
                              });
                            },
                            validator: (value) {
                              return value == null ? 'Choose at least one' : null;
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 20, left: 20, right: 20),
                        child: ListTile(
                          title: Text('Thought of a budget ?', style: TextStyle(color: Colors.white, fontSize: 20)),
                          subtitle: Text(
                              "We will consider this budget when selecting colleges and countries for you."
                              "\nCheck 'Not Sure' if you don't know yet",
                              style: TextStyle(color: Colors.white60)),
                        ),
                      ),
                      if (isChecked == false)
                        Padding(
                          padding: const EdgeInsets.only(right: 50, left: 50),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              CurrencyPickerDropdown(
                                initialValue: 'USD',
                                itemBuilder: _buildCurrencyDropdownItem,
                                onValuePicked: (Country country) {
                                  _budgetcurrency = country.currencyCode;
                                },
                              ),
                              Flexible(
                                child: TextFormField(
                                  validator: (value) {
                                    return null;
                                  },
                                  onSaved: (value) {
                                    _budgetamount = int.parse(value);
                                  },
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: "Amount",
                                    hintStyle: TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Padding(
                        padding: EdgeInsets.only(left: 0, right: 80),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Checkbox(
                              value: isChecked,
                              onChanged: (value) {
                                setState(() {
                                  isChecked = value;
                                });
                              },
                            ),
                            Text('Not Sure', style: TextStyle(color: Colors.white, fontSize: 16)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              FadeTransition(
                opacity: _animation4,
                child: Padding(
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
                              if (signupformKey2.currentState.validate()) {
                                print('valid');
                                //updateUser();
                                /*Navigator.pushAndRemoveUntil(
                                  context,
                                  PageTransition(type: PageTransitionType.fade, child: StudentHomeScreen()),
                                  (Route<dynamic> route) => false,
                                );*/
                              }
                            });
                          },
                          child: Row(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text(
                                  "FINISH",
                                  style: TextStyle(color: Colors.white, fontSize: 15),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Icon(
                                Icons.navigate_next,
                                size: 25,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ],
      if (_usertype == 'Counsellor') ...[],
      if (_usertype == 'CollegeRep') ...[],
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
