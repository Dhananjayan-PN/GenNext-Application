import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:io' show Platform;
import 'login.dart';

String token;
String domain = "https://gennext.ml/";

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
      theme: Platform.isAndroid ? ThemeData(fontFamily: 'Roboto') : null,
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
