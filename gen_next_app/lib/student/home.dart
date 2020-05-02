import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/services.dart';
import '../main.dart';
import 'notifications.dart';
import 'profile.dart';
import 'youruniversities.dart';
import 'completedapps.dart';
import 'pendingapps.dart';
import 'schedule.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';

String uname;

final navlistelements = [
  ['Home', StudentHomeScreen(), Icons.home],
  ['Your Profile', ProfileScreen(), Icons.account_box],
  ['Your Universities', YourUniversitiesScreen(), Icons.account_balance],
  [
    'Completed Applications',
    CompletedApplicationsScreen(),
    Icons.assignment_turned_in
  ],
  ['Pending Applications', PendingApplicationsScreen(), Icons.assignment_late],
  ['Counselling Schedule', ScheduleScreen(), Icons.date_range]
];

class NavDrawer extends StatelessWidget {
  final String uname;
  final String email;
  NavDrawer({this.uname, this.email});

  @override
  Widget build(BuildContext context) {
    List<Widget> navlist = [];
    for (var i = 0; i < navlistelements.length; i++) {
      var element = navlistelements[i];
      navlist.add(new ListTile(
        leading: Icon(
          element[2],
          size: 26,
          color: Colors.blue[800],
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
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          new UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0xff00AEEF), Color(0xff0072BC)]),
            ),
            accountName: new Text(uname,
                style: TextStyle(color: Colors.black, fontSize: 18)),
            accountEmail: new Text('email',
                style: TextStyle(color: Colors.black, fontSize: 12)),
            currentAccountPicture: CircleAvatar(
              backgroundImage: AssetImage('images/profile.png'),
              backgroundColor: Colors.blue[200],
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
            }, //Take to Profile Page...implement later
          ),
          new Column(children: navlist),
          new ListTile(
            leading: Icon(Icons.power_settings_new,
                size: 26, color: Colors.red[600]),
            title: Text('Sign Out',
                style: TextStyle(color: Colors.black, fontSize: 16.5)),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) => SignOutDialog(
                  title: "Sign Out ?",
                  description: "Are you sure you want to sign out?",
                  buttonText: "Sign Out",
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
      title: Text(
        titletext,
        style: TextStyle(color: Colors.black, fontSize: 20),
      ),
      gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xff00AEEF), Color(0xff0072BC)]),
      iconTheme: new IconThemeData(color: Colors.indigo[900]),
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
      title: Image(
        image: AssetImage('images/gennextlonglogo.png'),
      ),
      gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xff00AEEF), Color(0xff0072BC)]),
      actions: <Widget>[
        new Stack(
          children: <Widget>[
            new IconButton(
                icon: Icon(Icons.notifications, size: 28),
                alignment: Alignment.bottomLeft,
                onPressed: () {
                  setState(() {
                    Navigator.push(
                        context,
                        PageTransition(
                            type: PageTransitionType.rightToLeft,
                            child: NotificationScreen()));
                  });
                }),
            counter != 0
                ? new Positioned(
                    right: 11,
                    top: 11,
                    child: new Container(
                      padding: EdgeInsets.all(2),
                      decoration: new BoxDecoration(
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
                : new Container()
          ],
        ),
      ],
    );
  }
}

class StudentHomeScreen extends StatefulWidget {
  final String username;
  StudentHomeScreen({this.username});
  // This widget defines the homepage of the application
  @override
  _StudentHomeScreenState createState() =>
      _StudentHomeScreenState(username: username);
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  final String username;
  _StudentHomeScreenState({this.username});

  @override
  Widget build(BuildContext context) {
    uname = username;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        statusBarColor: Color(0xff0072BC).withAlpha(150),
      ),
      child: new Scaffold(
        backgroundColor: Colors.white,
        drawer: NavDrawer(uname: username), //add email here too
        appBar: HomeAppBar(),
        body: Center(child: Text('Hey @' + username + '!')),
      ),
    );
  }
}
