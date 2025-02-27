import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;
import 'landingpage.dart';

void main() {
  initializeDateFormatting().then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MaterialApp(
      theme: Platform.isAndroid
          ? ThemeData(
              fontFamily: 'Roboto',
              primaryColor: Color(0xff005fa8),
              accentColor: Color(0xff005fa8),
            )
          : ThemeData(
              primaryColor: Color(0xff005fa8),
              accentColor: Color(0xff005fa8),
            ),
      home: LandingPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
