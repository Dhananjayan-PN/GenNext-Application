import 'package:flutter/material.dart';
import 'main.dart';

class HomeScreen extends StatelessWidget {
  // This widget defines the homepage of the application
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.grey[250],
      drawer: NavDrawer(),
      appBar: AppBar(
        title: Image(
          image: AssetImage('images/gennextlonglogo.png'),
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
