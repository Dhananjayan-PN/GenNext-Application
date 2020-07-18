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

  TextEditingController _reason = TextEditingController();
  TextEditingController counselornotes = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int index = 0;
  int userId;
  bool saved = false;
  bool saving = true;
  bool savingfailed = false;

  Future upcomingsession;
  Future assignmentrequests;
  Future counselorNotes;

  @override
  void initState() {
    upcomingsession = getUpcomingSession();
    assignmentrequests = getAssignmentRequests();
    counselorNotes = getCounselorNotes();
    super.initState();
  }

  Future<void> getUpcomingSession() async {
    final response =
        await http.get(dom + 'api/counselor/get-sessions-calendar', headers: {
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
    final response =
        await http.get(dom + 'api/counselor/get-assignment-requests', headers: {
      HttpHeaders.authorizationHeader: 'Token $tok',
    });
    if (response.statusCode == 200) {
      List requests = json.decode(response.body)['incoming_reqs'];
      if (requests.length == 0) {
        return <Widget>[];
      } else {
        List<Widget> requestList = [
          Divider(indent: 25, endIndent: 25, thickness: 0)
        ];
        for (var i = 0; i < requests.length; i++) {
          requestList.add(requestBuilder(requests[i]));
        }
        return requestList;
      }
    } else {
      throw ('error');
    }
  }

  Future<void> accept(int id) async {
    final response = await http.put(
      dom + 'api/counselor/accept-or-deny-reqs',
      headers: {
        HttpHeaders.authorizationHeader: "Token $tok",
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode(
        <String, dynamic>{
          "student_id": id,
          "decision": 'A',
          "reason_for_decision": ''
        },
      ),
    );
    if (response.statusCode == 200) {
      if (json.decode(response.body)['response'] == 'Decision Registered.') {
        Navigator.pop(context);
        success(context);
        refresh();
      } else {
        Navigator.pop(context);
        error(context);
        refresh();
      }
    } else {
      Navigator.pop(context);
      error(context);
      refresh();
    }
  }

  Future<void> deny(int id) async {
    final response = await http.put(
      dom + 'api/counselor/accept-or-deny-reqs',
      headers: {
        HttpHeaders.authorizationHeader: "Token $tok",
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode(
        <String, dynamic>{
          "student_id": id,
          "decision": 'R',
          "reason_for_decision": _reason.text
        },
      ),
    );
    if (response.statusCode == 200) {
      if (json.decode(response.body)['response'] == 'Decision Registered.') {
        Navigator.pop(context);
        success(context);
        refresh();
      } else {
        Navigator.pop(context);
        error(context);
        refresh();
      }
    } else {
      Navigator.pop(context);
      error(context);
      refresh();
    }
  }

  Future<void> getCounselorNotes() async {
    saving = true;
    final response =
        await http.get(dom + 'api/counselor/get-counselor-notes', headers: {
      HttpHeaders.authorizationHeader: 'Token $tok',
    });
    if (response.statusCode == 200) {
      setState(() {
        saving = false;
        saved = true;
      });
      userId = json.decode(response.body)['counselor_id'];
      String notes = json.decode(response.body)['counselor_notes'];
      return notes;
    } else {
      setState(() {
        saving = false;
        savingfailed = true;
      });
      throw ('error');
    }
  }

  Future<void> editCounselorNotes() async {
    final response = await http.put(
      dom + 'api/counselor/edit-counselor-notes',
      headers: {
        HttpHeaders.authorizationHeader: "Token $tok",
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode(
        <String, dynamic>{"user_id": userId, "notes": counselornotes.text},
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
        error(context);
      }
    } else {
      setState(() {
        saving = false;
        savingfailed = true;
      });
      error(context);
    }
  }

  _editCounselorNotes() {
    setState(() {
      saved = false;
      saving = true;
    });
    editCounselorNotes();
  }

  _deny(String decision, int id) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: EdgeInsets.only(top: 15),
          contentPadding: EdgeInsets.all(0),
          elevation: 20,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: Center(
              child: Text('Reject',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500))),
          content: Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
            ),
            child: Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 5, left: 20, right: 20),
                    child: Divider(thickness: 0),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(
                      'Provide a reason for your rejection',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 25, right: 25),
                    child: TextFormField(
                      controller: _reason,
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.blue, width: 0.0),
                        ),
                        labelText: 'Reason',
                        labelStyle: TextStyle(color: Colors.black54),
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'A reason is required to reject';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                _reason.clear();
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text(
                'Send',
                style: TextStyle(color: Colors.blue),
              ),
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  _reason.clear();
                  Navigator.pop(context);
                  loading(context);
                  deny(id);
                }
              },
            ),
          ],
        );
      },
    );
  }

  requestBuilder(Map<String, dynamic> request) {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 15, bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(request['student_name'], style: TextStyle(fontSize: 18)),
              Row(
                children: <Widget>[
                  Text('Sent by: '),
                  Text('@' + request['assigner_admin'],
                      style: TextStyle(color: Colors.blue)),
                ],
              )
            ],
          ),
          Row(
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.check_circle,
                  size: 30,
                  color: Colors.green,
                ),
                onPressed: () {
                  loading(context);
                  accept(request['student_id']);
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.cancel,
                  size: 30,
                  color: Colors.red,
                ),
                onPressed: () {
                  _deny('R', request['student_id']);
                },
              )
            ],
          )
        ],
      ),
    );
  }

  refresh() {
    setState(() {
      upcomingsession = getUpcomingSession();
      assignmentrequests = getAssignmentRequests();
      counselorNotes = getCounselorNotes();
    });
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
          future: upcomingsession,
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
                            "Looks like you haven't scheduled\nany sessions yet",
                            style: TextStyle(color: Colors.black54),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            "Head over to the Schedule section to\nget started!",
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
          padding: EdgeInsets.only(top: 20, left: 10, right: 10),
          child: FutureBuilder(
              future: assignmentrequests,
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
                        padding: EdgeInsets.only(left: 20),
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
                      children: snapshot.data.length == 0
                          ? [
                              Padding(
                                padding: EdgeInsets.only(bottom: 15),
                                child: Text(
                                  'All requests have been taken care of!',
                                  style: TextStyle(color: Colors.black54),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            ]
                          : snapshot.data,
                    ),
                  );
                }
                return Center(child: CircularProgressIndicator());
              }),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 20, top: 30, left: 10, right: 10),
          child: Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15))),
            elevation: 10,
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
                                fontWeight: FontWeight.w800,
                                color: Colors.black.withOpacity(0.8)),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      Spacer(),
                      saved
                          ? Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: Icon(
                                Icons.check,
                                color: Colors.green,
                              ),
                            )
                          : saving
                              ? Padding(
                                  padding: EdgeInsets.only(right: 14),
                                  child: SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                    ),
                                  ),
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
                  style: TextStyle(color: Colors.black54, fontSize: 10),
                  textAlign: TextAlign.center,
                ),
                Divider(thickness: 0, indent: 25, endIndent: 25),
                FutureBuilder(
                    future: counselorNotes,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        saving = false;
                        savingfailed = true;
                        return Padding(
                          padding: EdgeInsets.only(
                              top: 00, left: 20, right: 20, bottom: 15),
                          child: Text(
                            'Unable to load your notes. Try again later',
                            style: TextStyle(fontSize: 12, color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      if (snapshot.hasData) {
                        saving = false;
                        saved = true;
                        return Padding(
                          padding: EdgeInsets.only(
                              top: 10, left: 20, right: 20, bottom: 10),
                          child: TextField(
                            controller: counselornotes,
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
                            onChanged: (value) => _editCounselorNotes(),
                          ),
                        );
                      }
                      return Padding(
                        padding: EdgeInsets.only(
                            top: 10, left: 20, right: 20, bottom: 10),
                        child: Center(child: CircularProgressIndicator()),
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
