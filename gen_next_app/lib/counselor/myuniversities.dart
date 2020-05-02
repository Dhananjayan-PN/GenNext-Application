import 'package:flutter/material.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:page_transition/page_transition.dart';
import 'home.dart';

class MyUniversitiesScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyUniversitiesScreenState();
}

class MyUniversitiesScreenState extends State<MyUniversitiesScreen> {
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
            type: PageTransitionType.fade,
            child: CounselorHomeScreen(
              username: uname,
            )));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.grey[250],
      drawer: NavDrawer(uname: uname),
      appBar: CustomAppBar('My Universities'),
      body: Center(child: Text('Universities')),
    );
  }
}
