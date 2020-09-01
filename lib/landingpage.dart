import 'university/user.dart' as universityglobals;
import 'counselor/user.dart' as counselorglobals;
import 'student/user.dart' as studentglobals;
import 'package:http/http.dart' as http;
import 'university/home.dart';
import 'counselor/home.dart';
import 'student/home.dart';
import 'imports.dart';
import 'login.dart';

String domain = "https://collegegenie.org/";

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> getUserDetails(String token) async {
    try {
      final response = await http.get(
        domain + 'authenticate/details',
        headers: {HttpHeaders.authorizationHeader: "Token $token"},
      ).timeout(Duration(seconds: 10));
      if (response.statusCode == 200) {
        User user = User.fromJson(json.decode(response.body));
        Navigator.pop(context);
        Route route = homepageRoute(user.usertype, user);
        if (route != null) {
          Navigator.of(context)
              .pushAndRemoveUntil(route, (Route<dynamic> route) => false);
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            PageTransition(type: PageTransitionType.fade, child: LoginPage()),
            (Route<dynamic> route) => false,
          );
        }
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          PageTransition(type: PageTransitionType.fade, child: LoginPage()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      Navigator.pushAndRemoveUntil(
        context,
        PageTransition(type: PageTransitionType.fade, child: LoginPage()),
        (Route<dynamic> route) => false,
      );
    }
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
          return UniHomeScreen();
        } else if (role == 'A') {
          return Container();
        } else {
          return null;
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

  void route() async {
    final directory = await getApplicationDocumentsDirectory();
    bool exists = await File('${directory.path}/tok.txt').exists();
    if (exists) {
      final file = File('${directory.path}/tok.txt');
      String token = await file.readAsString();
      getUserDetails(token);
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        PageTransition(type: PageTransitionType.fade, child: LoginPage()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top]);
    route();
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.black.withOpacity(0.3),
      ),
      child: Scaffold(
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
                size: 40,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
