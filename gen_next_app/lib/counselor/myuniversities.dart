import 'package:flutter/material.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:page_transition/page_transition.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'home.dart';

class MyUniversitiesScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyUniversitiesScreenState();
}

class MyUniversitiesScreenState extends State<MyUniversitiesScreen> {
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

  Future<void> getUniversities() async {
    final response = await http.get(
      'http://gennext.ml/api/counselor/get-connected-unis',
      headers: {HttpHeaders.authorizationHeader: "Token $tok"},
    );
    if (response.statusCode == 200) {
      print(json.decode(response.body));
      List myuniversities = json.decode(response.body)['my_connected_unis'];
      print(myuniversities);
      return myuniversities;
    } else {
      return 'failed';
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.white,
      drawer: NavDrawer(
          name: newUser.firstname + ' ' + newUser.lastname,
          email: newUser.email),
      appBar: CustomAppBar('My Universities'),
      body: FutureBuilder(
          future: getUniversities(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      List unis = snapshot.data;
                      List topmajors;
                      List standoutfactors;
                      for (var i = 0; i < unis[index]['top_majors']; i++) {
                        topmajors.add(
                          Chip(
                            backgroundColor: Colors.blue,
                            label: Text(
                              unis[index]['top_majors'][i],
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      }
                      for (var i = 0;
                          i < unis[index]['stand_out_factors'];
                          i++) {
                        standoutfactors.add(
                          Chip(
                            backgroundColor: Colors.blue,
                            label: Text(
                              unis[index]['stand_out_factors'][i],
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      }
                      return Padding(
                        padding:
                            const EdgeInsets.only(top: 5, left: 10, right: 10),
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15))),
                          elevation: 10,
                          child: ExpansionTile(
                            title: Text(unis[index]['university']),
                            subtitle: Text(
                              unis[index]['university_location'],
                              style: TextStyle(color: Colors.black54),
                            ),
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(
                                    top: 10, left: 20, bottom: 15),
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
                                      unis[index]['university_location'],
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
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      'Top Majors: ',
                                    ),
                                    Wrap(
                                      children: topmajors,
                                    )
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 5, left: 20),
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      'Stand Out Factors: ',
                                    ),
                                    Wrap(
                                      children: topmajors,
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
                                      r"$" + unis[index]['research_or_not'],
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
                                      r"$" + unis[index]['research_or_not'],
                                      style: TextStyle(color: Colors.black54),
                                    )
                                  ],
                                ),
                              ),
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
