import 'package:flutter/material.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:page_transition/page_transition.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import 'home.dart';

class ScheduleScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ScheduleScreenState();
}

class ScheduleScreenState extends State<ScheduleScreen> {
  CalendarController _calendarController;
  Map<DateTime, List<String>> _events;
  List _selectedEvents;

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
    BackButtonInterceptor.add(myInterceptor);
    _events = {
      DateTime(2020, 5, 5): [
        'Selected Day in the calendar!',
        'lmao',
        'lmao',
        'hello',
        'letsgo',
        'lmao'
      ],
      DateTime(2020, 5, 10): ['Selected Day in the calendar!'],
      DateTime(2020, 5, 22): ['Selected Day in the calendar!'],
      DateTime(2020, 5, 30): ['Selected Day in the calendar!'],
      DateTime(2020, 5, 26): ['Selected Day in the calendar!'],
    };
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

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.white,
      drawer: NavDrawer(
          name: newUser.firstname + ' ' + newUser.lastname,
          email: newUser.email),
      appBar: CustomAppBar('Calendar'),
      body: Column(
        children: <Widget>[
          TableCalendar(
            calendarController: _calendarController,
            locale: 'en_US',
            events: _events,
            initialCalendarFormat: CalendarFormat.month,
            formatAnimation: FormatAnimation.slide,
            startingDayOfWeek: StartingDayOfWeek.monday,
            availableGestures: AvailableGestures.all,
            availableCalendarFormats: const {
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
                    decoration: new BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    margin: const EdgeInsets.all(6.0),
                    width: 5,
                    height: 5,
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
                      elevation: 9,
                      child: ListTile(
                        title: Text(_selectedEvents[index]),
                      ),
                    ),
                  );
                }),
          )
        ],
      ),
    );
  }
}
