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
  CalendarController _calendarController;
  Map<DateTime, List<List<dynamic>>> _events;
  List _selectedEvents;

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
        headers: {HttpHeaders.authorizationHeader: 'Token $tok'});
    if (response.statusCode == 200) {
      return json.decode(response.body)['counselor_sessions'];
    } else {
      return ('error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
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
              DateTime timestamp = DateTime.parse(session['session_timestamp']);
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
            _events = {};
            for (var i = 0; i < snapshot.data.length; i++) {
              Map<String, dynamic> session = snapshot.data[i];
              DateTime timestamp = DateTime.parse(session['session_timestamp']);
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
                    titleTextStyle: TextStyle(fontSize: 20),
                    centerHeaderTitle: true,
                  ),
                  headerVisible: true,
                  onDaySelected: (date, events) {
                    setState(() {
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
                  thickness: 1,
                ),
                Expanded(
                  child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: _selectedEvents.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15))),
                            elevation: 5,
                            child: ExpansionTile(
                              title: Text(_selectedEvents[index][2]),
                              subtitle: Text(_selectedEvents[index][3]),
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
