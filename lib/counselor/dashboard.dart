import '../imports.dart';
import 'package:http/http.dart' as http;
import 'home.dart';

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
  int index = 0;
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
        )
      ],
    );
  }
}
