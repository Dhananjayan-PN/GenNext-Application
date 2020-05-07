import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:page_transition/page_transition.dart';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'home.dart';

class ScheduleScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ScheduleScreenState();
}

class ScheduleScreenState extends State<ScheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> _scafKey = GlobalKey<ScaffoldState>();
  TextEditingController _subject = TextEditingController();
  TextEditingController _duration = TextEditingController();
  TextEditingController _notes = TextEditingController();
  TextEditingController _datetimecontroller = TextEditingController();
  DateTime _newDateTime;
  CalendarController _calendarController;
  Map<DateTime, List<List<dynamic>>> _events;
  List _selectedEvents;
  bool expanded;

  @override
  void initState() {
    super.initState();
    _events = {};
    _calendarController = CalendarController();
    BackButtonInterceptor.add(myInterceptor);
    final _selectedDay = DateTime.now();
    _selectedEvents = _events[_selectedDay] ?? [];
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    _calendarController.dispose();
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent) {
    print("BACK BUTTON!");
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.fade,
            child: CounselorHomeScreen(user: newUser)));
    return true;
  }

  Future<void> getEvents() async {
    final response = await http.get(
        'https://gennext.ml/api/counselor/get-sessions-calendar',
        headers: {
          HttpHeaders.authorizationHeader: 'Token $tok',
        });
    if (response.statusCode == 200) {
      return json.decode(response.body)['counselor_sessions'];
    } else {
      return ('error');
    }
  }

  Future<void> editSession(int id, String complete) async {
    final response = await http.put(
      'https://gennext.ml/api/counselor/edit-sessions-calendar',
      headers: {
        HttpHeaders.authorizationHeader: "Token $tok",
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode(
        <String, dynamic>{
          "session_id": id,
          "subject_of_session": _subject.text,
          "time_of_session": _newDateTime.toUtc().toIso8601String(),
          "session_notes": _notes.text,
          "session_duration": _duration.text,
          "session_complete": complete
        },
      ),
    );
    if (response.statusCode == 200) {
      if (json.decode(response.body)['response'] ==
          'Session Successfully edited!') {
        Navigator.pop(context);
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return AlertDialog(
              contentPadding: EdgeInsets.all(0),
              elevation: 20,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              content: Container(
                height: 150,
                width: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
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
                          'Session successfully edited!\nRespective students will be notified',
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
        setState(() {});
      } else {
        Navigator.pop(context);
        _error();
      }
    } else {
      Navigator.pop(context);
      _error();
    }
  }

  Future<void> deleteSession(int id) async {
    final response = await http.delete(
      'https://gennext.ml/api/counselor/delete-counselor-session/$id',
      headers: {
        HttpHeaders.authorizationHeader: "Token $tok",
      },
    );
    if (response.statusCode == 200) {
      if (json.decode(response.body)['Response'] ==
          'Session successfully deleted!') {
        Navigator.pop(context);
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return AlertDialog(
              contentPadding: EdgeInsets.all(0),
              elevation: 20,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              content: Container(
                height: 150,
                width: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
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
                          'Session successfully deleted!\nRespective students will be notified',
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
        setState(() {});
      } else {
        Navigator.pop(context);
        _error();
      }
    } else {
      Navigator.pop(context);
      _error();
    }
  }

  _loading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(0),
          elevation: 20,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          content: Container(
            height: 150,
            width: 80,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 50,
                    width: 50,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      strokeWidth: 3.0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 23.0),
                    child: Text(
                      "Saving your changes",
                      style: TextStyle(color: Colors.blue, fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
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
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          content: Container(
            height: 150,
            width: 80,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
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

  _editSession(String student, DateTime time, int id, String complete) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        _newDateTime = time;
        return AlertDialog(
          contentPadding: EdgeInsets.all(0),
          elevation: 20,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: Center(child: Text('Edit Session')),
          content: Container(
            width:MediaQuery.of(context).size.width,
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
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Divider(thickness: 0),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 25, right: 25),
                    child: Row(
                      children: <Widget>[
                        Text('Student: '),
                        Text(student, style: TextStyle(color: Colors.black54))
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10, left: 25, right: 25),
                    child: DateTimeField(
                      controller: _datetimecontroller,
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.blue, width: 0.0),
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
                            firstDate: DateTime(1900),
                            initialDate: currentValue ?? time,
                            lastDate: DateTime(2150));
                        if (_date != null) {
                          final _time = await showTimePicker(
                            context: context,
                            initialTime:
                                TimeOfDay.fromDateTime(currentValue ?? time),
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
                      controller: _subject,
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.blue, width: 0.0),
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
                    padding: EdgeInsets.only(top: 10, left: 25, right: 25),
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      controller: _duration,
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.blue, width: 0.0),
                        ),
                        labelText: 'Session Duration',
                        labelStyle: TextStyle(color: Colors.black54),
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Session duration is required to save';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10, left: 25, right: 25),
                    child: TextFormField(
                      keyboardType: TextInputType.multiline,
                      controller: _notes,
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.blue, width: 0.0),
                        ),
                        labelText: 'Session Notes',
                        labelStyle: TextStyle(color: Colors.black54),
                      ),
                      validator: (value) {
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
                'Save',
                style: TextStyle(color: Colors.blue),
              ),
              onPressed: () {
                Navigator.pop(context);
                editSession(id, complete);
                _loading();
              },
            ),
          ],
        );
      },
    );
  }

  _deleteSession(int id) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(0),
          elevation: 20,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          content: Container(
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Icon(
                    Icons.delete,
                    size: 40,
                    color: Colors.red.withOpacity(0.9),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    'Are you sure you want to delete this session?',
                    style: TextStyle(color: Colors.black, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.blue),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.pop(context);
                deleteSession(id);
                _loading();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scafKey,
      resizeToAvoidBottomPadding: false,
      backgroundColor: Colors.white,
      drawer: NavDrawer(
          name: newUser.firstname + ' ' + newUser.lastname,
          email: newUser.email),
      appBar: CustomAppBar('Calendar'),
      body: FutureBuilder(
        future: getEvents().timeout(Duration(seconds: 10)),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.error_outline,
                      size: 30,
                      color: Colors.red.withOpacity(0.6),
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
                    weekdayStyle: TextStyle(color: Colors.blue),
                    weekendStyle: TextStyle(color: Colors.blue),
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
                      expanded = false;
                      _selectedEvents = events;
                    });
                  },
                  builders: CalendarBuilders(
                    markersBuilder: (context, date, events, holidays) {
                      return [
                        Container(
                          margin: const EdgeInsets.all(2.0),
                          decoration: new BoxDecoration(
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
                        margin: const EdgeInsets.all(6.0),
                        decoration: new BoxDecoration(
                          border: Border.all(color: Colors.blue),
                          shape: BoxShape.circle,
                        ),
                        width: 100,
                        height: 100,
                        child: Center(
                          child: Text(
                            '${date.day}',
                            style: TextStyle(
                                fontSize: 17.0,
                                color: Colors.blue,
                                fontWeight: FontWeight.w900),
                          ),
                        ),
                      );
                    },
                    selectedDayBuilder: (context, date, _) {
                      return Container(
                        decoration: new BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black45,
                              blurRadius: 10,
                              offset: Offset(
                                3.0,
                                3.0,
                              ),
                            )
                          ],
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        margin: const EdgeInsets.all(2.0),
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
                Divider(
                  thickness: 0,
                ),
                Expanded(
                  child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: _selectedEvents.length,
                      itemBuilder: (context, index) {
                        DateTime timestamp =
                            DateTime.parse(_selectedEvents[index][7]);
                        String completed = _selectedEvents[index][6];
                        return Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: Card(
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15))),
                            elevation: 5,
                            child: ExpansionTile(
                              initiallyExpanded: expanded ?? false,
                              title: Padding(
                                padding: EdgeInsets.only(top: 5.0),
                                child: Text(_selectedEvents[index][2] +
                                    ' - ' +
                                    DateFormat.jm()
                                        .format(timestamp.toLocal())),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    '@' + _selectedEvents[index][3],
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                  if (completed == 'Yes') ...[
                                    Transform.scale(
                                      scale: 0.9,
                                      child: Chip(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30.0),
                                        ),
                                        padding: EdgeInsets.all(0),
                                        labelPadding:
                                            EdgeInsets.only(left: 3, right: 4),
                                        elevation: 2,
                                        backgroundColor: Colors.green,
                                        label: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(right: 3),
                                              child: Icon(
                                                Icons.check,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              'Completed',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                  if (completed == 'No') ...[
                                    Transform.scale(
                                      scale: 0.9,
                                      child: Chip(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30.0),
                                        ),
                                        padding: EdgeInsets.all(0),
                                        labelPadding:
                                            EdgeInsets.only(left: 3, right: 4),
                                        elevation: 2,
                                        backgroundColor: Colors.yellow[600],
                                        label: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(right: 3),
                                              child: Icon(
                                                Icons.access_time,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              'Pending',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ]
                                ],
                              ),
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(top: 5, left: 20),
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        'Session Subject: ',
                                        style: TextStyle(fontSize: 15),
                                      ),
                                      Text(
                                        _selectedEvents[index][4],
                                        style: TextStyle(color: Colors.black54),
                                      )
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 5, left: 20),
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        'Session Duration: ',
                                        style: TextStyle(fontSize: 15),
                                      ),
                                      Text(
                                        _selectedEvents[index][8].toString() +
                                            ' mins',
                                        style: TextStyle(color: Colors.black54),
                                      )
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 5, left: 20),
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        'Session Notes: ',
                                        style: TextStyle(fontSize: 15),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: 5, left: 30, right: 20),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Wrap(
                                      alignment: WrapAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          _selectedEvents[index][5],
                                          style:
                                              TextStyle(color: Colors.black54),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: 5, right: 20, bottom: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      ActionChip(
                                        pressElevation: 5,
                                        labelPadding:
                                            EdgeInsets.only(left: 5, right: 4),
                                        avatar: Padding(
                                          padding: EdgeInsets.only(left: 2),
                                          child: Icon(Icons.edit,
                                              color: Colors.white),
                                        ),
                                        elevation: 3,
                                        backgroundColor: Colors.blue,
                                        label: Text(
                                          'Edit',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        onPressed: () {
                                          _datetimecontroller.text =
                                              DateFormat.yMd()
                                                  .add_jm()
                                                  .format(timestamp.toLocal());
                                          _subject.text =
                                              _selectedEvents[index][4];
                                          _duration.text =
                                              _selectedEvents[index][8]
                                                  .toString();
                                          _notes.text =
                                              _selectedEvents[index][5];
                                          _editSession(
                                              _selectedEvents[index][2],
                                              timestamp.toLocal(),
                                              _selectedEvents[index][0],
                                              completed[0]);
                                        },
                                      ),
                                      Padding(
                                          padding: EdgeInsets.only(left: 10),
                                          child: ActionChip(
                                            pressElevation: 5,
                                            labelPadding: EdgeInsets.only(
                                                left: 3, right: 4),
                                            avatar: Padding(
                                              padding: EdgeInsets.only(left: 2),
                                              child: Icon(Icons.delete,
                                                  color: Colors.white),
                                            ),
                                            elevation: 3,
                                            backgroundColor: Colors.red,
                                            label: Text(
                                              'Delete',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            onPressed: () {
                                              _deleteSession(
                                                  _selectedEvents[index][0]);
                                            },
                                          ))
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                )
              ],
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}