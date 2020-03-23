import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MaterialApp(home: new HomeScreen());
  }
}

class HomeScreen extends StatelessWidget {
  // This widget defines the homepage of the application
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.grey[250],
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            new UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Colors.cyanAccent[400]),
              accountName: new Text("Jake Adams",
                  style: TextStyle(color: Colors.black, fontSize: 18)),
              accountEmail: new Text("jake.adams@gmail.com",
                  style: TextStyle(color: Colors.black, fontSize: 12)),
              currentAccountPicture: CircleAvatar(
                backgroundImage: AssetImage('images/profile.png'),
                backgroundColor: Colors.cyan[50],
                radius: 30,
              ),
              onDetailsPressed: () {}, //Take to Profile Page...implement later
            ),
            ListTile(
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  new MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              },
            ),
            ListTile(
              title: Text('Your Profile'),
              onTap: () {
                // Update the state of the app.
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Your Universities'),
              onTap: () {
                // Update the state of the app.
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Completed Applications'),
              onTap: () {
                // Update the state of the app.
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Pending Applications'),
              onTap: () {
                // Update the state of the app.
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Counselling Schedule'),
              onTap: () {
                // Update the state of the app.
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Sign Out'),
              onTap: () {
                // Update the state of the app.
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Image(
          image: AssetImage('images/gennextlonglogo.png'),
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

//class ProfileScreen extends StatelessWidget {}

//class YourUniversitiesScreen extends StatelessWidget {}

//class CompletedApplicationsScreen extends StatelessWidget {}

//class PendingApplicationsScreen extends StatelessWidget {}

//class ScheduleScreen extends StatelessWidget {}
