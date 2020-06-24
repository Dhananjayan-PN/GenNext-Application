import 'package:flutter/material.dart';
import 'package:gennextapp/student/allunis.dart';
import 'package:page_transition/page_transition.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:badges/badges.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../shimmer_skeleton.dart';
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
  GlobalKey<ScaffoldState> _scafKey = GlobalKey<ScaffoldState>();
  final User user;
  _DashBoardState({this.user});

  Future recommendedUnis;

  @override
  void initState() {
    super.initState();
    recommendedUnis = getRecommendedUnis();
  }

  Color colorPicker(double rating) {
    if (0 <= rating && rating < 30) {
      return Colors.red;
    } else if (30 <= rating && rating < 60) {
      return Colors.orange;
    } else if (60 <= rating && rating < 80) {
      return Colors.yellow;
    } else if (80 <= rating && rating <= 100) {
      return Colors.green;
    } else {
      return Colors.white;
    }
  }

  Future<void> getRecommendedUnis() async {
    final response = await http.get(
      dom + 'api/student/recommend-universities',
      headers: {HttpHeaders.authorizationHeader: "Token $tok"},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body)['recommended_universities'];
    } else {
      throw 'failed';
    }
  }

  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 20, top: 20),
          child: Text(
            'Hello,',
            style: TextStyle(color: Colors.black45, fontSize: 25),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 20),
          child: Text(
            '${user.firstname}',
            style: TextStyle(color: Colors.black87, fontSize: 25),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 30, left: 20, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                'Recommended Universities',
                style: TextStyle(color: Colors.black87, fontSize: 18.5),
              ),
              Spacer(),
              InkWell(
                child: Text(
                  'See all',
                  style: TextStyle(color: Colors.blue, fontSize: 15),
                ),
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    PageTransition(
                        type: PageTransitionType.fade,
                        child: AllUniversitiesScreen()),
                    (Route<dynamic> route) => false,
                  );
                },
              ),
            ],
          ),
        ),
        FutureBuilder(
          future: recommendedUnis.timeout(Duration(seconds: 10)),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                elevation: 10,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.error_outline,
                        size: 30,
                        color: Colors.red.withOpacity(0.9),
                      ),
                      Text(
                        'Unable to establish a connection with our servers.\nCheck your connection and try again later.',
                        style: TextStyle(color: Colors.black54),
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                ),
              );
            }
            if (snapshot.hasData) {
              if (snapshot.data.length == 0) {
                return Padding(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: Card(
                    margin: EdgeInsets.only(top: 20, bottom: 30),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15))),
                    elevation: 10,
                    child: Padding(
                      padding: EdgeInsets.only(top: 20, bottom: 30),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.sentiment_neutral,
                            size: 40,
                          ),
                          Text(
                            "No recommendations at the moment",
                            style: TextStyle(color: Colors.black54),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            "Head over to the Explore section to\nexplore universities",
                            style: TextStyle(color: Colors.black54),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                return Container(
                  height: 270,
                  child: Swiper(
                    loop: snapshot.data.length == 1 ? false : true,
                    itemCount: snapshot.data.length,
                    viewportFraction: 0.87,
                    scale: 0.9,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        margin: EdgeInsets.only(top: 20, bottom: 30),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        elevation: 10,
                        child: CachedNetworkImage(
                          imageUrl:
                              "https://www.wpr.org/sites/default/files/bascom_hall_summer.jpg",
                          placeholder: (context, url) => CardSkeleton(
                            padding: 0,
                            isBottomLinesActive: false,
                          ),
                          errorWidget: (context, url, error) {
                            _scafKey.currentState.showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Failed to fetch data. Check your internet connection and try again',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                            return Icon(Icons.error);
                          },
                          imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                alignment: Alignment.center,
                                colorFilter: ColorFilter.mode(
                                    Colors.black.withAlpha(140),
                                    BlendMode.darken),
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(top: 12, right: 13),
                                  child: Row(
                                    children: <Widget>[
                                      Spacer(),
                                      CircularPercentIndicator(
                                        footer: Text('Match',
                                            style: TextStyle(
                                                color: Colors.white
                                                    .withOpacity(0.8),
                                                fontSize: 10)),
                                        radius: 45.0,
                                        lineWidth: 2.5,
                                        animation: true,
                                        percent: snapshot.data[index]
                                                ["match_rating"] /
                                            100,
                                        center: Text(
                                          " ${snapshot.data[index]["match_rating"].toString().substring(0, 4)}%",
                                          style: TextStyle(
                                              color:
                                                  Colors.white.withOpacity(0.8),
                                              fontSize: 11.5),
                                        ),
                                        circularStrokeCap:
                                            CircularStrokeCap.round,
                                        backgroundColor: Colors.transparent,
                                        progressColor: colorPicker(snapshot
                                            .data[index]["match_rating"]),
                                      ),
                                    ],
                                  ),
                                ),
                                Spacer(),
                                Padding(
                                  padding: EdgeInsets.only(left: 15),
                                  child: Text(
                                    snapshot.data[index]['university_name'],
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.only(bottom: 14, left: 15),
                                  child: Text(
                                    snapshot.data[index]['university_location'],
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
            }
            return Container(
                height: 200, child: Center(child: CircularProgressIndicator()));
          },
        ),
      ],
    );
  }
}
