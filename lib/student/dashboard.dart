import 'package:flutter/material.dart';
import 'package:gennextapp/student/allunis.dart';
import 'package:page_transition/page_transition.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
// import 'package:badges/badges.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../shimmer_skeleton.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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
  GlobalKey<ScaffoldState> _scafKey = GlobalKey<ScaffoldState>();
  TextEditingController studentnotes = TextEditingController();
  int userId;
  bool saved = false;
  bool saving = true;
  bool savingfailed = false;

  Future recommendedUnis;
  Future upcomingSessions;
  Future studentNotes;

  @override
  void initState() {
    super.initState();
    recommendedUnis = getRecommendedUnis();
    upcomingSessions = getUpcomingSessions();
    studentNotes = getStudentNotes();
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

  Future<void> getUpcomingSessions() async {
    final response =
        await http.get(dom + 'api/student/get-counselor-sessions', headers: {
      HttpHeaders.authorizationHeader: 'Token $tok',
    });
    if (response.statusCode == 200) {
      List sessions = json.decode(response.body)['session_data'];
      List upcoming = [];
      for (var i = 0; sessions.length < 4 ? i < sessions.length : i < 5; i++) {
        upcoming.add(sessions[i]);
      }
      return upcoming;
    } else {
      throw ('error');
    }
  }

  Future<void> getStudentNotes() async {
    saving = true;
    final response = await http.get(dom + 'authenticate/get-notes', headers: {
      HttpHeaders.authorizationHeader: 'Token $tok',
    });
    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      userId = json.decode(response.body)['user_id'];
      if (result['response'] == 'Access Denied.') {
        setState(() {
          saving = false;
          savingfailed = true;
        });
        throw ('error');
      } else {
        setState(() {
          saving = false;
          saved = true;
        });
        String notes = json.decode(response.body)['notes'];
        return notes;
      }
    } else {
      setState(() {
        saving = false;
        savingfailed = true;
      });
      throw ('error');
    }
  }

  Future<void> editStudentNotes() async {
    final response = await http.put(
      dom + 'authenticate/edit-notes',
      headers: {
        HttpHeaders.authorizationHeader: "Token $tok",
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode(
        <String, dynamic>{"user_id": userId, "notes": studentnotes.text},
      ),
    );
    if (response.statusCode == 200) {
      if (json.decode(response.body)['response'] ==
          'Notes Successfuly Updated.') {
        setState(() {
          saving = false;
          saved = true;
        });
      } else {
        setState(() {
          saving = false;
          savingfailed = true;
        });
        _error();
      }
    } else {
      setState(() {
        saving = false;
        savingfailed = true;
      });
      _error();
    }
  }

  _editStudentNotes() {
    setState(() {
      saved = false;
      saving = true;
    });
    editStudentNotes();
  }

  _error() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(0),
          elevation: 20,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          content: Container(
            height: 150,
            width: 80,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.error_outline,
                    size: 40,
                    color: Colors.red.withOpacity(0.9),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(
                      'Unable to establish a connection with our servers.\nCheck your connection and try again later.',
                      style: TextStyle(color: Colors.black, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 20, top: 18),
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
          padding: EdgeInsets.only(top: 20, left: 20, right: 20),
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
                  curPage = AllUniversitiesScreen();
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
              return Padding(
                padding: EdgeInsets.only(left: 25, right: 25),
                child: Card(
                  margin: EdgeInsets.only(top: 20, bottom: 20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  elevation: 6,
                  child: Padding(
                    padding:
                        EdgeInsets.only(left: 5, right: 5, top: 55, bottom: 50),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Icon(
                            Icons.error_outline,
                            size: 35,
                            color: Colors.red.withOpacity(0.75),
                          ),
                        ),
                        Text(
                          'Unable to establish a connection\nwith our servers.\nCheck your connection and try again later.',
                          style: TextStyle(color: Colors.black54),
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  ),
                ),
              );
            }
            if (snapshot.hasData) {
              if (snapshot.data.length == 0) {
                return Padding(
                  padding: EdgeInsets.only(left: 25, right: 25),
                  child: Card(
                    margin: EdgeInsets.only(top: 20, bottom: 25),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    elevation: 6,
                    child: Padding(
                      padding: EdgeInsets.only(top: 50, bottom: 50),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Icon(
                              Icons.assessment,
                              size: 35,
                              color: Colors.black.withOpacity(0.75),
                            ),
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
                  height: 260,
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
                        elevation: 6,
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
                                                fontWeight: FontWeight.w300,
                                                color: Colors.white,
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
                                              fontWeight: FontWeight.w300,
                                              color: Colors.white,
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
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white70,
                                        fontSize: 16),
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
            return Padding(
              padding: EdgeInsets.only(bottom: 25),
              child: DashCardSkeleton(
                padding: 20,
              ),
            );
          },
        ),
        Padding(
          padding: EdgeInsets.only(top: 5, left: 20, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                'Upcoming Sessions',
                style: TextStyle(color: Colors.black87, fontSize: 19),
              ),
              Spacer(),
              InkWell(
                child: Text(
                  'See all',
                  style: TextStyle(color: Colors.blue, fontSize: 15),
                ),
                onTap: () {
                  curPage = ScheduleScreen();
                  Navigator.pushAndRemoveUntil(
                    context,
                    PageTransition(
                        type: PageTransitionType.fade, child: ScheduleScreen()),
                    (Route<dynamic> route) => false,
                  );
                },
              ),
            ],
          ),
        ),
        FutureBuilder(
          future: upcomingSessions.timeout(Duration(seconds: 10)),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Padding(
                padding: EdgeInsets.only(left: 25, right: 25),
                child: Card(
                  margin: EdgeInsets.only(top: 20, bottom: 30),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  elevation: 6,
                  child: Padding(
                    padding:
                        EdgeInsets.only(left: 5, right: 5, top: 55, bottom: 50),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Icon(
                            Icons.error_outline,
                            size: 35,
                            color: Colors.red.withOpacity(0.75),
                          ),
                        ),
                        Text(
                          'Unable to establish a connection\nwith our servers.\nCheck your connection and try again later.',
                          style: TextStyle(color: Colors.black54),
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  ),
                ),
              );
            }
            if (snapshot.hasData) {
              if (snapshot.data.length == 0) {
                return Padding(
                  padding: EdgeInsets.only(left: 25, right: 25),
                  child: Card(
                    margin: EdgeInsets.only(top: 20, bottom: 30),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    elevation: 6,
                    child: Padding(
                      padding: EdgeInsets.only(top: 50, bottom: 50),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Icon(
                              Icons.schedule,
                              size: 35,
                              color: Colors.black.withOpacity(0.75),
                            ),
                          ),
                          Text(
                            "No upcoming sessions",
                            style: TextStyle(color: Colors.black54),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            "Enjoy your day!",
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
                  height: 235,
                  child: Swiper(
                    loop: false,
                    pagination: snapshot.data.length == 1
                        ? null
                        : SwiperPagination(margin: EdgeInsets.all(0)),
                    itemCount: snapshot.data.length,
                    viewportFraction: 0.83,
                    scale: 0.9,
                    itemBuilder: (BuildContext context, int index) {
                      DateTime sessionDateTime = DateTime.parse(
                              snapshot.data[index]['session_timestamp'])
                          .toLocal();
                      final int hour =
                          snapshot.data[index]['session_duration'] ~/ 60;
                      final int minutes =
                          snapshot.data[index]['session_duration'] % 60;
                      return Card(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        margin: EdgeInsets.only(top: 20, bottom: 30),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        elevation: 6,
                        child: Padding(
                          padding:
                              EdgeInsets.only(top: 10, left: 20, right: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Text(
                                    DateFormat.d().format(sessionDateTime),
                                    style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 38,
                                        fontWeight: FontWeight.w200),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.only(left: 3, bottom: 2.9),
                                    child: Text(
                                      DateFormat.MMM()
                                          .format(sessionDateTime)
                                          .toUpperCase(),
                                      style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 25,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  Spacer(),
                                  Padding(
                                    padding:
                                        EdgeInsets.only(left: 2, bottom: 12),
                                    child: Text(
                                      hour == 0
                                          ? minutes.toString() + 'm'
                                          : hour.toString() +
                                              'h ' +
                                              minutes.toString() +
                                              'm',
                                      style: TextStyle(
                                          color: Colors.blue,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w200),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 2, bottom: 0),
                                child: Text(
                                  DateFormat.jm()
                                      .format(sessionDateTime)
                                      .toUpperCase(),
                                  style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w200),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 2, top: 13),
                                child: Text(
                                  snapshot.data[index]['subject_of_session'],
                                  style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 21,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              snapshot.data[index]['session_notes'] == ''
                                  ? Container()
                                  : Padding(
                                      padding: EdgeInsets.only(
                                          left: 3, top: 3, right: 8),
                                      child: Text(
                                        snapshot.data[index]['session_notes'],
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        style: TextStyle(
                                            color: Colors.black87,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w200),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
            }
            return DashCardSkeleton(
              padding: 20,
            );
          },
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 20, top: 15, left: 18, right: 18),
          child: Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15))),
            elevation: 6,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Spacer(),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(right: 5),
                            child: Icon(
                              Icons.edit,
                              color: Colors.black.withOpacity(0.8),
                            ),
                          ),
                          Text(
                            'Notepad',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                                color: Colors.black.withOpacity(0.8)),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      Spacer(),
                      saved
                          ? Padding(
                              padding: EdgeInsets.only(right: 13),
                              child: Icon(
                                Icons.check,
                                color: Colors.green,
                              ),
                            )
                          : saving
                              ? Padding(
                                  padding: EdgeInsets.only(right: 17),
                                  child: SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: SpinKitThreeBounce(
                                          color: Colors.black87, size: 10)),
                                )
                              : savingfailed
                                  ? Padding(
                                      padding: EdgeInsets.only(right: 10),
                                      child: Icon(
                                        Icons.priority_high,
                                        color: Colors.red,
                                      ),
                                    )
                                  : Container(),
                    ],
                  ),
                ),
                Text(
                  "Changes will be synced across devices",
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: 10,
                      fontWeight: FontWeight.w400),
                  textAlign: TextAlign.center,
                ),
                Divider(thickness: 0, indent: 25, endIndent: 25),
                FutureBuilder(
                    future: studentNotes.timeout(Duration(seconds: 10)),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        saving = false;
                        savingfailed = true;
                        return Padding(
                          padding: EdgeInsets.only(
                              top: 20, left: 20, right: 20, bottom: 30),
                          child: Text(
                            'Unable to load your notes. Try again later',
                            style:
                                TextStyle(fontSize: 12, color: Colors.black54),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      if (snapshot.hasData) {
                        saving = false;
                        saved = true;
                        return Padding(
                          padding: EdgeInsets.only(
                              top: 0, left: 20, right: 20, bottom: 10),
                          child: TextField(
                            controller: studentnotes,
                            autocorrect: true,
                            maxLines: null,
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black87),
                                  borderRadius: BorderRadius.circular(10)),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              hintText:
                                  'Take note of your tasks, plans, thoughts...',
                              hintStyle: TextStyle(
                                  color: Colors.black54, fontSize: 14),
                            ),
                            onChanged: (value) => _editStudentNotes(),
                          ),
                        );
                      }
                      return Padding(
                        padding: EdgeInsets.only(
                            top: 30, left: 20, right: 20, bottom: 50),
                        child: Center(
                            child: SpinKitWave(
                          color: Colors.grey.withOpacity(0.4),
                          size: 30,
                        )),
                      );
                    })
              ],
            ),
          ),
        )
      ],
    );
  }
}
