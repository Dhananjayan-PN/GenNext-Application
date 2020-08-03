import '../imports.dart';
import '../login.dart';
import '../landingpage.dart';
import '../usermodel.dart';
import 'chat.dart';
import 'dashboard.dart';
import 'notifications.dart';
import 'essays.dart';
import 'profile.dart';
import 'documents.dart';
import 'myuniversities.dart';
import 'scores.dart';
import 'allunis.dart';
import 'applications.dart';
import 'counselor.dart';
import 'schedule.dart';

User newUser;
String dom = domain;
Widget curPage;
PageController _controller;

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
  final String name;
  final String email;
  final User user;
  NavDrawer({this.user, this.name, this.email});

  @override
  _NavDrawerState createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  @override
  Widget build(BuildContext context) {
    final navlistelements = [
      ['Home', StudentHomeScreen(user: widget.user), Icons.home],
      ['Counselling', CounsellingScreen(), Icons.people],
      ['Schedule', ScheduleScreen(), Icons.date_range],
      ['Explore Universities', AllUniversitiesScreen(), Icons.explore],
      ['My Profile', ProfileScreen(), Icons.account_box],
      ['My Universities', MyUniversitiesScreen(), Icons.account_balance],
      ['My Applications', ApplicationsScreen(), Icons.assignment],
      ['My Essays', EssaysScreen(), Icons.edit],
      ['My Test Scores', TestScoresScreen(), Icons.assessment],
      ['My Documents', DocumentsScreen(), Icons.description],
    ];
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
            height: 195,
            child: UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Color(0xff005fa8)),
              accountName: Text(widget.name,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w400)),
              accountEmail: Text(widget.email,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w300)),
              currentAccountPicture: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(newUser.dp),
                backgroundColor: Colors.blue[800],
                radius: 30,
              ),
              onDetailsPressed: () {
                Navigator.pop(context);
                curPage = ProfileScreen();
                Navigator.pushAndRemoveUntil(
                  context,
                  PageTransition(
                      type: PageTransitionType.fade, child: ProfileScreen()),
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
  int counter = notifications.length;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 6,
      title: Text('Home'),
      backgroundColor: Color(0xff005fa8),
      actions: <Widget>[
        Stack(
          children: <Widget>[
            IconButton(
                icon: Icon(Icons.notifications, size: 28),
                alignment: Alignment.bottomLeft,
                onPressed: () {
                  Navigator.push(
                      context,
                      PageTransition(
                          type: PageTransitionType.fade,
                          child: NotificationScreen()));
                }),
            counter != 0
                ? Positioned(
                    right: 11,
                    top: 11,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 14,
                        minHeight: 14,
                      ),
                      child: Text(
                        '$counter',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : Container()
          ],
        ),
        IconButton(
          icon: Icon(Icons.chat, size: 28),
          onPressed: () {
            setState(
              () {
                _controller.animateToPage(1,
                    duration: Duration(milliseconds: 600),
                    curve: Curves.easeInOut);
              },
            );
          },
        )
      ],
    );
  }
}

class StudentHomeScreen extends StatefulWidget {
  final User user;
  StudentHomeScreen({this.user});
  @override
  _StudentHomeScreenState createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  @override
  void initState() {
    super.initState();
    _controller = PageController(
      initialPage: 0,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays(
        [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    curPage = StudentHomeScreen(user: widget.user);
    newUser = widget.user;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        statusBarColor: Colors.black.withOpacity(0.3),
      ),
      child: PageView(
        controller: _controller,
        children: [
          Scaffold(
            backgroundColor: Colors.white,
            drawer: NavDrawer(
              user: widget.user,
              name: '${widget.user.firstname} ${widget.user.lastname}',
              email: widget.user.email,
            ),
            appBar: HomeAppBar(),
            body: DashBoard(user: widget.user),
          ),
          AllChats(pgcontroller: _controller)
        ],
      ),
    );
  }
}
