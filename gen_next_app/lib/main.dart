import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'login.dart';
import 'home.dart';
import 'schedule.dart';

final name = 'Jake Adams';
final emailid = 'jake.adams@gmail.com';
final navlistelements = [
  ['Home', HomeScreen(), Icons.home],
  ['Your Profile', ProfileScreen(), Icons.account_box],
  ['Your Universities', YourUniversitiesScreen(), Icons.account_balance],
  ['Completed Applications', CompletedApplicationsScreen(), Icons.assignment_turned_in],
  ['Pending Applications', PendingApplicationsScreen(), Icons.assignment_late],
  ['Counselling Schedule', ScheduleScreen(), Icons.date_range]
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
      navlist.add(new ListTile(
        leading: Icon(
          element[2],
          size: 26,
          color: Colors.indigo[900],
        ),
        title: Text(
          element[0],
          style: TextStyle(color: Colors.black, fontSize: 16.5),
        ),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(context, new MaterialPageRoute(builder: (context) => element[1]));
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
            decoration: BoxDecoration(color: Colors.cyanAccent[400]),
            accountName: new Text(name, style: TextStyle(color: Colors.black, fontSize: 18)),
            accountEmail: new Text(emailid, style: TextStyle(color: Colors.black, fontSize: 12)),
            currentAccountPicture: CircleAvatar(
              backgroundImage: AssetImage('images/profile.png'),
              backgroundColor: Colors.cyan[50],
              radius: 30,
            ),
            onDetailsPressed: () {
              Navigator.pop(context);
              Navigator.push(context, new MaterialPageRoute(builder: (context) => ProfileScreen()));
            }, //Take to Profile Page...implement later
          ),
          new Column(children: navlist),
          new ListTile(
            leading: Icon(Icons.power_settings_new, size: 26, color: Colors.red[600]),
            title: Text('Sign Out', style: TextStyle(color: Colors.black, fontSize: 16.5)),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) => CustomDialog(
                  title: "Sign Out ?",
                  description: "Are you sure you want to sign out?\nTap outside the box to stay back",
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
  @override
  CustomAppBar(this.titletext);
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        titletext,
        style: TextStyle(color: Colors.black, fontSize: 20),
      ),
      backgroundColor: Colors.cyanAccent[400],
      iconTheme: new IconThemeData(color: Colors.indigo[900]),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.notifications),
          color: Colors.indigo[900],
          onPressed: () {},
        ),
      ],
    );
  }
}

//Following class is for the custom dialog screen that can be used from anywhere

class CustomDialog extends StatelessWidget {
  final String title, description, buttonText;

  CustomDialog({
    @required this.title,
    @required this.description,
    @required this.buttonText,
  });

  dialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(
            top: 24,
            bottom: 16,
            left: 16,
            right: 16,
          ),
          decoration: new BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(16),
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
                  shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(9.0), side: BorderSide(color: Colors.cyan[600])),
                  color: Colors.cyanAccent[400],
                  splashColor: Colors.blueAccent,
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(context, new MaterialPageRoute(builder: (context) => LoginPage()));
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
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.cyan[600]),
      ),
      elevation: 2.0,
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
      appBar: CustomAppBar('Your Profile'),
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
      appBar: CustomAppBar('Your Universities'),
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
      appBar: CustomAppBar('Completed Applications'),
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
      appBar: CustomAppBar('Pending Application'),
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
