import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.blueGrey,
        appBar: AppBar(
          title: Center(
            child: Text("GenNext Application"),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_drop_down_circle),
            color: Colors.black87,
            onPressed: () {},
          ),
          backgroundColor: Colors.blueAccent,
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
