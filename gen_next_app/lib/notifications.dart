import 'package:flutter/material.dart';
import 'main.dart';

final notifications = ["App is under development. Come back soon!"];

class NotificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        backgroundColor: Colors.grey[250],
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(
                Icons.keyboard_backspace,
                color: Colors.indigo[900],
              ),
              onPressed: () {
                Navigator.pop(context);
              }),
          title: Text(
            'Notifications',
            style: TextStyle(color: Colors.black, fontSize: 20),
          ),
          backgroundColor: Colors.cyanAccent[400],
          iconTheme: new IconThemeData(color: Colors.indigo[900]),
        ),
        body: ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            return Card(
              child: ListTile(
                title: Text(notifications[index]),
              ),
            );
          },
        ));
  }
}
