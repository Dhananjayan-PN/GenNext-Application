import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'login.dart';
import 'home.dart';
import 'schedule.dart';

final name = 'Jake Adams';
final emailid = 'jake.adams!gmail.com';
final navlistelements = [
  ['Home', HomeScreen()],
  ['Your Profile', ProfileScreen()],
  ['Your Universities', YourUniversitiesScreen()],
  ['Completed Applications', CompletedApplicationsScreen()],
  ['Pending Applications', PendingApplicationsScreen()],
  ['Counselling Schedule', ScheduleScreen()]
];

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MaterialApp(home: new LoginPage());
  }
}

class NavDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<Widget> navlist = [];
    for (var i = 0; i < navlistelements.length; i++) {
      var element = navlistelements[i];
      navlist.add(
        new ListTile(
          title: Text(element[0]),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(context,
                new MaterialPageRoute(builder: (context) => element[1]));
          },
        ),
      );
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          new UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Colors.cyanAccent[400]),
            accountName: new Text(name,
                style: TextStyle(color: Colors.black, fontSize: 18)),
            accountEmail: new Text(emailid,
                style: TextStyle(color: Colors.black, fontSize: 12)),
            currentAccountPicture: CircleAvatar(
              backgroundImage: AssetImage('images/profile.png'),
              backgroundColor: Colors.cyan[50],
              radius: 30,
            ),
            onDetailsPressed: () {
              Navigator.pop(context);
              Navigator.push(context,
                  new MaterialPageRoute(builder: (context) => ProfileScreen()));
            }, //Take to Profile Page...implement later
          ),
          new Column(children: navlist),
          new ListTile(
            title: Text('Sign Out'),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) => CustomDialog(
                  title: "Sign Out",
                  description: "Are you sure you want to sign out?",
                  buttonText: "Okay",
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

//Following two classes are for the custom dialog screen that can be used for any dialog
class Consts {
  Consts._();

  static const double padding = 16.0;
  static const double avatarRadius = 66.0;
}

class CustomDialog extends StatelessWidget {
  final String title, description, buttonText;
  final Image image;

  CustomDialog({
    @required this.title,
    @required this.description,
    @required this.buttonText,
    this.image,
  });

  dialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(
            top: Consts.avatarRadius + Consts.padding,
            bottom: Consts.padding,
            left: Consts.padding,
            right: Consts.padding,
          ),
          margin: EdgeInsets.only(top: Consts.avatarRadius),
          decoration: new BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(Consts.padding),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: const Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // To make the card compact
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
              SizedBox(height: 24.0),
              Align(
                alignment: Alignment.bottomRight,
                child: FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                        context,
                        new MaterialPageRoute(
                            builder: (context) => LoginPage()));
                  },
                  child: Text(buttonText),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Consts.padding),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.grey[250],
      drawer: NavDrawer(),
      appBar: AppBar(
        title: Text(
          'Your Profile',
          style: TextStyle(color: Colors.black, fontSize: 20),
        ),
        backgroundColor: Colors.cyanAccent[400],
        iconTheme: new IconThemeData(color: Colors.black),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.notifications),
            color: Colors.black87,
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image(
              image: AssetImage('images/doggo.png'),
            ),
            Text(
              'Our Application is under development\nCome back soon!',
              style: TextStyle(color: Colors.black, fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class YourUniversitiesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.grey[250],
      drawer: NavDrawer(),
      appBar: AppBar(
        title: Text(
          'Your Universities',
          style: TextStyle(color: Colors.black, fontSize: 20),
        ),
        backgroundColor: Colors.cyanAccent[400],
        iconTheme: new IconThemeData(color: Colors.black),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.notifications),
            color: Colors.black87,
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image(
              image: AssetImage('images/doggo.png'),
            ),
            Text(
              'Our Application is under development\nCome back soon!',
              style: TextStyle(color: Colors.black, fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class CompletedApplicationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.grey[250],
      drawer: NavDrawer(),
      appBar: AppBar(
        title: Text(
          'Completed Applications',
          style: TextStyle(color: Colors.black, fontSize: 20),
        ),
        backgroundColor: Colors.cyanAccent[400],
        iconTheme: new IconThemeData(color: Colors.black),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.notifications),
            color: Colors.black87,
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image(
              image: AssetImage('images/doggo.png'),
            ),
            Text(
              'Our Application is under development\nCome back soon!',
              style: TextStyle(color: Colors.black, fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class PendingApplicationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.grey[250],
      drawer: NavDrawer(),
      appBar: AppBar(
        title: Text(
          'Pending Applications',
          style: TextStyle(color: Colors.black, fontSize: 20),
        ),
        backgroundColor: Colors.cyanAccent[400],
        iconTheme: IconThemeData(color: Colors.black),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.notifications),
            color: Colors.black87,
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image(
              image: AssetImage('images/doggo.png'),
            ),
            Text(
              'Our Application is under development\nCome back soon!',
              style: TextStyle(color: Colors.black, fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
