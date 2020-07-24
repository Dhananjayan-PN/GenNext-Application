import 'package:http/http.dart' as http;
import 'student/home.dart';
import 'counselor/home.dart';
import 'university/home.dart';
import 'login.dart';
import 'imports.dart';

String token1;
String domain = "https://gennext.ml/";

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  Future<void> getUserDetails(String token) async {
    final response = await http.get(
      domain + 'authenticate/details',
      headers: {HttpHeaders.authorizationHeader: "Token $token"},
    );
    if (response.statusCode == 200) {
      User user = User.fromJson(json.decode(response.body));
      Navigator.pop(context);
      Route route = homepageRoute(user.usertype, user);
      if (route != null) {
        Navigator.of(context).push(route);
      } else {
        _error();
      }
    } else {
      _error();
    }
  }

  Route homepageRoute(String role, User user) {
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

  void route() async {
    final directory = await getApplicationDocumentsDirectory();
    bool exists = await File('${directory.path}/tok.txt').exists();
    if (exists) {
      final file = File('${directory.path}/tok.txt');
      token1 = await file.readAsString();
      getUserDetails(token1);
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        PageTransition(type: PageTransitionType.fade, child: LoginPage()),
        (Route<dynamic> route) => false,
      );
    }
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

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top]);
    route();
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.only(bottom: 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding:
                  EdgeInsets.only(top: 45, right: 20, left: 8, bottom: 100),
              child: Image.asset(
                'images/CollegeGenieLogo-2.png',
                height: 165,
                width: 190,
                fit: BoxFit.contain,
                colorBlendMode: BlendMode.darken,
              ),
            ),
            SpinKitWave(
              color: Colors.black38,
              size: 30,
            ),
          ],
        ),
      ),
    );
  }
}
