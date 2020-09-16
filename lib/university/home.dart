import 'package:http/http.dart' as http;
import '../imports.dart';
import '../login.dart';
import '../landingpage.dart';
import 'allunis.dart';
import 'counselorconnect.dart';
import 'engagement.dart';
import 'repprofile.dart';
import 'universityprofile.dart';
import 'dashboard.dart';
import 'notifications.dart';
import 'user.dart' as universityglobals;

String dom = domain;
Widget curPage;
List navlistelements = [
  ['Home', UniHomeScreen(), Icons.home],
  ['My Profile', RepProfileScreen(), Icons.account_box],
  ['University Profile', UniProfileScreen(), Icons.account_balance],
  ['All Universities', AllUniversitiesScreen(), Icons.all_inclusive],
  ['Counselor Connect', CounselorConnectScreen(), Icons.link],
  ['Student Engagement', StudentEngagementScreen(), Icons.group],
];

Future<String> getToken() async {
  final directory = await getApplicationDocumentsDirectory();
  String tok = await File('${directory.path}/tok.txt').readAsString();
  return tok;
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
                    color: Colors.grey.withOpacity(0.8),
                    size: 25,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 23.0),
                  child: Text(
                    "Saving your changes",
                    style: TextStyle(color: Colors.black, fontSize: 15),
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
                  color: Colors.red.withOpacity(0.9),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    message ??
                        'Something went wrong.\nCheck your connection and try again later.',
                    style: TextStyle(color: Colors.black, fontSize: 12),
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
                    style: TextStyle(color: Colors.black, fontSize: 14),
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

class NavDrawer extends StatefulWidget {
  @override
  _NavDrawerState createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  @override
  Widget build(BuildContext context) {
    List<Widget> navlist = [];
    for (var i = 0; i < navlistelements.length; i++) {
      var element = navlistelements[i];
      navlist.add(
        Padding(
          padding: EdgeInsets.only(left: 6),
          child: ListTile(
            leading: Icon(
              element[2],
              size: 26,
              color: Color(0xff005fa8),
            ),
            title: Align(
              alignment: Alignment(-1, 0),
              child: Text(
                element[0],
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.5,
                    fontWeight: FontWeight.w400),
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              if (curPage == element[1]) {
              } else {
                curPage = element[1];
                Navigator.pushAndRemoveUntil(
                  context,
                  PageTransition(
                      type: PageTransitionType.fade, child: element[1]),
                  (Route<dynamic> route) => false,
                );
              }
            },
          ),
        ),
      );
      navlist.add(
        Divider(),
      );
    }
    return Drawer(
      elevation: 20,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            height: 210,
            child: UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xff005fa8),
              ),
              accountName: Text(
                  universityglobals.user.firstname +
                      ' ' +
                      universityglobals.user.lastname,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w400)),
              accountEmail: Text(universityglobals.user.email,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w300)),
              currentAccountPicture: CircleAvatar(
                backgroundImage:
                    CachedNetworkImageProvider(universityglobals.user.dp),
                backgroundColor: Colors.blue[800],
                radius: 30,
              ),
              onDetailsPressed: () {
                Navigator.pop(context);
                curPage = RepProfileScreen();
                Navigator.pushAndRemoveUntil(
                  context,
                  PageTransition(
                      type: PageTransitionType.fade, child: RepProfileScreen()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ),
          Column(mainAxisSize: MainAxisSize.min, children: navlist),
          Padding(
            padding: EdgeInsets.only(left: 6),
            child: ListTile(
              leading: Icon(Icons.power_settings_new,
                  size: 26, color: Colors.red[600]),
              title: Align(
                alignment: Alignment(-1, 0),
                child: Text('Sign Out',
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                        fontSize: 16.5)),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    contentPadding: EdgeInsets.all(0),
                    elevation: 20,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15.0))),
                    content: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.all(Radius.circular(15.0)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(top: 30),
                            child: Icon(
                              Icons.power_settings_new,
                              size: 40,
                              color: Colors.red.withOpacity(0.9),
                            ),
                          ),
                          Padding(
                            padding:
                                EdgeInsets.only(left: 5, right: 5, top: 10),
                            child: Text(
                              'Are you sure you want to sign out?',
                              style: TextStyle(
                                  fontSize: 14.3,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w300),
                              textAlign: TextAlign.center,
                            ),
                          )
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      FlatButton(
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: Color(0xff005fa8)),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      FlatButton(
                        child: Text(
                          'Sign out',
                          style: TextStyle(color: Colors.red),
                        ),
                        onPressed: () async {
                          try {
                            final directory =
                                await getApplicationDocumentsDirectory();
                            final file = File('${directory.path}/tok.txt');
                            file.delete();
                            universityglobals.user = null;
                          } catch (_) {
                            print('Error');
                          }
                          Navigator.pop(context);
                          Navigator.of(context).pushAndRemoveUntil(
                              logoutRoute(), (route) => false);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Divider(),
        ],
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget with PreferredSizeWidget {
  final String titletext;
  CustomAppBar(this.titletext);
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 6,
      title: Text(
        titletext,
      ),
      backgroundColor: Color(0xff005fa8),
    );
  }
}

class HomeAppBar extends StatefulWidget with PreferredSizeWidget {
  @override
  State<StatefulWidget> createState() => HomeAppBarState();
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class HomeAppBarState extends State<HomeAppBar> {
  Future notifications;

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
    notifications = getNotifications();
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    return true;
  }

  Future<void> getNotifications() async {
    String tok = await getToken();
    final response = await http.get(
      dom + 'authenticate/get-alerts',
      headers: {
        HttpHeaders.authorizationHeader: 'Token $tok',
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['alert_data'];
    } else {
      throw ('error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('Home'),
      backgroundColor: Color(0xff005fa8),
      actions: <Widget>[
        FutureBuilder(
          future: notifications,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Padding(
                padding: EdgeInsets.only(right: 4),
                child: Stack(
                  children: <Widget>[
                    IconButton(
                        icon: Icon(Icons.notifications),
                        alignment: Alignment.bottomLeft,
                        onPressed: () {}),
                    Positioned(
                      right: 12.5,
                      top: 12.5,
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(top: 1),
                          child: SizedBox(
                            height: 10,
                            width: 10,
                            child: Icon(Icons.priority_high,
                                color: Colors.white, size: 10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            if (snapshot.hasData) {
              return Padding(
                padding: EdgeInsets.only(right: 4),
                child: Stack(
                  children: <Widget>[
                    IconButton(
                        icon: Icon(Icons.notifications),
                        alignment: Alignment.bottomLeft,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NotificationScreen(
                                      notifications: snapshot.data,
                                    )),
                          );
                        }),
                    Positioned(
                      right: 12.5,
                      top: 12.5,
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(right: 0.01),
                          child: Text(
                            snapshot.data.length.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return Padding(
              padding: EdgeInsets.only(right: 4),
              child: Stack(
                children: <Widget>[
                  IconButton(
                      icon: Icon(Icons.notifications),
                      alignment: Alignment.bottomLeft,
                      onPressed: () {}),
                  Positioned(
                    right: 12.5,
                    top: 12.5,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 14,
                        minHeight: 14,
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(top: 1),
                        child: SizedBox(
                          height: 10,
                          width: 10,
                          child:
                              SpinKitThreeBounce(color: Colors.white, size: 5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class UniHomeScreen extends StatefulWidget {
  @override
  _UniHomeScreenState createState() => _UniHomeScreenState();
}

class _UniHomeScreenState extends State<UniHomeScreen> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays(
        [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    curPage = UniHomeScreen();
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        statusBarColor: Colors.black.withOpacity(0.3),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        drawer: NavDrawer(),
        appBar: HomeAppBar(),
        body: DashBoard(user: universityglobals.user),
      ),
    );
  }
}

class UniLandingPage extends StatefulWidget {
  @override
  _UniLandingPageState createState() => _UniLandingPageState();
}

class _UniLandingPageState extends State<UniLandingPage> {
  GlobalKey<ScaffoldState> _scafKey = GlobalKey<ScaffoldState>();
  Future status;

  @override
  void initState() {
    super.initState();
    status = getApprovalStatus();
  }

  Future<void> getApprovalStatus() async {
    String tok = await getToken();
    final response = await http.post(
      dom + 'api/university/approval-status',
      headers: {
        HttpHeaders.authorizationHeader: 'Token $tok',
      },
    );
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['Response']) {
        Navigator.of(context).pushAndRemoveUntil(
          PageTransition(type: PageTransitionType.fade, child: UniHomeScreen()),
          (Route<dynamic> route) => false,
        );
      } else {
        return false;
      }
    } else {
      throw ('error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scafKey,
      backgroundColor: Colors.white,
      body: FutureBuilder(
        future: status,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Icon(Icons.error);
          }
          if (snapshot.hasData) {
            if (!snapshot.data) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 150, right: 20, left: 8),
                    child: Image.asset(
                      'images/CollegeGenieLogo-2.png',
                      height: 175,
                      width: 200,
                      fit: BoxFit.contain,
                      colorBlendMode: BlendMode.darken,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: Text(
                      'Hey, ${universityglobals.user.firstname}!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                          fontSize: 25),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 8, left: 30, right: 30),
                    child: Text(
                      'Kindly wait as our team approves your\nsubmitted profile.\nWe greatly appreciate your patience.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w300,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 70, left: 100, right: 100),
                    child: OutlineButton(
                      borderSide: BorderSide(color: Color(0xff005fa8)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        child: Text(
                          'Sign Out',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w400),
                        ),
                      ),
                      onPressed: () async {
                        try {
                          final directory =
                              await getApplicationDocumentsDirectory();
                          final file = File('${directory.path}/tok.txt');
                          file.delete();
                          universityglobals.user = null;
                        } catch (_) {
                          print('Error');
                        }
                        Navigator.pop(context);
                        Navigator.of(context).pushAndRemoveUntil(
                            logoutRoute(), (route) => false);
                      },
                    ),
                  ),
                  Spacer(),
                  Padding(
                    padding: EdgeInsets.only(bottom: 60),
                    child: Container(
                      alignment: Alignment.topRight,
                      height: 25,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "Been waiting for too long? ",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black54,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              splashColor: Color(0xff005fa8),
                              onTap: () async {
                                if (await canLaunch(
                                    'mailto:help@collegegenie.org')) {
                                  launch('mailto:help@collegegenie.org');
                                } else {
                                  await ClipboardManager.copyToClipBoard(
                                      'help@collegegenie.org');
                                  _scafKey.currentState.showSnackBar(
                                    SnackBar(
                                        content: Text(
                                      'Unable to open mail. Email copied to clipboard.',
                                      textAlign: TextAlign.center,
                                    )),
                                  );
                                }
                              },
                              child: Text(
                                'Email Us',
                                style: TextStyle(
                                  fontSize: 15,
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
              );
            }
          }
          return Padding(
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
          );
        },
      ),
    );
  }
}
