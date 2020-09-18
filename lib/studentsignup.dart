import 'imports.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class StudentSignUpPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => StudentSignUpPageState();
}

class StudentSignUpPageState extends State<StudentSignUpPage>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation _animation1;
  Animation _animation2;
  Animation _animation3;
  Animation _animation4;
  Animation _animation5;

  final registerFormKey = GlobalKey<FormState>();
  final signupformKey1 = GlobalKey<FormState>();
  final signupformKey2 = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _pass = TextEditingController();
  final TextEditingController _confirmpass = TextEditingController();
  ScrollController _scrollController;
  Future<List<dynamic>> _fetchCountries;
  List<DropdownMenuItem<String>> countries;
  // ignore: unused_field
  bool _isOnTop;
  int _selectedIndex = 0;
  int _radioValue = -1;

  File _profilepic;
  String _firstname;
  String _lastname;
  String _username;
  String _email;
  DateTime _dob;
  String _country;
  String _password;
  String _confpassword;
  String _degreelevel;
  String _school;
  String _major;
  List<String> _interests;
  bool _research;
  List<String> _countrypref = [];
  String _collegetownpref;
  List<int> _countryprefindexes = [];
  bool isChecked = false;
  int _budgetamount;

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
    _fetchCountries = fetchCountries();
    _isOnTop = false;
    _scrollController = ScrollController();
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 6));
    _animation1 = CurvedAnimation(
      parent: _controller,
      curve: Interval(0.0, 0.2, curve: Curves.fastOutSlowIn),
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
    BackButtonInterceptor.remove(myInterceptor);
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    return true;
  }

  _scrollToTop() {
    _scrollController.animateTo(_scrollController.position.minScrollExtent,
        duration: Duration(milliseconds: 1000), curve: Curves.easeIn);
    setState(() => _isOnTop = true);
  }

  Future<List<dynamic>> fetchCountries() async {
    var result =
        await http.get('https://restcountries.eu/rest/v2/all?fields=name');
    if (result.statusCode == 200) {
      List<String> countrylist = [];
      for (var i = 0; i < json.decode(result.body).length; i++) {
        countrylist.add(json.decode(result.body)[i]['name']);
      }
      countries = countrylist.map(
        (String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: TextStyle(fontSize: 16),
            ),
          );
        },
      ).toList();
      return json.decode(result.body);
    } else {
      throw Exception('Failed to load countries');
    }
  }

  Widget build(BuildContext context) {
    List<Widget> _pageOptions = <Widget>[
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: ListView(
          controller: _scrollController,
          children: <Widget>[
            FadeTransition(
              opacity: _animation1,
              child: Padding(
                padding: EdgeInsets.only(top: 150),
                child: Text(
                  " Hi there!",
                  style: TextStyle(
                      color: Color(0xff005fa8),
                      fontSize: 50,
                      fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            FadeTransition(
              opacity: _animation2,
              child: Padding(
                padding: EdgeInsets.only(),
                child: Text(
                  " Welcome to College Genie!",
                  style: TextStyle(
                      color: Color(0xff005fa8),
                      fontSize: 23,
                      fontWeight: FontWeight.w400),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            FadeTransition(
              opacity: _animation3,
              child: Padding(
                padding: EdgeInsets.only(top: 50, left: 20, right: 20),
                child: Text(
                  "Our goal is to help students dash through the college admission process,\nwith the help of our talented team and\nthis feature-packed app",
                  style: TextStyle(color: Colors.black54, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            FadeTransition(
              opacity: _animation4,
              child: Padding(
                padding: EdgeInsets.only(top: 50, left: 20, right: 20),
                child: Text(
                  "Answer a couple of questions and you'll be\nup and running in no time.",
                  style: TextStyle(color: Colors.black54, fontSize: 15),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            FadeTransition(
              opacity: _animation5,
              child: Padding(
                padding: EdgeInsets.only(top: 100, left: 120, right: 120),
                child: OutlineButton(
                  borderSide: BorderSide(color: Color(0xff005fa8)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.all(0.0),
                  onPressed: () {
                    setState(() {
                      _controller.reset();
                      _controller.duration = Duration(seconds: 6);
                      _controller.forward();
                      _selectedIndex += 1;
                      _scrollToTop();
                    });
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 15),
                        child: Text(
                          "START",
                          style:
                              TextStyle(color: Color(0xff005fa8), fontSize: 20),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Icon(
                        Icons.navigate_next,
                        size: 35,
                        color: Color(0xff005fa8),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: ListView(
          controller: _scrollController,
          children: <Widget>[
            FadeTransition(
              opacity: _animation1,
              child: Padding(
                padding: EdgeInsets.only(top: 50),
                child: Icon(
                  Icons.person,
                  size: 55,
                  color: Color(0xff005fa8),
                ),
              ),
            ),
            FadeTransition(
              opacity: _animation2,
              child: Padding(
                padding: EdgeInsets.only(top: 5),
                child: Text(
                  'Account Information',
                  style: TextStyle(
                      color: Color(0xff005fa8),
                      fontSize: 30,
                      fontWeight: FontWeight.w500),
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 40, right: 10),
                      child: Stack(
                        children: <Widget>[
                          CircleAvatar(
                            backgroundImage: _profilepic != null
                                ? FileImage(_profilepic)
                                : CachedNetworkImageProvider(
                                    "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcRcmHDwB_4wghy1PoY5WOkxHK4wf4k3MJ-17g&usqp=CAU",
                                  ),
                            backgroundColor: Colors.white,
                            radius: 45,
                          ),
                          ClipOval(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                child: Container(
                                  height: 90,
                                  width: 90,
                                  color: Colors.black.withOpacity(0.35),
                                  child: Center(
                                      child: Text(
                                    'EDIT',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  )),
                                ),
                                onTap: () async {
                                  File image = await FilePicker.getFile(
                                    type: FileType.image,
                                  );
                                  if (image != null) {
                                    setState(() {
                                      _profilepic = image;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10, left: 20, right: 50),
                      child: TextFormField(
                        cursorColor: Color(0xff005fa8),
                        validator: (value) {
                          return value.isEmpty ? 'Enter your first name' : null;
                        },
                        onSaved: (value) => _firstname = value,
                        onChanged: (value) => _firstname = value,
                        style: TextStyle(
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          icon: Icon(Icons.person),
                          labelText: "First Name",
                          labelStyle: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 30, left: 60, right: 50),
                      child: TextFormField(
                        cursorColor: Color(0xff005fa8),
                        validator: (value) {
                          return value.isEmpty ? 'Enter your last name' : null;
                        },
                        onSaved: (value) => _lastname = value,
                        onChanged: (value) => _lastname = value,
                        style: TextStyle(
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          labelText: "Last Name",
                          labelStyle: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 30, left: 60, right: 50),
                      child: TextFormField(
                        cursorColor: Color(0xff005fa8),
                        validator: (value) {
                          return value.isEmpty
                              ? 'Enter desired username'
                              : null;
                        },
                        onSaved: (value) => _username = value,
                        onChanged: (value) => _username = value,
                        style: TextStyle(
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          helperText:
                              "Don't forget, you'll need this to sign in",
                          labelText: "Username",
                          labelStyle: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 30, left: 20, right: 50),
                      child: TextFormField(
                        cursorColor: Color(0xff005fa8),
                        validator: (value) {
                          return value.isEmpty
                              ? 'Enter a valid Email ID'
                              : null;
                        },
                        onSaved: (value) => _email = value,
                        onChanged: (value) => _email = value,
                        style: TextStyle(
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          icon: Icon(Icons.email),
                          labelText: 'Email',
                          labelStyle: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 30, left: 20, right: 50),
                      child: DateTimeField(
                        cursorColor: Color(0xff005fa8),
                        validator: (value) {
                          return value == null
                              ? 'Enter your date of birth'
                              : null;
                        },
                        style: TextStyle(color: Colors.black),
                        format: DateFormat("MM-dd-yyyy"),
                        decoration: InputDecoration(
                          icon: Icon(Icons.calendar_today),
                          labelText: 'Date of Birth',
                          labelStyle: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                        onShowPicker: (context, _dob) {
                          return showDatePicker(
                            context: context,
                            firstDate: DateTime(1800),
                            initialDate: _dob == null ? DateTime.now() : _dob,
                            lastDate: DateTime.now(),
                            builder: (context, child) {
                              return Theme(
                                data: ThemeData(
                                    colorScheme: ColorScheme(
                                        brightness: Brightness.light,
                                        error: Color(0xff005fa8),
                                        onError: Colors.red,
                                        background: Color(0xff005fa8),
                                        primary: Color(0xff005fa8),
                                        primaryVariant: Color(0xff005fa8),
                                        secondary: Color(0xff005fa8),
                                        secondaryVariant: Color(0xff005fa8),
                                        onPrimary: Colors.white,
                                        surface: Color(0xff005fa8),
                                        onSecondary: Colors.black,
                                        onSurface: Colors.black,
                                        onBackground: Colors.black)),
                                child: child,
                              );
                            },
                          );
                        },
                        onChanged: (value) {
                          setState(() {
                            _dob = value;
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20, left: 20, right: 50),
                      child: TextFormField(
                        cursorColor: Color(0xff005fa8),
                        validator: (value) {
                          return value.isEmpty
                              ? 'Enter name of last attended school'
                              : null;
                        },
                        onSaved: (value) => _school = value,
                        onChanged: (value) => _school = value,
                        style: TextStyle(
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          icon: Icon(Icons.school),
                          labelText: "School",
                          labelStyle: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                              top: 30, left: 20, right: 10, bottom: 10),
                          child: Icon(Icons.public, color: Colors.black45),
                        ),
                        Flexible(
                          child: Padding(
                            padding: EdgeInsets.only(
                                top: 30, left: 5, right: 50, bottom: 0),
                            child: FutureBuilder<List<dynamic>>(
                              future: _fetchCountries,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return SearchableDropdown.single(
                                    dialogBox: true,
                                    menuBackgroundColor: Colors.white,
                                    icon: Icon(
                                      Icons.arrow_drop_down,
                                      size: 25,
                                      color: Colors.black54,
                                    ),
                                    items: countries,
                                    style: TextStyle(color: Colors.black),
                                    hint: Padding(
                                      padding: EdgeInsets.only(
                                          left: 0,
                                          right: 0,
                                          top: 0,
                                          bottom: 15),
                                      child: Text(
                                        "Country of Residence",
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 16),
                                      ),
                                    ),
                                    value: _country,
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
                      padding: EdgeInsets.only(top: 30, left: 20, right: 50),
                      child: TextFormField(
                        controller: _pass,
                        validator: (String value) {
                          return value.isEmpty ? 'Enter a password' : null;
                        },
                        onSaved: (value) => _password = value,
                        onChanged: (value) => _password = value,
                        style: TextStyle(
                          color: Colors.black,
                        ),
                        obscureText: true,
                        decoration: InputDecoration(
                          icon: Icon(Icons.vpn_key),
                          helperText:
                              "Needless to say, don't forget this either",
                          labelText: 'Password',
                          labelStyle: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 30, left: 60, right: 50),
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
                        onChanged: (value) => _confpassword = value,
                        style: TextStyle(
                          color: Colors.black,
                        ),
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          labelStyle: TextStyle(
                            color: Colors.black54,
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
                        onPressed: () {
                          setState(() {
                            if (registerFormKey.currentState.validate()) {
                              if (_country != null && _profilepic != null) {
                                print('valid');
                                _controller.reset();
                                _controller.duration = Duration(seconds: 8);
                                _controller.forward();
                                _selectedIndex += 1;
                                _scrollToTop();
                              } else if (_country == null) {
                                _scaffoldKey.currentState.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Selection of a country is required to proceed',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                );
                              } else {
                                _scaffoldKey.currentState.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "It'll be wonderful to have your profile pic",
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                );
                              }
                            }
                          });
                        },
                        child: Row(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Text(
                                "NEXT",
                                style: TextStyle(
                                    color: Color(0xff005fa8), fontSize: 15),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Icon(
                              Icons.navigate_next,
                              size: 25,
                              color: Color(0xff005fa8),
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
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: ListView(
          controller: _scrollController,
          children: <Widget>[
            FadeTransition(
              opacity: _animation1,
              child: Padding(
                padding: EdgeInsets.only(top: 50),
                child: Icon(
                  Icons.bubble_chart,
                  size: 55,
                  color: Color(0xff005fa8),
                ),
              ),
            ),
            FadeTransition(
              opacity: _animation2,
              child: Padding(
                padding: EdgeInsets.only(top: 5, left: 10, right: 10),
                child: Text(
                  'Tell us a little more about yourself',
                  style: TextStyle(
                      color: Color(0xff005fa8),
                      fontSize: 30,
                      fontWeight: FontWeight.w500),
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
                          canvasColor: Colors.white,
                        ),
                        child: DropdownButtonFormField(
                          icon: Icon(
                            Icons.arrow_drop_down,
                            size: 25,
                            color: Colors.black54,
                          ),
                          style: TextStyle(color: Colors.black),
                          hint: Text(
                            "Select Intended Degree Level",
                            style:
                                TextStyle(color: Colors.black54, fontSize: 16),
                          ),
                          itemHeight: kMinInteractiveDimension,
                          items: [
                            DropdownMenuItem(
                                child: Text(
                                  "Bachelor's",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black),
                                ),
                                value: "Bachelor's"),
                            DropdownMenuItem(
                                child: Text(
                                  "Master's",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black),
                                ),
                                value: "Master's"),
                            DropdownMenuItem(
                                child: Text(
                                  "Post bachelor's Certificate",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black),
                                ),
                                value: "Post bachelor's Certificate"),
                            DropdownMenuItem(
                                child: Text(
                                  "Post master's Certificate",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black),
                                ),
                                value: "Post master's Certificate"),
                            DropdownMenuItem(
                                child: Text(
                                  "Doctorate - research/internship",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black),
                                ),
                                value: "Doctorat"),
                            DropdownMenuItem(
                                child: Text(
                                  "Doctorate - professional practice",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black),
                                ),
                                value: "Doctorate - professional practic"),
                            DropdownMenuItem(
                                child: Text(
                                  "Certificate",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black),
                                ),
                                value: "Certificate"),
                            DropdownMenuItem(
                                child: Text(
                                  "Diploma",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black),
                                ),
                                value: "Diploma"),
                            DropdownMenuItem(
                                child: Text(
                                  "Associate",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black),
                                ),
                                value: "Associate"),
                            DropdownMenuItem(
                                child: Text(
                                  "Transfer",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black),
                                ),
                                value: "Transfer"),
                          ],
                          value: _degreelevel,
                          isExpanded: true,
                          onChanged: (value) {
                            setState(() {
                              _degreelevel = value;
                            });
                          },
                          validator: (value) {
                            return value == null
                                ? 'Selection of degree level is required'
                                : null;
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20, left: 50, right: 50),
                      child: TextFormField(
                        cursorColor: Color(0xff005fa8),
                        validator: (value) {
                          return null;
                        },
                        onSaved: (value) => _major = value,
                        onChanged: (value) => _major = value,
                        style: TextStyle(
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          labelText: "Intended Major (Optional)",
                          labelStyle: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 30, left: 30, right: 30),
                      child: ListTile(
                        title: Text('What are your interests ?',
                            style:
                                TextStyle(color: Colors.black, fontSize: 20)),
                        subtitle: Text(
                            'This will help our team recommend you majors or get to know more about you if you have an intended major'
                            ' (Min 3)',
                            style: TextStyle(color: Colors.black54)),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 0, left: 48, right: 50),
                      child: TextFormField(
                        validator: (value) {
                          if (value.split(',').length < 3) {
                            return 'Add at least 3 interests';
                          }
                          for (int i = 0; i < value.split(',').length; i++) {
                            if (value.split(',')[i] == '' ||
                                value.split(',')[i] == ' ') {
                              return 'Do not enter empty values';
                            }
                            if (value.split(',')[i].length > 1) {
                              if (value.split(',')[i][1] == ' ') {
                                return 'Do not enter empty values';
                              }
                            }
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _interests = value.split(",");
                        },
                        onChanged: (value) {
                          _interests = value.split(",");
                        },
                        style: TextStyle(
                          color: Colors.black,
                        ),
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          hintText: "Enter comma-separated interests",
                          hintStyle: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 35, left: 30, right: 30),
                      child: ListTile(
                        title: Text('Are you interested in Research ?',
                            style:
                                TextStyle(color: Colors.black, fontSize: 20)),
                        subtitle: Text(
                            'Let us know if you are interested in undertaking research during the course of your degree',
                            style: TextStyle(color: Colors.black54)),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20, right: 60),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                          Text('Yes      ',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16)),
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
                          Text('No',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16)),
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
                        onPressed: () {
                          setState(() {
                            if (signupformKey1.currentState.validate()) {
                              if (_research != null) {
                                _controller.reset();
                                _controller.duration = Duration(seconds: 8);
                                _controller.forward();
                                print('valid');
                                _selectedIndex += 1;
                                _scrollToTop();
                              } else {
                                _scaffoldKey.currentState.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Pick an option for interest in research',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                );
                              }
                            }
                          });
                        },
                        child: Row(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Text(
                                "NEXT",
                                style: TextStyle(
                                    color: Color(0xff005fa8), fontSize: 15),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Icon(
                              Icons.navigate_next,
                              size: 25,
                              color: Color(0xff005fa8),
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
          color: Colors.white,
        ),
        child: ListView(
          children: <Widget>[
            FadeTransition(
              opacity: _animation1,
              child: Padding(
                padding: EdgeInsets.only(top: 50),
                child: Icon(
                  Icons.account_balance,
                  size: 55,
                  color: Color(0xff005fa8),
                ),
              ),
            ),
            FadeTransition(
              opacity: _animation2,
              child: Padding(
                padding: EdgeInsets.only(top: 5),
                child: Text(
                  "Let's talk about your\ncollege preferences",
                  style: TextStyle(
                      color: Color(0xff005fa8),
                      fontSize: 30,
                      fontWeight: FontWeight.w500),
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
                        title: Text('Where would you like to study ?',
                            style:
                                TextStyle(color: Colors.black, fontSize: 20)),
                        subtitle: Text(
                            "Don't worry if you aren't sure yet, we'll help you find the best countries for your interests",
                            style: TextStyle(color: Colors.black54)),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 0, left: 40, right: 50),
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
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: TextStyle(fontSize: 16),
                                ),
                              );
                            }).toList();
                            return SearchableDropdown.multiple(
                              dialogBox: true,
                              menuBackgroundColor: Colors.white,
                              icon: Icon(
                                Icons.arrow_drop_down,
                                size: 25,
                                color: Colors.black54,
                              ),
                              items: countries,
                              selectedItems: _countryprefindexes,
                              style: TextStyle(color: Colors.black),
                              hint: Text(
                                "Select countries",
                                style: TextStyle(
                                    color: Colors.black54, fontSize: 16),
                              ),
                              searchHint: "Search Countries",
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
                              validator: (value) => null,
                            );
                          } else if (snapshot.hasError) {
                            return Text("${snapshot.error}");
                          }
                          return SpinKitWave(
                            color: Colors.black38,
                            size: 30,
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20, left: 20, right: 20),
                      child: ListTile(
                        title: Text('Any college locale preference ?',
                            style:
                                TextStyle(color: Colors.black, fontSize: 20)),
                        subtitle: Text(
                            "What environment would you like to study in? Select 'Any' if you're okay with any type of college location",
                            style: TextStyle(color: Colors.black54)),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 0, left: 40, right: 50),
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          canvasColor: Colors.white,
                        ),
                        child: DropdownButtonFormField(
                          icon: Icon(
                            Icons.arrow_drop_down,
                            size: 25,
                            color: Colors.black54,
                          ),
                          style: TextStyle(color: Colors.black),
                          hint: Padding(
                            padding: EdgeInsets.all(3.0),
                            child: Text(
                              "Select College Town Preference",
                              style: TextStyle(
                                  color: Colors.black54, fontSize: 16),
                            ),
                          ),
                          itemHeight: kMinInteractiveDimension,
                          items: [
                            DropdownMenuItem(
                                child: Text(
                                  'Large City',
                                  style: TextStyle(fontSize: 16),
                                ),
                                value: 'Large City'),
                            DropdownMenuItem(
                                child: Text(
                                  'College Town',
                                  style: TextStyle(fontSize: 16),
                                ),
                                value: 'College Town'),
                            DropdownMenuItem(
                                child: Text(
                                  'Rural City',
                                  style: TextStyle(fontSize: 16),
                                ),
                                value: 'Rural City'),
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
                            return value == null ? 'Select at least one' : null;
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20, left: 20, right: 20),
                      child: ListTile(
                        title: Text('Thought of a budget ?',
                            style:
                                TextStyle(color: Colors.black, fontSize: 20)),
                        subtitle: Text(
                            "We will be considering this budget when recommending universities for you."
                            "\nCheck 'Not Sure' if you don't know yet",
                            style: TextStyle(color: Colors.black54)),
                      ),
                    ),
                    if (isChecked == false)
                      Padding(
                        padding: EdgeInsets.only(right: 50, left: 40),
                        child: TextFormField(
                          validator: (value) {
                            if (_budgetamount == null) {}
                            return _budgetamount == null
                                ? 'Enter a budget amount'
                                : null;
                            ;
                          },
                          onChanged: (value) {
                            _budgetamount =
                                value == '' ? null : int.parse(value);
                          },
                          style: TextStyle(
                            color: Colors.black,
                          ),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "Amount in USD",
                            hintStyle: TextStyle(
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ),
                    Padding(
                      padding: EdgeInsets.only(left: 27),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
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
                          Text('Not Sure',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16)),
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
                        onPressed: () {
                          setState(() {
                            if (signupformKey2.currentState.validate()) {
                              for (int i = 0;
                                  i < _countryprefindexes.length;
                                  i++) {
                                if (countries[_countryprefindexes[i]].value ==
                                    "United Kingdom of Great Britain and Northern Ireland") {
                                  _countrypref.add("United Kingdom");
                                } else {
                                  _countrypref.add(
                                      countries[_countryprefindexes[i]].value);
                                }
                              }
                              print(_firstname);
                              print(_lastname);
                              print(_username);
                              print(_email);
                              print(_dob);
                              print(_school);
                              print(_country);
                              print(_password);
                              print(_confpassword);
                              print(_major);
                              print(_degreelevel);
                              print(_interests);
                              print(_countrypref);
                              print(_countryprefindexes);
                              print(_collegetownpref);
                              print(_budgetamount);
                              print(_research);
                              List data = [
                                _firstname,
                                _lastname,
                                _password,
                                _confpassword,
                                _username,
                                _email,
                                _country,
                                _interests,
                                _countrypref,
                                _profilepic,
                                _dob,
                                _school,
                                _major,
                                _degreelevel,
                                _research,
                                _budgetamount,
                                _collegetownpref
                              ];
                              Navigator.pop(context, data);
                            }
                          });
                        },
                        child: Row(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Text(
                                "FINISH",
                                style: TextStyle(
                                    color: Color(0xff005fa8), fontSize: 15),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Icon(
                              Icons.navigate_next,
                              size: 25,
                              color: Color(0xff005fa8),
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
    ];
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        statusBarColor: Colors.black.withOpacity(0.3),
      ),
      child: Scaffold(
        key: _scaffoldKey,
        body: _pageOptions[_selectedIndex],
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(canvasColor: Colors.white),
          child: BottomNavigationBar(
            elevation: 0,
            items: <BottomNavigationBarItem>[
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
            unselectedItemColor: Colors.black38,
            currentIndex: _selectedIndex,
            selectedItemColor: Color(0xff005fa8),
          ),
        ),
      ),
    );
  }
}
