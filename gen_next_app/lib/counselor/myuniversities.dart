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
                      return Padding(
                        padding:
                            const EdgeInsets.only(top: 5, left: 10, right: 10),
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15))),
                          elevation: 10,
                          child: ExpansionTile(
                            title: Text(snapshot.data[index]['university']),
                            subtitle: Text(
                              'Ithaca, NY',
                              style: TextStyle(color: Colors.black54),
                            ),
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(top: 5, left: 20),
                                child: Row(
                                  children: <Widget>[
                                    Text(
                                      'ID: ',
                                    ),
                                    Text(
                                      snapshot.data[index]['university_id']
                                          .toString(),
                                      style: TextStyle(color: Colors.black54),
                                    )
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: 10, left: 20, bottom: 15),
                                child: Row(
                                  children: <Widget>[
                                    Text(
                                      'University Rep: ',
                                    ),
                                    Text(
                                      '@' +
                                          snapshot.data[index]
                                              ['university_rep'],
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
