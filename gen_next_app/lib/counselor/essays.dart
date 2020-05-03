import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'home.dart';

class EssayScreen extends StatefulWidget {
  @override
  _EssayScreenState createState() => _EssayScreenState();
}

class _EssayScreenState extends State<EssayScreen> {
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
            child: CounselorHomeScreen(user: newUser)));
    return true;
  }

  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.white,
      drawer: NavDrawer(
          name: newUser.firstname + ' ' + newUser.lastname,
          email: newUser.email),
      appBar: CustomAppBar('Essays'),
      body: Center(child: Text('Essays')),
    );
  }
}
