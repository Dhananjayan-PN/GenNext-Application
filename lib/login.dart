import 'dart:developer';

import 'landingpage.dart';
import 'package:dio/dio.dart' as dio;
import 'imports.dart';
import 'package:http/http.dart' as http;
import 'student/home.dart';
import 'counselor/home.dart';
import 'university/home.dart';
import 'admin/home.dart';
import 'signup.dart';
import 'usermodel.dart';
import 'student/user.dart' as studentglobals;
import 'counselor/user.dart' as counselorglobals;
import 'university/user.dart' as universityglobals;
import 'admin/user.dart' as adminglobals;

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

  // ignore: unused_field
  String _username;
  // ignore: unused_field
  String _password;

  @override
  void initState() {
    super.initState();
  }

  Route homepageRoute(String role, User user) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) {
        if (role == 'S') {
          studentglobals.user = user;
          return StudentHomeScreen();
        } else if (role == 'C') {
          counselorglobals.user = user;
          return CounselorHomeScreen();
        } else if (role == 'R') {
          universityglobals.user = user;
          return UniLandingPage();
        } else if (role == 'A') {
          adminglobals.user = user;
          return AdminHomeScreen();
        } else {
          return Container();
        }
      },
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
        String token = json.decode(result.body)['token'];
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/tok.txt');
        await file.writeAsString(token);
        final response = await http.get(
          domain + 'authenticate/details',
          headers: {HttpHeaders.authorizationHeader: "Token $token"},
        );
        if (response.statusCode == 200) {
          User user = User.fromJson(json.decode(response.body));
          Route route = homepageRoute(user.usertype, user);
          if (route != null) {
            Navigator.pop(context);
            Navigator.of(context)
                .pushAndRemoveUntil(route, (Route<dynamic> route) => false);
          } else {
            username.clear();
            password.clear();
            Navigator.pop(context);
            error(context);
          }
        }
      } else if (result.statusCode == 521 || result.statusCode == 500) {
        username.clear();
        password.clear();
        Navigator.pop(context);
        error(context);
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
      error(context);
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
          error(context);
        });
      });
    } else {
      print("Form Is Invalid");
    }
  }

  Future<void> registerStudent(List data) async {
    print(data[0]);
    print(data[1]);
    print(data[2]);
    print(data[3]);
    print(data[4]);
    print(data[5]);
    print(data[6]);
    print(data[7]);
    print(data[8]);
    print(data[9]);
    print(data[10]);
    print(data[11]);
    print(data[12]);
    print(data[13]);
    print(data[14]);
    print(data[15]);
    print(data[16]);
    // try {
    var dioRequest = dio.Dio();
    dioRequest.options.headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    var formData = dio.FormData.fromMap({
      'first_name': data[0],
      'last_name': data[1],
      'password': data[2],
      'confirm_pass': data[3],
      'username': data[4],
      'email': data[5],
      'country': data[6],
      'interests': data[7].toString(),
      'countries': data[8].toString(),
      'grade': data[17] ?? 0,
      'dob': data[10],
      'school': data[11],
      'major': data[12],
      'degree_level': data[13],
      'interested_in_research': data[14],
      'budget': data[15] ?? 0,
      'location_preferance': data[16],
    });
    var file = await dio.MultipartFile.fromFile(
      data[9].path,
    );
    formData.files.add(MapEntry('profile_image', file));
    var response =
        await dioRequest.post(domain + 'authenticate/api-student-registration/',
            data: formData,
            options: dio.Options(
              followRedirects: false,
              validateStatus: (status) {
                return status < 500;
              },
            ));
    print(response.data);
    if (response.statusCode == 200) {
      if (response.data['Response'] == 'User successfully created.') {
        Navigator.pop(context);
        success(context,
            'Account successfully created!\nSign in with your credentials');
      } else {
        Navigator.pop(context);
        error(context);
      }
    } else {
      Navigator.pop(context);
      error(context);
    }
    // } catch (e) {
    //   Navigator.pop(context);
    //   error(context);
    // }
  }

  loading(BuildContext context) {
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
              color: Color(0xff005fa8),
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 50,
                    width: 50,
                    child: SpinKitWave(
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 23.0),
                    child: Text(
                      "Creating your account...",
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

  error(BuildContext context,
      [String message =
          'Something went wrong.\nCheck your connection and try again later.']) {
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
              color: Color(0xff005fa8),
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.error_outline,
                    size: 40,
                    color: Colors.red,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(
                      message ??
                          'Something went wrong.\nCheck your connection and try again later.',
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

  success(BuildContext context, String message) {
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
              color: Color(0xff005fa8),
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.check_circle_outline,
                    size: 40,
                    color: Colors.green,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(
                      message,
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
              color: Color(0xff005fa8),
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
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
              color: Color(0xff005fa8),
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
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
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        statusBarColor: Colors.black.withOpacity(0.3),
      ),
      child: WillPopScope(
        onWillPop: () async => Future.value(false),
        child: Scaffold(
          backgroundColor: Colors.white,
          key: _scafKey,
          body: ScrollConfiguration(
            behavior: ScrollBehavior()
              ..buildViewportChrome(context, null, AxisDirection.down),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 100, right: 100),
                    child: Transform.scale(
                      scale: 1,
                      child: Container(
                        alignment: Alignment.centerLeft,
                        height: 45,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          boxShadow: [...kElevationToShadow[8]],
                          color: Color(0xff005fa8),
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(20),
                              bottomRight: Radius.circular(20)),
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 1.3),
                            child: Text(
                              'Are you future-ready ?',
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
                    padding: EdgeInsets.only(top: 45, right: 20, left: 8),
                    child: Image.asset(
                      'images/CollegeGenieLogo-2.png',
                      height: 175,
                      width: 200,
                      fit: BoxFit.contain,
                      colorBlendMode: BlendMode.darken,
                    ),
                  ),
                  Form(
                    key: formKey,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding:
                              EdgeInsets.only(top: 35, left: 35, right: 50),
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              primaryColor: Color(0xff0072BC),
                            ),
                            child: TextFormField(
                              cursorColor: Color(0xff005fa8),
                              key: ValueKey('Username'),
                              controller: username,
                              validator: (value) {
                                return value.isEmpty
                                    ? 'Enter your username'
                                    : null;
                              },
                              onSaved: (value) => _username = value,
                              style: TextStyle(
                                color: Colors.black,
                              ),
                              decoration: InputDecoration(
                                icon: Icon(Icons.person),
                                labelText: 'Username',
                                labelStyle: TextStyle(
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.only(top: 20, left: 35, right: 50),
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              primaryColor: Color(0xff0072BC),
                            ),
                            child: TextFormField(
                              cursorColor: Color(0xff005fa8),
                              key: ValueKey('Password'),
                              controller: password,
                              validator: (String value) {
                                return value.isEmpty
                                    ? 'Enter your password'
                                    : null;
                              },
                              onSaved: (value) => _password = value,
                              style: TextStyle(
                                color: Colors.black,
                              ),
                              obscureText: true,
                              decoration: InputDecoration(
                                icon: Icon(Icons.vpn_key),
                                labelText: 'Password',
                                labelStyle: TextStyle(
                                  color: Colors.black54,
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
                          boxShadow: [...kElevationToShadow[8]],
                          color: Color(0xff005fa8),
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
                                  color: Colors.white,
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
                    padding: EdgeInsets.only(top: 35),
                    child: Container(
                      alignment: Alignment.topRight,
                      height: 25,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "Don't have an account yet? ",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              splashColor: Color(0xff005fa8),
                              onTap: () async {
                                formKey.currentState.reset();
                                final data = await Navigator.push(
                                  context,
                                  PageTransition(
                                    type: PageTransitionType.downToUp,
                                    child: SignUpPage(),
                                  ),
                                );
                                if (data != null) {
                                  registerStudent(data);
                                  loading(context);
                                }
                              },
                              child: Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xff005fa8),
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
      ),
    );
  }
}
