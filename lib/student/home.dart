import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/services.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../login.dart';
import '../main.dart';
import '../usermodel.dart';
import 'chat.dart';
import 'dashboard.dart';
import 'notifications.dart';
import 'profile.dart';
import 'myuniversities.dart';
import 'completedapps.dart';
import 'pendingapps.dart';
import 'schedule.dart';

User newUser;
String tok = token;
final navlistelements = [
  ['Home', StudentHomeScreen(user: newUser), Icons.home],
  ['My Profile', ProfileScreen(), Icons.account_box],
  ['My Universities', MyUniversitiesScreen(), Icons.account_balance],
  [
    'Completed Applications',
    CompletedApplicationsScreen(),
    Icons.assignment_turned_in
  ],
  ['Pending Applications', PendingApplicationsScreen(), Icons.assignment_late],
  ['Counselling Schedule', ScheduleScreen(), Icons.date_range]
];
PageController _controller;

class NavDrawer extends StatelessWidget {
  final String name;
  final String email;
  NavDrawer({this.name, this.email});

  @override
  Widget build(BuildContext context) {
    List<Widget> navlist = [];
    for (var i = 0; i < navlistelements.length; i++) {
      var element = navlistelements[i];
      navlist.add(new ListTile(
        leading: Icon(
          element[2],
          size: 26,
          color: Color(0xff00AEEF),
        ),
        title: Text(
          element[0],
          style: TextStyle(color: Colors.black, fontSize: 16.5),
        ),
        onTap: () {
          Navigator.pop(context);
          Navigator.pushAndRemoveUntil(
            context,
            PageTransition(type: PageTransitionType.fade, child: element[1]),
            (Route<dynamic> route) => false,
          );
        },
      ));
      navlist.add(
        Divider(),
      );
    }
    return Drawer(
      elevation: 20,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0xff00AEEF), Color(0xff0072BC)]),
            ),
            accountName:
                Text(name, style: TextStyle(color: Colors.white, fontSize: 18)),
            accountEmail: Text(email,
                style: TextStyle(color: Colors.white, fontSize: 12)),
            currentAccountPicture: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(
                  'https://www.pngfind.com/pngs/m/610-6104451_image-placeholder-png-user-profile-placeholder-image-png.png'),
              backgroundColor: Colors.blue[400],
              radius: 30,
            ),
            onDetailsPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                PageTransition(
                    type: PageTransitionType.fade, child: ProfileScreen()),
                (Route<dynamic> route) => false,
              );
            },
          ),
          Column(mainAxisSize: MainAxisSize.min, children: navlist),
          ListTile(
            leading: Icon(Icons.power_settings_new,
                size: 26, color: Colors.red[600]),
            title: Text('Sign Out',
                style: TextStyle(color: Colors.black, fontSize: 16.5)),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  contentPadding: EdgeInsets.all(0),
                  elevation: 20,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0))),
                  content: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: Icon(
                            Icons.power_settings_new,
                            size: 40,
                            color: Colors.red.withOpacity(0.9),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Text(
                            'Are you sure you want to sign out?',
                            style: TextStyle(color: Colors.black),
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
                        style: TextStyle(color: Colors.blue),
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
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushAndRemoveUntil(
                          context,
                          PageTransition(
                              type: PageTransitionType.upToDown,
                              child: LoginPage()),
                          (Route<dynamic> route) => false,
                        );
                      },
                    ),
                  ],
                ),
              );
            },
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
    return GradientAppBar(
      elevation: 20,
      title: Text(
        titletext,
        style: TextStyle(color: Colors.white, fontSize: 20),
      ),
      gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xff00AEEF), Color(0xff0072BC)]),
    );
  }
}

class HomeAppBar extends StatefulWidget with PreferredSizeWidget {
  @override
  State<StatefulWidget> createState() => HomeAppBarState();
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class HomeAppBarState extends State<HomeAppBar> {
  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent) {
    return true;
  }

  int counter = notifications.length;
  @override
  Widget build(BuildContext context) {
    return GradientAppBar(
      title: Container(
        margin: EdgeInsets.only(left: 0, top: 3, bottom: 3),
        child: Image.asset('images/gennextlonglogo-4.png'),
      ),
      gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xff00AEEF), Color(0xff0072BC)]),
      actions: <Widget>[
        Stack(
          children: <Widget>[
            IconButton(
                icon: Icon(Icons.notifications, size: 28),
                alignment: Alignment.bottomLeft,
                onPressed: () {
                  setState(() {
                    Navigator.push(
                        context,
                        PageTransition(
                            curve: Curves.ease,
                            duration: Duration(milliseconds: 500),
                            type: PageTransitionType.rightToLeft,
                            child: NotificationScreen()));
                  });
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
                    duration: Duration(milliseconds: 600), curve: Curves.ease);
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
  // This widget defines the homepage of the application
  @override
  _StudentHomeScreenState createState() => _StudentHomeScreenState(user: user);
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  final User user;
  _StudentHomeScreenState({this.user});

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
    newUser = user;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        statusBarColor: Color(0xff0072BC).withAlpha(150),
      ),
      child: PageView(
        controller: _controller,
        children: [
          Scaffold(
              backgroundColor: Colors.white,
              drawer: NavDrawer(
                name: '${user.firstname} ${user.lastname}',
                email: user.email,
              ),
              appBar: HomeAppBar(),
              body: DashBoard(user: user)),
          AllChats()
        ],
      ),
    );
  }
}
