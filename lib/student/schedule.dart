import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../imports.dart';
import 'counselor.dart';
import 'home.dart';

class ScheduleScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ScheduleScreenState();
}

class ScheduleScreenState extends State<ScheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> _scafKey = GlobalKey<ScaffoldState>();
  TextEditingController _subject = TextEditingController();
  TextEditingController _reason = TextEditingController();
  TextEditingController _datetimecontroller = TextEditingController();
  DateTime _newDateTime;
  DateTime _selectedDay;
  CalendarController _calendarController;
  Map<DateTime, List<List<dynamic>>> _events;
  Map<String, int> studentids = {};
  List _selectedEvents;
  DateTime today;
  int studentId;
  bool fabVisible = true;
  Future sessions;

  @override
  void initState() {
    super.initState();
    sessions = getEvents();
    _events = {};
    _calendarController = CalendarController();
    BackButtonInterceptor.add(myInterceptor);
    _selectedEvents = [];
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    _calendarController.dispose();
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent) {
    curPage = StudentHomeScreen(user: newUser);
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.fade,
        child: StudentHomeScreen(user: newUser),
      ),
    );
    return true;
  }

  Future<void> getEvents() async {
    final response =
        await http.get(dom + 'api/student/get-counselor-sessions', headers: {
      HttpHeaders.authorizationHeader: 'Token $tok',
    });
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['Response'] == 'Student yet to be connected with a counselor.') {
        setState(() {
          fabVisible = false;
        });
        return 'No counselor';
      } else {
        studentId = json.decode(response.body)['student_id'];
        return json.decode(response.body)['session_data'];
      }
    } else {
      setState(() {
        fabVisible = false;
      });
      throw ('error');
    }
  }

  Future<void> requestSession() async {
    final response = await http.post(
      dom + 'api/student/request-counselor-session/',
      headers: <String, String>{
        HttpHeaders.authorizationHeader: "Token $tok",
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: json.encode(
        <String, dynamic>{
          "student_id": studentId,
          "subject_of_session": _subject.text,
          "time_of_session": _newDateTime.toUtc().toIso8601String(),
          "student_message": _reason.text,
        },
      ),
    );
    if (response.statusCode == 200) {
      if (json.decode(response.body)['Response'] ==
          'Session request successfully sent.') {
        Navigator.pop(context);
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
                        Icons.check_circle_outline,
                        size: 40,
                        color: Colors.green,
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Text(
                          'Request successfully sent!\nYour counselor will be notified',
                          style: TextStyle(color: Colors.black, fontSize: 14),
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
        refresh();
        setState(() {
          _selectedDay = _newDateTime;
          _selectedEvents = _events[_selectedDay] ?? [];
        });
      } else {
        Navigator.pop(context);
        error(context);
        refresh();
        setState(() {});
      }
    } else {
      Navigator.pop(context);
      error(context);
      refresh();
      setState(() {});
    }
  }

  Future<void> requestEditSession(int id, String message) async {
    final response = await http.put(
      dom + 'api/student/request-session-edit/$id',
      headers: {
        HttpHeaders.authorizationHeader: "Token $tok",
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode(
        <String, dynamic>{"session_id": id, "student_message": message},
      ),
    );
    if (response.statusCode == 200) {
      if (json.decode(response.body)['Response'] ==
          'Edit request successfully sent.') {
        Navigator.pop(context);
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
                        Icons.check_circle_outline,
                        size: 40,
                        color: Colors.green,
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Text(
                          'Request successfully sent!\nYour counselor will be notified',
                          style: TextStyle(color: Colors.black, fontSize: 14),
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
        refresh();
        setState(() {
          _selectedDay = _newDateTime;
          _selectedEvents = _events[_selectedDay] ?? [];
        });
      } else {
        Navigator.pop(context);
        error(context);
        refresh();
        setState(() {});
      }
    } else {
      Navigator.pop(context);
      error(context);
      refresh();
      setState(() {});
    }
  }

  refresh() {
    setState(() {
      sessions = getEvents();
    });
  }

  _requestSession() {
    _subject.clear();
    _reason.clear();
    _datetimecontroller.clear();
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: EdgeInsets.only(top: 15),
          contentPadding: EdgeInsets.all(0),
          elevation: 20,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: Center(
              child: Text('Request Session',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500))),
          content: Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
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
                    padding: EdgeInsets.only(top: 10, left: 25, right: 25),
                    child: DateTimeField(
                      controller: _datetimecontroller,
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0xff005fa8), width: 0.0),
                        ),
                        labelText: 'Date and Time',
                        labelStyle: TextStyle(color: Colors.black54),
                      ),
                      format: DateFormat.yMd().add_jm(),
                      onChanged: (value) {
                        setState(() {
                          _newDateTime = value;
                        });
                      },
                      onShowPicker: (context, currentValue) async {
                        final _date = await showDatePicker(
                          context: context,
                          firstDate: DateTime.now(),
                          initialDate:
                              currentValue ?? _selectedDay ?? DateTime.now(),
                          lastDate: DateTime(2500),
                          builder: (context, child) {
                            return Theme(
                              data: ThemeData(
                                  colorScheme: ColorScheme(
                                      brightness: Brightness.light,
                                      error: Color(0xff005fa8),
                                      onError: Colors.red,
                                      background: Color(0xff005fa8),
                                      primary: Color(0xff005fa8),
                                      primaryVariant: Color(0xff005fa8),
                                      secondary: Color(0xff005fa8),
                                      secondaryVariant: Color(0xff005fa8),
                                      onPrimary: Colors.white,
                                      surface: Color(0xff005fa8),
                                      onSecondary: Colors.black,
                                      onSurface: Colors.black,
                                      onBackground: Colors.black)),
                              child: child,
                            );
                          },
                        );
                        if (_date != null) {
                          final _time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(
                                currentValue ?? _selectedDay ?? DateTime.now()),
                            builder: (context, child) {
                              return Theme(
                                data: ThemeData(
                                  primaryColor: Color(0xff005fa8),
                                  accentColor: Color(0xff005fa8),
                                  colorScheme: ColorScheme(
                                      brightness: Brightness.light,
                                      error: Color(0xff005fa8),
                                      onError: Colors.red,
                                      background: Color(0xff005fa8),
                                      primary: Color(0xff005fa8),
                                      primaryVariant: Color(0xff005fa8),
                                      secondary: Color(0xff005fa8),
                                      secondaryVariant: Color(0xff005fa8),
                                      onPrimary: Colors.white,
                                      surface: Color(0xff005fa8),
                                      onSecondary: Colors.black,
                                      onSurface: Colors.black,
                                      onBackground: Colors.black),
                                ),
                                child: child,
                              );
                            },
                          );
                          return DateTimeField.combine(_date, _time);
                        } else {
                          return currentValue;
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10, left: 25, right: 25),
                    child: TextFormField(
                      cursorColor: Color(0xff005fa8),
                      controller: _subject,
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0xff005fa8), width: 0.0),
                        ),
                        labelText: 'Subject',
                        labelStyle: TextStyle(color: Colors.black54),
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Session subject is required to save';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 30, left: 25, right: 25),
                    child: TextFormField(
                      cursorColor: Color(0xff005fa8),
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      controller: _reason,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0xff005fa8), width: 0.0),
                        ),
                        labelText: 'Reason',
                        labelStyle: TextStyle(color: Colors.black54),
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Reason is required to send request';
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
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text(
                'Send',
                style: TextStyle(color: Color(0xff005fa8)),
              ),
              onPressed: () {
                Navigator.pop(context);
                requestSession();
                loading(context);
              },
            ),
          ],
        );
      },
    );
  }

  _rescheduleSession(int id, DateTime time) {
    _reason.clear();
    _datetimecontroller.clear();
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: EdgeInsets.only(top: 15),
          contentPadding: EdgeInsets.all(0),
          elevation: 20,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: Center(
              child: Text('Reschedule Session',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500))),
          content: Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
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
                    padding: EdgeInsets.only(top: 10, left: 25, right: 25),
                    child: DateTimeField(
                      controller: _datetimecontroller,
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0xff005fa8), width: 0.0),
                        ),
                        labelText: 'New Date and Time',
                        labelStyle: TextStyle(color: Colors.black54),
                      ),
                      format: DateFormat.yMd().add_jm(),
                      onChanged: (value) {
                        setState(() {
                          _newDateTime = value;
                        });
                      },
                      onShowPicker: (context, currentValue) async {
                        final _date = await showDatePicker(
                          context: context,
                          firstDate: DateTime.now(),
                          initialDate: currentValue ?? time,
                          lastDate: DateTime(2500),
                          builder: (context, child) {
                            return Theme(
                              data: ThemeData(
                                colorScheme: ColorScheme(
                                    brightness: Brightness.light,
                                    error: Color(0xff005fa8),
                                    onError: Colors.red,
                                    background: Color(0xff005fa8),
                                    primary: Color(0xff005fa8),
                                    primaryVariant: Color(0xff005fa8),
                                    secondary: Color(0xff005fa8),
                                    secondaryVariant: Color(0xff005fa8),
                                    onPrimary: Colors.white,
                                    surface: Color(0xff005fa8),
                                    onSecondary: Colors.black,
                                    onSurface: Colors.black,
                                    onBackground: Colors.black),
                              ),
                              child: child,
                            );
                          },
                        );
                        if (_date != null) {
                          final _time = await showTimePicker(
                            context: context,
                            initialTime:
                                TimeOfDay.fromDateTime(currentValue ?? time),
                            builder: (context, child) {
                              return Theme(
                                data: ThemeData(
                                  primaryColor: Color(0xff005fa8),
                                  accentColor: Color(0xff005fa8),
                                  colorScheme: ColorScheme(
                                      brightness: Brightness.light,
                                      error: Color(0xff005fa8),
                                      onError: Colors.red,
                                      background: Color(0xff005fa8),
                                      primary: Color(0xff005fa8),
                                      primaryVariant: Color(0xff005fa8),
                                      secondary: Color(0xff005fa8),
                                      secondaryVariant: Color(0xff005fa8),
                                      onPrimary: Colors.white,
                                      surface: Color(0xff005fa8),
                                      onSecondary: Colors.black,
                                      onSurface: Colors.black,
                                      onBackground: Colors.black),
                                ),
                                child: child,
                              );
                            },
                          );
                          return DateTimeField.combine(_date, _time);
                        } else {
                          return currentValue;
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10, left: 25, right: 25),
                    child: TextFormField(
                      cursorColor: Color(0xff005fa8),
                      controller: _subject,
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0xff005fa8), width: 0.0),
                        ),
                        labelText: 'Reason',
                        labelStyle: TextStyle(color: Colors.black54),
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Reason is required to send request';
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
                  String message =
                      'Please reschedule session to ${_newDateTime.toUtc().toIso8601String()}. ';
                  Navigator.pop(context);
                  requestEditSession(id, message + _reason.text);
                  loading(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  _cancelSession(int id) {
    _reason.clear();
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: EdgeInsets.only(top: 15),
          contentPadding: EdgeInsets.all(0),
          elevation: 20,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: Center(
              child: Text('Cancel Session',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500))),
          content: Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
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
                    padding: EdgeInsets.only(top: 10, left: 25, right: 25),
                    child: TextFormField(
                      cursorColor: Color(0xff005fa8),
                      controller: _reason,
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0xff005fa8), width: 0.0),
                        ),
                        labelText: 'Reason',
                        labelStyle: TextStyle(color: Colors.black54),
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Reason is required to send request';
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
                  requestEditSession(
                      id, 'Please cancel the session. ' + _reason.text);
                  loading(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget buildEventCard(session) {
    DateTime sessionDateTime = DateTime.parse(session[7]).toLocal();
    int hour = session[8] ~/ 60;
    int minutes = session[8] % 60;
    String sessionTime = DateFormat.jm().format(sessionDateTime).toUpperCase();
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      elevation: 6,
      child: Padding(
        padding: EdgeInsets.only(top: 6, left: 20, right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  sessionTime.substring(0, sessionTime.length - 3),
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 30,
                      fontWeight: FontWeight.w100),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 1, bottom: 3),
                  child: Text(
                    sessionTime.substring(
                        sessionTime.length - 2, sessionTime.length),
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: 19,
                        fontWeight: FontWeight.w400),
                  ),
                ),
                Spacer(),
                Padding(
                  padding: EdgeInsets.only(left: 2, bottom: 5.5),
                  child: Text(
                    hour == 0
                        ? minutes.toString() + 'm'
                        : hour.toString() + 'h ' + minutes.toString() + 'm',
                    style: TextStyle(
                        color: Color(0xff005fa8),
                        fontSize: 19,
                        fontWeight: FontWeight.w200),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10, bottom: 4),
                  child: PopupMenuButton(
                    child: Icon(Icons.more_vert),
                    itemBuilder: (BuildContext context) {
                      return {'Reschedule', 'Cancel'}.map((String choice) {
                        return PopupMenuItem<String>(
                          height: 35,
                          value: choice,
                          child: Text(choice,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w400)),
                        );
                      }).toList();
                    },
                    onSelected: (value) {
                      switch (value) {
                        case 'Reschedule':
                          _rescheduleSession(session[0], sessionDateTime);
                          break;
                        case 'Cancel':
                          _cancelSession(session[0]);
                          break;
                      }
                    },
                  ),
                )
              ],
            ),
            Padding(
              padding: EdgeInsets.only(left: 1.5),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      DateFormat.d().format(sessionDateTime),
                      style: TextStyle(
                          color: Colors.black87,
                          fontSize: 15,
                          fontWeight: FontWeight.w300),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 1.2, bottom: 0.6),
                      child: Text(
                        DateFormat.MMM().format(sessionDateTime).toUpperCase(),
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14.8,
                            fontWeight: FontWeight.w300),
                      ),
                    ),
                  ]),
            ),
            Padding(
              padding: EdgeInsets.only(left: 1.5, top: 8),
              child: Text(
                session[4],
                style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
              ),
            ),
            session[5] == ''
                ? Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Container(),
                  )
                : Padding(
                    padding:
                        EdgeInsets.only(left: 2, top: 3, right: 8, bottom: 12),
                    child: Text(
                      session[5],
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                          color: Colors.black87,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w200),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Visibility(
        visible: fabVisible,
        child: FloatingActionButton(
            tooltip: 'Request session',
            elevation: 8,
            backgroundColor: Color(0xff005fa8),
            splashColor: Colors.blue[900],
            child: Icon(
              Icons.add,
              size: 28,
              color: Colors.white,
            ),
            onPressed: () {
              _requestSession();
            }),
      ),
      key: _scafKey,
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      drawer: NavDrawer(
          name: newUser.firstname + ' ' + newUser.lastname,
          email: newUser.email),
      appBar: CustomAppBar('Schedule'),
      body: FutureBuilder(
        future: sessions.timeout(Duration(seconds: 10)),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Padding(
              padding: EdgeInsets.only(bottom: 40.0),
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
            if (snapshot.data == 'No counselor') {
              return Padding(
                padding: EdgeInsets.only(left: 40, right: 40, bottom: 60),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.only(bottom: 0),
                          child: SizedBox(
                            height: 105,
                            width: 210,
                            child: Image.asset(
                              'images/gennextlonglogo-4.png',
                              fit: BoxFit.contain,
                            ),
                          )),
                      Text(
                        'This feature is available only to students assigned to a counselor.\nRequest now to unlock all benefits.',
                        style: TextStyle(color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: ActionChip(
                          shape: StadiumBorder(
                              side: BorderSide(
                                  color: Color(0xff005fa8), width: 0.0)),
                          backgroundColor: Colors.white,
                          label: Text('Request'),
                          onPressed: () {
                            curPage = CounsellingScreen();
                            Navigator.pushAndRemoveUntil(
                              context,
                              PageTransition(
                                  type: PageTransitionType.fade,
                                  child: CounsellingScreen()),
                              (Route<dynamic> route) => false,
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
              );
            } else {
              _events = {};
              for (var i = 0; i < snapshot.data.length; i++) {
                Map<String, dynamic> session = snapshot.data[i];
                DateTime timestamp =
                    DateTime.parse(session['session_timestamp']).toLocal();
                List event = [];
                for (var j = 0; j < session.length; j++) {
                  event.add(session[session.keys.toList()[j]]);
                }
                _events[timestamp] == null
                    ? _events[timestamp] = [
                        event,
                      ]
                    : _events[timestamp].add(event);
              }
              return Column(
                children: <Widget>[
                  TableCalendar(
                    calendarController: _calendarController,
                    locale: 'en_US',
                    events: _events,
                    initialCalendarFormat: CalendarFormat.month,
                    formatAnimation: FormatAnimation.slide,
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    availableGestures: AvailableGestures.all,
                    availableCalendarFormats: {
                      CalendarFormat.month: 'Month',
                    },
                    calendarStyle: CalendarStyle(
                      markersColor: Colors.red,
                      weekdayStyle: TextStyle(color: Color(0xff005fa8)),
                      weekendStyle: TextStyle(color: Color(0xff005fa8)),
                      outsideStyle: TextStyle(color: Colors.black45),
                      unavailableStyle: TextStyle(color: Colors.black45),
                      outsideWeekendStyle: TextStyle(color: Colors.black45),
                    ),
                    daysOfWeekStyle: DaysOfWeekStyle(
                      dowTextBuilder: (date, locale) {
                        return DateFormat.E(locale)
                            .format(date)
                            .substring(0, 3)
                            .toUpperCase();
                      },
                      weekdayStyle: TextStyle(color: Colors.black),
                      weekendStyle: TextStyle(color: Colors.black),
                    ),
                    headerStyle: HeaderStyle(
                      titleTextStyle: TextStyle(fontSize: 22),
                      centerHeaderTitle: true,
                    ),
                    headerVisible: true,
                    onDaySelected: (date, events) {
                      setState(() {
                        _selectedDay = date;
                        _selectedEvents = events;
                      });
                    },
                    builders: CalendarBuilders(
                      markersBuilder: (context, date, events, holidays) {
                        return [
                          Container(
                            margin: EdgeInsets.all(2.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.red),
                              shape: BoxShape.circle,
                            ),
                            width: 100,
                            height: 100,
                          )
                        ];
                      },
                      todayDayBuilder: (context, date, _) {
                        return Container(
                          margin: EdgeInsets.all(6.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Color(0xff005fa8)),
                            shape: BoxShape.circle,
                          ),
                          width: 100,
                          height: 100,
                          child: Center(
                            child: Text(
                              '${date.day}',
                              style: TextStyle(
                                  fontSize: 17.0,
                                  color: Color(0xff005fa8),
                                  fontWeight: FontWeight.w900),
                            ),
                          ),
                        );
                      },
                      selectedDayBuilder: (context, date, _) {
                        return Container(
                          decoration: BoxDecoration(
                            boxShadow: kElevationToShadow[4],
                            color: Color(0xff005fa8),
                            shape: BoxShape.circle,
                          ),
                          margin: EdgeInsets.all(2.0),
                          width: 100,
                          height: 100,
                          child: Center(
                            child: Text(
                              '${date.day}',
                              style: TextStyle(
                                  fontSize: 18.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  _events != {}
                      ? Expanded(
                          child: Padding(
                            padding:
                                EdgeInsets.only(top: 15, left: 15, right: 15),
                            child: ListView.builder(
                                scrollDirection: Axis.vertical,
                                itemCount: _selectedEvents.length,
                                itemBuilder: (context, index) {
                                  return buildEventCard(_selectedEvents[index]);
                                }),
                          ),
                        )
                      : Center(
                          child: Text(
                            'No sessions in your calendar\nTap on + to request one',
                            style:
                                TextStyle(color: Colors.black87, fontSize: 15),
                          ),
                        )
                ],
              );
            }
          }
          return Center(child: SpinKitWave(color: Colors.grey[400], size: 30));
        },
      ),
    );
  }
}
