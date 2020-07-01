import 'package:flutter/material.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';

class UniversityPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: GradientAppBar(
        title: Text(
          'New Application',
          maxLines: 1,
          style: TextStyle(color: Colors.white),
        ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xff00AEEF), Color(0xff0072BC)],
        ),
      ),
    );
  }
}
