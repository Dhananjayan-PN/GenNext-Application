import 'package:flutter/material.dart';

final notifications = ['You are late', 'you are a loser'];

int newNotifications = notifications.length;

class BodyBuilder extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => BodyBuilderState();
}

class BodyBuilderState extends State<BodyBuilder> {
  @override
  Widget build(BuildContext context) {
    if (notifications.length == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.sentiment_satisfied,
              size: 45,
            ),
            Text(' '),
            Text(
              "You're all caught up !",
              style: TextStyle(color: Colors.grey[800], fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    } else {
      return ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: Key('$index' + '$notifications[index]'),
            background: Container(child: Icon(Icons.delete), color: Colors.red[400]),
            child: ListTile(
              title: Text(notifications[index]),
            ),
            onDismissed: (direction) {
              notifications.removeAt(index);
              setState(() {});
              //Scaffold.of(context).showSnackBar(SnackBar(content: Text("Notification Dismissed"),),);
            },
          );
        },
      );
    }
  }
}

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
        body: BodyBuilder());
  }
}
