import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'home.dart';

final notifications = ['Are you future ready?'];

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
              Icons.thumb_up,
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
      return Center(
        child: Column(
          children: <Widget>[
            ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: Key('$index' + '$notifications[index]'),
                  background: Container(
                      child: Icon(Icons.delete), color: Colors.red[400]),
                  child: Card(
                    elevation: 8,
                    child: InkWell(
                      splashColor: Colors.cyan[400],
                      onTap: () {
                        //Take to the page containing information regarding notification
                      },
                      child: ListTile(
                        title: Text(notifications[index]),
                      ),
                    ),
                  ),
                  onDismissed: (direction) {
                    notifications.removeAt(index);
                    setState(() {});
                    Scaffold.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Notification Dismissed",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            Text(
              '\nSwipe on a notification to dismiss',
              style: TextStyle(fontSize: 11, color: Colors.black.withAlpha(99)),
              textAlign: TextAlign.center,
            )
          ],
        ),
      );
    }
  }
}

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent) {
    print("BACK BUTTON!");
    Navigator.push(
        context,
        PageTransition(
            duration: Duration(milliseconds: 500),
            type: PageTransitionType.leftToRight,
            child: CounselorHomeScreen(
              user: newUser,
            )));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: GradientAppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                PageTransition(
                  duration: Duration(milliseconds: 500),
                  type: PageTransitionType.leftToRightWithFade,
                  child: CounselorHomeScreen(user: newUser),
                ),
              );
            },
          ),
          title: Text(
            'Notifications',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xff00AEEF), Color(0xff0072BC)]),
        ),
        body: BodyBuilder());
  }
}
