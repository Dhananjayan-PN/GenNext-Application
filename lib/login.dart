import 'landingpage.dart';
import 'imports.dart';
import 'package:http/http.dart' as http;
import 'student/home.dart';
import 'counselor/home.dart';
import 'university/home.dart';
import 'signup.dart';
import 'main.dart';
import 'usermodel.dart';

String token2;
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

  @override
  void initState() {
    super.initState();
  }

  Route homepageRoute(String role) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => role == 'S'
          ? StudentHomeScreen(user: user)
          : role == 'C'
              ? CounselorHomeScreen(user: user)
              : role == 'R'
                  ? UniHomeScreen(user: user)
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
        token2 = json.decode(result.body)['token'];
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/tok.txt');
        await file.writeAsString(token2);
        final response = await http.get(
          domain + 'authenticate/details',
          headers: {HttpHeaders.authorizationHeader: "Token $token2"},
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
    token1 = null;
    token2 = null;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        statusBarColor: Color(0xff005fa8).withAlpha(200),
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
                    padding: EdgeInsets.only(top: 35, left: 55, right: 55),
                    child: Container(
                      alignment: Alignment.topRight,
                      height: 25,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Your first time here? ',
                            style: TextStyle(
                              fontSize: 17,
                              color: Colors.black54,
                            ),
                          ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              splashColor: Color(0xff005fa8),
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
                                  fontSize: 17,
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
