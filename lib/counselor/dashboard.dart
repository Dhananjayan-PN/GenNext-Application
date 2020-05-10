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

  int index = 0;

  Future<void> getUpcomingSession() async {
    final response = await http.get(
        'https://gennext.ml/api/counselor/get-sessions-calendar',
        headers: {
          HttpHeaders.authorizationHeader: 'Token $tok',
        });
    if (response.statusCode == 200) {
      List sessions = json.decode(response.body)['counselor_sessions'];
      List upcoming = [];
      for (var i = 0; sessions.length < 4 ? i < sessions.length : i < 5; i++) {
        upcoming.add(sessions[i]);
      }
      return upcoming;
    } else {
      throw ('error');
    }
  }

  Future<void> getAssignmentRequests() async {
    final response = await http.get(
        'https://gennext.ml/api/counselor/get-assignment-requests',
        headers: {
          HttpHeaders.authorizationHeader: 'Token $tok',
        });
    if (response.statusCode == 200) {
      List requests = json.decode(response.body)['incoming_reqs'];
      List<Widget> requestList = [
        Divider(indent: 25, endIndent: 25, thickness: 0)
      ];
      for (var i = 0; i < requests.length; i++) {
        requestList.add(requestBuilder(requests[i]));
      }
      return requestList;
    } else {
      throw ('error');
    }
  }

  requestBuilder(Map<String, dynamic> request) {
    return Text(request['student_name']);
  }

  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 30, bottom: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(right: 5),
                child: Icon(
                  Icons.access_time,
                  color: Colors.black.withOpacity(0.8),
                ),
              ),
              Text(
                'Upcoming Sessions',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.black.withOpacity(0.8)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        FutureBuilder(
          future: getUpcomingSession(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
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
              );
            }
            if (snapshot.hasData) {
              if (snapshot.data.length == 0) {
                return Container(
                  height: 250,
                  child: Card(
                    margin: EdgeInsets.only(top: 20, bottom: 30),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15))),
                    elevation: 10,
                    child: Column(
                      children: <Widget>[
                        Icon(
                          Icons.sentiment_dissatisfied,
                          size: 40,
                        ),
                        Text(
                          "Looks like you haven't scheduled\nany session yet :(",
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return Container(
                  height: 270,
                  child: Swiper(
                    loop: false,
                    pagination: SwiperPagination(margin: EdgeInsets.all(0)),
                    itemCount: snapshot.data.length,
                    viewportFraction: 0.8,
                    scale: 0.9,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        margin: EdgeInsets.only(top: 20, bottom: 30),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(15))),
                        elevation: 10,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(top: 10, bottom: 5),
                              child: CircleAvatar(
                                radius: 28,
                                backgroundImage: CachedNetworkImageProvider(
                                    'https://onetwostream.com/blog/wp-content/uploads/2019/10/sunset_beach.jpg'),
                                backgroundColor: Colors.blue[400],
                              ),
                            ),
                            Text(
                              snapshot.data[index]['student_name'],
                              style: TextStyle(fontSize: 20),
                            ),
                            Text(
                              '@' + snapshot.data[index]['student_username'],
                              style: TextStyle(color: Colors.blue),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 15),
                              child: Text(
                                DateFormat.yMMMMd('en_US').add_jm().format(
                                    DateTime.parse(snapshot.data[index]
                                            ['session_timestamp'])
                                        .toLocal()),
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    'Subject - ',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    snapshot.data[index]['subject_of_session'],
                                    style: TextStyle(color: Colors.black54),
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 14),
                              child: InkWell(
                                child: Text(
                                  'View',
                                  style: TextStyle(
                                      color: Colors.blue, fontSize: 17),
                                ),
                                onTap: () {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    PageTransition(
                                        type: PageTransitionType.fade,
                                        child: ScheduleScreen()),
                                    (Route<dynamic> route) => false,
                                  );
                                },
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                );
              }
            }
            return Container(
                height: 270, child: Center(child: CircularProgressIndicator()));
          },
        ),
        Padding(
          padding: EdgeInsets.only(top: 30, left: 10, right: 10),
          child: FutureBuilder(
              future: getAssignmentRequests(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Container(
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
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15))),
                    elevation: 10,
                    child: ExpansionTile(
                      initiallyExpanded: true,
                      title: Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(right: 5),
                              child: Icon(
                                Icons.group,
                                color: Colors.black.withOpacity(0.8),
                              ),
                            ),
                            Text(
                              'Incoming Requests',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black.withOpacity(0.8)),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      children: snapshot.data,
                    ),
                  );
                }
                return Center(child: CircularProgressIndicator());
              }),
        )
      ],
    );
  }
}
