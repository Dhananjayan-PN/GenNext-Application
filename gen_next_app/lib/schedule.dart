import 'package:flutter/material.dart';
import 'main.dart';

class ScheduleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.grey[250],
      drawer: NavDrawer(),
      appBar: AppBar(
        title: Text(
          'Counselling Schedule',
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
