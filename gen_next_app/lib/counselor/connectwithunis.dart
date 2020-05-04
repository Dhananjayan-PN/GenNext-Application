import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'home.dart';

class ConnectUniversitiesScreen extends StatefulWidget {
  @override
  _ConnectUniversitiesScreenState createState() =>
      _ConnectUniversitiesScreenState();
}

class _ConnectUniversitiesScreenState extends State<ConnectUniversitiesScreen> {
  GlobalKey<ScaffoldState> _scafKey = GlobalKey<ScaffoldState>();
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

  Future getAvailableUniversities() async {
    final response = await http.get(
      'http://gennext.ml/api/counselor/connect-with-unis',
      headers: {HttpHeaders.authorizationHeader: "Token $tok"},
    );
    if (response.statusCode == 200) {
      List availableuniversities = json.decode(response.body)['available_unis'];
      return availableuniversities;
    } else {
      return 'failed';
    }
  }

  Future sendRequest(int id) async {
    final response = await http.put(
      'https://gennext.ml/api/counselor/connect-with-unis/$id',
      headers: {HttpHeaders.authorizationHeader: "Token $tok"},
    );
    if (response.statusCode == 200) {
      if (json.decode(response.body)['Response'] ==
          'Request successfully sent!') {
        setState(() {
          addIcon = Icon(
            Icons.check,
            color: Colors.green,
            size: 40,
          );
        });
        _scafKey.currentState.showSnackBar(
          SnackBar(
            content: Text(
              'Request successfully sent!',
              textAlign: TextAlign.center,
            ),
          ),
        );
      } else {
        setState(() {
          addIcon = Icon(
            Icons.priority_high,
            color: Colors.red,
            size: 40,
          );
        });
        _scafKey.currentState.showSnackBar(
          SnackBar(
            content: Text(
              'Request failed. Try again later',
              textAlign: TextAlign.center,
            ),
          ),
        );
      }
    } else {
      setState(() {
        addIcon = Icon(
          Icons.error,
          color: Colors.red,
          size: 40,
        );
      });
      _scafKey.currentState.showSnackBar(
        SnackBar(
          content: Text(
            'Request failed. Try again later',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }

  String res;

  void requestSender(int id) async {
    setState(() {
      addIcon = CircularProgressIndicator();
    });
    Future.delayed(Duration(seconds: 2), () {
      sendRequest(id);
    });
  }

  Widget addIcon = Icon(
    Icons.add,
    color: Colors.blue,
    size: 40,
  );

  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scafKey,
      backgroundColor: Colors.white,
      drawer: NavDrawer(
          name: newUser.firstname + ' ' + newUser.lastname,
          email: newUser.email),
      appBar: CustomAppBar('Connect'),
      body: FutureBuilder(
          future: getAvailableUniversities(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      List unis = snapshot.data;
                      List<Widget> topmajors = [];
                      List<Widget> standoutfactors = [];
                      for (var i = 0;
                          i < unis[index]['top_majors'].length;
                          i++) {
                        topmajors.add(
                          Chip(
                            elevation: 5,
                            backgroundColor: Colors.blue,
                            label: Text(
                              unis[index]['top_majors'][i],
                              style:
                                  TextStyle(fontSize: 10, color: Colors.white),
                            ),
                          ),
                        );
                      }
                      for (var i = 0;
                          i < unis[index]['stand_out_factors'].length;
                          i++) {
                        standoutfactors.add(
                          Chip(
                            elevation: 5,
                            backgroundColor: Colors.blue,
                            label: Text(
                              unis[index]['stand_out_factors'][i],
                              style:
                                  TextStyle(fontSize: 10, color: Colors.white),
                            ),
                          ),
                        );
                      }
                      return Padding(
                        key: Key(unis[index]['university_id'].toString()),
                        padding:
                            const EdgeInsets.only(top: 5, left: 10, right: 10),
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15))),
                          elevation: 10,
                          child: ExpansionTile(
                            key: ValueKey(
                                unis[index]['university_id'].toString()),
                            leading: Padding(
                              padding: EdgeInsets.only(left: 0.0),
                              child: InkWell(
                                  child: addIcon,
                                  onTap: () {
                                    requestSender(unis[index]['university_id']);
                                  }),
                            ),
                            title: Text(unis[index]['university_name']),
                            subtitle: Text(
                              unis[index]['university_location'],
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
                                      'University Rep: ',
                                    ),
                                    Text(
                                      '@' + unis[index]['university_rep'],
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
                                      'US News Ranking: ',
                                    ),
                                    Text(
                                      unis[index]['usnews_ranking'].toString(),
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
                                      'Location: ',
                                    ),
                                    Text(
                                      unis[index]['university_location']
                                          .toString(),
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
                                      'In-State Cost: ',
                                    ),
                                    Text(
                                      r"$" +
                                          unis[index]['in_state_cost']
                                              .toString(),
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
                                      'Out-of-State Cost: ',
                                    ),
                                    Text(
                                      r"$" +
                                          unis[index]['out_of_state_cost']
                                              .toString(),
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
                                      'International Cost: ',
                                    ),
                                    Text(
                                      r"$" +
                                          unis[index]['international_cost']
                                              .toString(),
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
                                      'Research Institute?: ',
                                    ),
                                    Text(
                                      unis[index]['research_or_not'].toString(),
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
                                      'Both Grad and Undergrad?: ',
                                    ),
                                    Text(
                                      unis[index]['both_ug_and_g'].toString(),
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
                                      'Top Majors: ',
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 5, left: 20),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Wrap(
                                    spacing: 3,
                                    children: topmajors,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 5, left: 20),
                                child: Row(
                                  children: <Widget>[
                                    Text(
                                      'Stand Out Factors: ',
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: 5, left: 20, bottom: 10),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Wrap(
                                    spacing: 3,
                                    direction: Axis.horizontal,
                                    children: standoutfactors,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    }),
              );
            }
            return Center(child: CircularProgressIndicator());
          }),
    );
  }
}
