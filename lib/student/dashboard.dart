import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'schedule.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'dart:async';
import 'dart:convert';
import '../usermodel.dart';
import 'dart:io';
import 'home.dart';

class DashBoard extends StatefulWidget {
  final User user;
  DashBoard({this.user});

  @override
  _DashBoardState createState() => _DashBoardState(user: user);
}

class _DashBoardState extends State<DashBoard> {
  final User user;
  _DashBoardState({this.user});

  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text('@' + user.username),
      ),
    );
  }
}
