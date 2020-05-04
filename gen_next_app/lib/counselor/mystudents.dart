import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'home.dart';

class MyStudentsScreen extends StatefulWidget {
  @override
  _MyStudentsScreenState createState() => _MyStudentsScreenState();
}

class _MyStudentsScreenState extends State<MyStudentsScreen> {
  var refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
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

  Future<void> getMyStudents() async {
    final response = await http.get(
      'http://gennext.ml/api/counselor/counseled-students',
      headers: {HttpHeaders.authorizationHeader: "Token $tok"},
    );
    if (response.statusCode == 200) {
      List mystudents = json.decode(response.body)['counseled_students'];
      return mystudents;
    } else {
      return 'failed';
    }
  }

  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.white,
      drawer: NavDrawer(
          name: newUser.firstname + ' ' + newUser.lastname,
          email: newUser.email),
      appBar: CustomAppBar('My Students'),
      body: RefreshIndicator(
        key: refreshKey,
        onRefresh: getMyStudents,
        child: FutureBuilder(
          future: getMyStudents(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Padding(
                padding: EdgeInsets.only(top: 10),
                child: Scrollbar(
                  child: ListView.builder(
                      itemCount: snapshot.data.length + 1,
                      itemBuilder: (BuildContext context, int index) {
                        if (index == snapshot.data.length) {
                          return Padding(
                            padding: EdgeInsets.only(top: 30.0, bottom: 10),
                            child: Center(
                              child: Text(
                                'Pull down from the top to refresh',
                                style: TextStyle(
                                    fontSize: 10, color: Colors.black54),
                              ),
                            ),
                          );
                        } else {
                          List students = snapshot.data;
                          List<Widget> collegelist = [];
                          for (var i = 0;
                              i <
                                  students[index]['college_list']
                                      .split(':')
                                      .length;
                              i++) {
                            collegelist.add(
                              Chip(
                                elevation: 5,
                                backgroundColor: Colors.transparent,
                                shape: StadiumBorder(
                                    side: BorderSide(color: Colors.blue)),
                                label: Text(
                                  students[index]['college_list'].split(':')[i],
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.black),
                                ),
                              ),
                            );
                          }
                          return Padding(
                            padding: const EdgeInsets.only(
                                top: 5, left: 10, right: 10),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15))),
                              elevation: 10,
                              child: ExpansionTile(
                                leading: CircleAvatar(
                                  radius: 25,
                                  backgroundImage: CachedNetworkImageProvider(
                                      'https://www.pngfind.com/pngs/m/610-6104451_image-placeholder-png-user-profile-placeholder-image-png.png'),
                                  backgroundColor: Colors.blue[400],
                                ),
                                title: Text(students[index]['student_name']),
                                subtitle: Text(
                                  '@' + students[index]['student_username'],
                                  style: TextStyle(color: Colors.black54),
                                ),
                                children: <Widget>[
                                  Divider(
                                    indent: 10,
                                    endIndent: 10,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 5, left: 20),
                                    child: Row(
                                      children: <Widget>[
                                        Text(
                                          'Date of Birth: ',
                                        ),
                                        Text(
                                          students[index]['student_dob'],
                                          style:
                                              TextStyle(color: Colors.black54),
                                        )
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 5, left: 20),
                                    child: Row(
                                      children: <Widget>[
                                        Text(
                                          'Email ID: ',
                                        ),
                                        Text(
                                          students[index]['student_email']
                                              .toString(),
                                          style:
                                              TextStyle(color: Colors.black54),
                                        )
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 5, left: 20),
                                    child: Row(
                                      children: <Widget>[
                                        Text(
                                          'Degree Level: ',
                                        ),
                                        Text(
                                          students[index]
                                                  ['student_degree_level']
                                              .toString(),
                                          style:
                                              TextStyle(color: Colors.black54),
                                        )
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 5, left: 20),
                                    child: Row(
                                      children: <Widget>[
                                        Text(
                                          'Major: ',
                                        ),
                                        Text(
                                          students[index]['student_major']
                                              .toString(),
                                          style:
                                              TextStyle(color: Colors.black54),
                                        )
                                      ],
                                    ),
                                  ),
                                  if (students[index]['student_major'] ==
                                      'Undergraduate') ...[
                                    Padding(
                                      padding:
                                          EdgeInsets.only(top: 5, left: 20),
                                      child: Row(
                                        children: <Widget>[
                                          Text(
                                            'School: ',
                                          ),
                                          Text(
                                            students[index]['student_school']
                                                .toString(),
                                            style: TextStyle(
                                                color: Colors.black54),
                                          )
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.only(top: 5, left: 20),
                                      child: Row(
                                        children: <Widget>[
                                          Text(
                                            'Grade: ',
                                          ),
                                          Text(
                                            students[index]['student_grade']
                                                .toString(),
                                            style: TextStyle(
                                                color: Colors.black54),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                  if (students[index]['student_major'] ==
                                      'Graduate') ...[
                                    Padding(
                                      padding:
                                          EdgeInsets.only(top: 5, left: 20),
                                      child: Row(
                                        children: <Widget>[
                                          Text(
                                            'University: ',
                                          ),
                                          Text(
                                            students[index]
                                                    ['student_university']
                                                .toString(),
                                            style: TextStyle(
                                                color: Colors.black54),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                  Padding(
                                    padding: EdgeInsets.only(top: 5, left: 20),
                                    child: Row(
                                      children: <Widget>[
                                        Text(
                                          'Country: ',
                                        ),
                                        Text(
                                          students[index]['student_country']
                                              .toString(),
                                          style:
                                              TextStyle(color: Colors.black54),
                                        )
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 5, left: 20),
                                    child: Row(
                                      children: <Widget>[
                                        Text(
                                          'College List: ',
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: 5, bottom: 10, left: 20),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Wrap(
                                        spacing: 3,
                                        children: collegelist,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      }),
                ),
              );
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}
