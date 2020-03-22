import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.grey[250],
        appBar: AppBar(
          title: Image(
            image: AssetImage('images/gennextlonglogo.png'),
          ),
          leading: IconButton(
            icon: Icon(Icons.view_headline),
            color: Colors.black,
            onPressed: () {},
          ),
          backgroundColor: Colors.cyanAccent[400],
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
      ),
    ),
  );
}
