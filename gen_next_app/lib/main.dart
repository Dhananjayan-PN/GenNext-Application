import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          title: Center(
            child: Text("GenNext Application"),
          ),
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
      ),
    ),
  );
}
