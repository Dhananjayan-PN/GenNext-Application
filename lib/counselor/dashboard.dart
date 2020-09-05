import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../imports.dart';
import 'home.dart';
import 'schedule.dart';

class DashBoard extends StatefulWidget {
  final User user;
  DashBoard({this.user});

  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  TextEditingController _reason = TextEditingController();
  TextEditingController counselornotes = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool savingfailed = false;
  bool saved = false;
  bool saving = true;
  int index = 0;

  Future upcomingSessions;
  Future incomingRequests;
  Future counselorNotes;

  @override
  void initState() {
    upcomingSessions = getUpcomingSession();
    incomingRequests = getAssignmentRequests();
    counselorNotes = getCounselorNotes();
    super.initState();
  }

  Future<void> getUpcomingSession() async {
    String tok = await getToken();
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
    String tok = await getToken();
    final response =
        await http.get(dom + 'api/counselor/get-assignment-requests', headers: {
      HttpHeaders.authorizationHeader: 'Token $tok',
    });
    if (response.statusCode == 200) {
      return json.decode(response.body)['incoming_reqs'];
    } else {
      throw ('error');
    }
  }

  Future<void> accept(int id) async {
    String tok = await getToken();
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
    String tok = await getToken();
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
        _reason.clear();
        Navigator.pop(context);
        refresh();
      } else {
        _reason.clear();
        Navigator.pop(context);
        error(context);
        refresh();
      }
    } else {
      _reason.clear();
      Navigator.pop(context);
      error(context);
      refresh();
    }
  }

  Future<void> getCounselorNotes() async {
    String tok = await getToken();
    saving = true;
    final response = await http.get(dom + 'authenticate/get-notes', headers: {
      HttpHeaders.authorizationHeader: 'Token $tok',
    });
    if (response.statusCode == 200) {
      String notes = json.decode(response.body)['notes'];
      setState(() {
        counselornotes.text = notes;
        saving = false;
        saved = true;
      });
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
    String tok = await getToken();
    final response = await http.put(
      dom + 'authenticate/edit-notes',
      headers: {
        HttpHeaders.authorizationHeader: "Token $tok",
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode(
        <String, dynamic>{
          "user_id": widget.user.id,
          "notes": counselornotes.text
        },
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

  _deny(int id) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: EdgeInsets.only(top: 15),
          contentPadding: EdgeInsets.all(0),
          elevation: 20,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
          ),
          title: Center(
            child: Text(
              'Reject Request',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
          ),
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
                    padding: EdgeInsets.only(left: 25, right: 25),
                    child: TextFormField(
                      cursorColor: Color(0xff005fa8),
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
                style: TextStyle(color: Color(0xff005fa8)),
              ),
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  Navigator.pop(context);
                  deny(id);
                  loading(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  refresh() {
    setState(() {
      upcomingSessions = getUpcomingSession();
      incomingRequests = getAssignmentRequests();
      counselorNotes = getCounselorNotes();
    });
  }

  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 20, top: 18),
          child: Text(
            'Hello,',
            style: TextStyle(
                color: Colors.black54,
                fontSize: 24,
                fontWeight: FontWeight.w300),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 20),
          child: Text(
            '${widget.user.firstname}',
            style: TextStyle(
                color: Colors.black87,
                fontSize: 25,
                fontWeight: FontWeight.w400),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 20, left: 20, right: 20),
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
                  style: TextStyle(color: Color(0xff005fa8), fontSize: 15),
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
                  margin: EdgeInsets.only(top: 20, bottom: 20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  elevation: 6,
                  child: Padding(
                    padding:
                        EdgeInsets.only(left: 3, right: 3, top: 30, bottom: 30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Icon(
                            Icons.error_outline,
                            size: 35,
                            color: Colors.red.withOpacity(0.6),
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
                              size: 37,
                              color: Colors.black.withOpacity(0.75),
                            ),
                          ),
                          Text(
                            "There are no upcoming sessions",
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
                  height: 250,
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
                                        EdgeInsets.only(left: 2, bottom: 2.9),
                                    child: Text(
                                      DateFormat.MMM()
                                          .format(sessionDateTime)
                                          .toUpperCase(),
                                      style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 25,
                                          fontWeight: FontWeight.w400),
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
                                          color: Color(0xff005fa8),
                                          fontSize: 18,
                                          fontWeight: FontWeight.w200),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 3, bottom: 0),
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
                                padding: EdgeInsets.only(left: 2, top: 6),
                                child: Text(
                                  snapshot.data[index]['student_name'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Color(0xff005fa8),
                                      fontSize: 17,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 2, top: 4),
                                child: Text(
                                  snapshot.data[index]['subject_of_session'],
                                  style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 18.5,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                              snapshot.data[index]['session_notes'] == ''
                                  ? Container()
                                  : Padding(
                                      padding: EdgeInsets.only(
                                          left: 3, top: 2, right: 8),
                                      child: Text(
                                        snapshot.data[index]['session_notes'],
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 4,
                                        style: TextStyle(
                                            color:
                                                Colors.black.withOpacity(0.6),
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w300),
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
          padding: EdgeInsets.only(top: 5, left: 20, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                'Counseling Requests',
                style: TextStyle(color: Colors.black87, fontSize: 19),
              ),
            ],
          ),
        ),
        FutureBuilder(
          future: incomingRequests.timeout(Duration(seconds: 10)),
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
                        EdgeInsets.only(left: 3, right: 3, top: 30, bottom: 30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Icon(
                            Icons.error_outline,
                            size: 35,
                            color: Colors.red.withOpacity(0.6),
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
                      padding: EdgeInsets.only(top: 30, bottom: 30),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Icon(
                              Icons.thumb_up,
                              size: 35,
                              color: Colors.black.withOpacity(0.75),
                            ),
                          ),
                          Text(
                            "No pending counselling requests",
                            style: TextStyle(color: Colors.black54),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            "Check back later to see them!",
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
                  height: 190,
                  child: Swiper(
                    loop: false,
                    pagination: snapshot.data.length == 1
                        ? null
                        : SwiperPagination(margin: EdgeInsets.all(0)),
                    itemCount: snapshot.data.length,
                    viewportFraction: 0.83,
                    scale: 0.9,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        margin: EdgeInsets.only(top: 20, bottom: 30),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        elevation: 6,
                        child: Padding(
                          padding:
                              EdgeInsets.only(top: 10, left: 15, right: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(top: 5, bottom: 5),
                                child: Row(
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.only(left: 10),
                                      child: CircleAvatar(
                                        radius: 27,
                                        backgroundImage: CachedNetworkImageProvider(
                                            'https://images.newindianexpress.com/uploads/user/imagelibrary/2019/3/7/w900X450/Take_in_the_Scenery.jpg'),
                                        backgroundColor: Color(0xff005fa8),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 18),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: 2, bottom: 2),
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.50,
                                              child: Text(
                                                snapshot.data[index]
                                                    ['student_name'],
                                                style:
                                                    TextStyle(fontSize: 15.5),
                                              ),
                                            ),
                                          ),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Assigned By:',
                                                style: TextStyle(
                                                    color: Colors.black54,
                                                    fontSize: 13),
                                              ),
                                              Container(
                                                margin:
                                                    EdgeInsets.only(left: 1),
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.3,
                                                child: Text(
                                                  '@' +
                                                      snapshot.data[index]
                                                          ['assigner_admin'],
                                                  style: TextStyle(
                                                      color: Color(0xff005fa8),
                                                      fontSize: 13),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Spacer(),
                              Padding(
                                padding: EdgeInsets.only(bottom: 15),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    ClipOval(
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          child: Icon(
                                            Icons.check,
                                            color: Colors.green,
                                            size: 33,
                                          ),
                                          onTap: () {
                                            accept(snapshot.data[index]
                                                ['student_id']);
                                            loading(context);
                                          },
                                        ),
                                      ),
                                    ),
                                    VerticalDivider(),
                                    Padding(
                                      padding: EdgeInsets.only(left: 25),
                                      child: ClipOval(
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            child: Icon(
                                              Icons.close,
                                              color: Colors.red,
                                              size: 33,
                                            ),
                                            onTap: () {
                                              _deny(snapshot.data[index]
                                                  ['student_id']);
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
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
          padding: EdgeInsets.only(top: 20),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(width: 0.2, color: Colors.black54),
              ),
            ),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              elevation: 0,
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
                                          color: Colors.black87, size: 10),
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
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: 10,
                        fontWeight: FontWeight.w400),
                    textAlign: TextAlign.center,
                  ),
                  Divider(thickness: 0, indent: 25, endIndent: 25),
                  FutureBuilder(
                    future: counselorNotes.timeout(Duration(seconds: 10)),
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
                              top: 0, left: 20, right: 20, bottom: 30),
                          child: TextField(
                            cursorColor: Color(0xff005fa8),
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
                            top: 30, left: 20, right: 20, bottom: 50),
                        child: Center(
                            child: SpinKitWave(
                          color: Colors.grey.withOpacity(0.4),
                          size: 30,
                        )),
                      );
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
