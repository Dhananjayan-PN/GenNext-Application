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
  TextEditingController controller = new TextEditingController();
  String filter;

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
    controller.addListener(() {
      setState(() {
        filter = controller.text;
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
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

  Widget buildCard(AsyncSnapshot snapshot, index) {
    List students = snapshot.data;
    List<Widget> collegelist = [];
    for (var i = 0;
        i < students[index]['college_list'].split(':').length;
        i++) {
      collegelist.add(
        Padding(
          padding: EdgeInsets.only(right: 3),
          child: Chip(
            labelPadding: EdgeInsets.only(left: 3, right: 3, top: 1, bottom: 1),
            elevation: 5,
            backgroundColor: Colors.transparent,
            shape: StadiumBorder(side: BorderSide(color: Colors.blue)),
            label: Text(
              students[index]['college_list'].split(':')[i],
              style: TextStyle(fontSize: 13, color: Colors.black),
            ),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 5, left: 10, right: 10),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15))),
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
            style: TextStyle(color: Colors.blue),
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
                    'Email ID: ',
                  ),
                  Text(
                    students[index]['student_email'].toString(),
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
                    'Degree Level: ',
                  ),
                  Text(
                    students[index]['student_degree_level'].toString(),
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
                    'Major: ',
                  ),
                  Text(
                    students[index]['student_major'].toString(),
                    style: TextStyle(color: Colors.black54),
                  )
                ],
              ),
            ),
            if (students[index]['student_major'] == 'Undergraduate') ...[
              Padding(
                padding: EdgeInsets.only(top: 5, left: 20),
                child: Row(
                  children: <Widget>[
                    Text(
                      'School: ',
                    ),
                    Text(
                      students[index]['student_school'].toString(),
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
                      'Grade: ',
                    ),
                    Text(
                      students[index]['student_grade'].toString(),
                      style: TextStyle(color: Colors.black54),
                    )
                  ],
                ),
              ),
            ],
            if (students[index]['student_major'] == 'Graduate') ...[
              Padding(
                padding: EdgeInsets.only(top: 5, left: 20),
                child: Row(
                  children: <Widget>[
                    Text(
                      'University: ',
                    ),
                    Text(
                      students[index]['student_university'].toString(),
                      style: TextStyle(color: Colors.black54),
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
                    students[index]['student_country'].toString(),
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
                    'College List: ',
                  ),
                ],
              ),
            ),
            Padding(
              padding:
                  EdgeInsets.only(left: 20.0, right: 20, top: 5, bottom: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: <Widget>[
                      Row(
                        children: collegelist,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
          future: getMyStudents().timeout(Duration(seconds: 10)),
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
              return Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 5, left: 18, right: 30),
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 5, right: 6),
                          child: Icon(
                            Icons.search,
                            size: 30,
                            color: Colors.black54,
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            decoration: new InputDecoration(
                                labelText: "Search",
                                contentPadding: EdgeInsets.all(2)),
                            controller: controller,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Scrollbar(
                        child: ListView.builder(
                            itemCount: snapshot.data.length,
                            itemBuilder: (BuildContext context, int index) {
                              return filter == null || filter == ""
                                  ? buildCard(snapshot, index)
                                  : snapshot.data[index]['student_name']
                                          .toLowerCase()
                                          .contains(filter)
                                      ? buildCard(snapshot, index)
                                      : Container();
                            }),
                      ),
                    ),
                  ),
                ],
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
