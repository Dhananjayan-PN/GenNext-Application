import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/services.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../login.dart';
import '../main.dart';
import '../usermodel.dart';
import 'dashboard.dart';
import 'notifications.dart';
import 'mystudents.dart';
import 'chat.dart';
import 'essays.dart';
import 'myuniversities.dart';
import 'profile.dart';
import 'schedule.dart';
import 'connectwithunis.dart';

User newUser;
String tok = token;
String dom = domain;
Widget curPage = CounselorHomeScreen(user: newUser);
PageController _controller;
final navlistelements = [
  ['Home', CounselorHomeScreen(user: newUser), Icons.home],
  ['My Students', MyStudentsScreen(), Icons.group],
  ['Essays', EssaysScreen(), Icons.edit],
  ['My Profile', ProfileScreen(), Icons.account_box],
  ['Sessions Calendar', ScheduleScreen(), Icons.date_range],
  ['My Universities', MyUniversitiesScreen(), Icons.account_balance],
  ['Connect with Universities', ConnectUniversitiesScreen(), Icons.link]
];

loading(context) {
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

success(context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        contentPadding: EdgeInsets.all(0),
        elevation: 20,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
        content: Container(
          height: 150,
          width: 80,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
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
                    'Message successfully delivered!\nRespective individuals will be notified',
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

error(context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        contentPadding: EdgeInsets.all(0),
        elevation: 20,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
        content: Container(
          height: 150,
          width: 80,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
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
                    'Unable to establish a connection with our servers.\nCheck your connection and try again later.',
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

class NavDrawer extends StatelessWidget {
  final String name;
  final String email;
  NavDrawer({this.name, this.email});

  @override
  Widget build(BuildContext context) {
    List<Widget> navlist = [];
    for (var i = 0; i < navlistelements.length; i++) {
      var element = navlistelements[i];
      navlist.add(ListTile(
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
          if (curPage == element[1]) {
          } else {
            curPage = element[1];
            Navigator.pushAndRemoveUntil(
              context,
              PageTransition(type: PageTransitionType.fade, child: element[1]),
              (Route<dynamic> route) => false,
            );
          }
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
              backgroundImage: CachedNetworkImageProvider(newUser.dp),
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
                          padding: EdgeInsets.only(left: 5, right: 5, top: 10),
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
                        Navigator.of(context).pushAndRemoveUntil(
                            logoutRoute(), (route) => false);
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
  int counter = notifications.length;

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

class CounselorHomeScreen extends StatefulWidget {
  final User user;
  CounselorHomeScreen({this.user});
  // This widget defines the homepage of the application
  @override
  _CounselorHomeScreenState createState() =>
      _CounselorHomeScreenState(user: user);
}

class _CounselorHomeScreenState extends State<CounselorHomeScreen> {
  final User user;
  _CounselorHomeScreenState({this.user});

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
          AllChats(pgcontroller: _controller)
        ],
      ),
    );
  }
}
