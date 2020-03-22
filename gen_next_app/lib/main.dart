import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          title: Text('GenNext'),
          leading: IconButton(
            icon: Icon(Icons.arrow_drop_down_circle),
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
