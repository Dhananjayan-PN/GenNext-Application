import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import '../custom_expansion_tile.dart' as custom;
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
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  List unis;

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

  Future sendRequest(int id, int index) async {
    final response = await http.put(
      'https://gennext.ml/api/counselor/connect-with-unis/$id',
      headers: {HttpHeaders.authorizationHeader: "Token $tok"},
    );
    if (response.statusCode == 200) {
      if (json.decode(response.body)['Response'] ==
          'Request successfully sent!') {
        unis[index]['request_sent'] = true;
        _scafKey.currentState.showSnackBar(
          SnackBar(
            content: Text(
              'Request successfully sent!',
              textAlign: TextAlign.center,
            ),
          ),
        );
      } else {
        unis[index]['request_failed'] = true;
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
      unis[index]['request_failed'] = true;
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

  void requestSender(int id, int index) async {
    Future.delayed(Duration(milliseconds: 200), () {
      sendRequest(id, index);
    });
  }

  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scafKey,
      backgroundColor: Colors.white,
      drawer: NavDrawer(
          name: newUser.firstname + ' ' + newUser.lastname,
          email: newUser.email),
      appBar: CustomAppBar('Connect'),
      body: RefreshIndicator(
        key: refreshKey,
        onRefresh: getAvailableUniversities,
        child: FutureBuilder(
            future: getAvailableUniversities(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: snapshot.data.length,
                          itemBuilder: (BuildContext context, int index) {
                            unis = snapshot.data;
                            unis[index]['request_failed'] = false;
                            unis[index]['requesting'] = false;
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
                                    style: TextStyle(
                                        fontSize: 10, color: Colors.white),
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
                                    style: TextStyle(
                                        fontSize: 10, color: Colors.white),
                                  ),
                                ),
                              );
                            }
                            return Padding(
                              key: Key(unis[index]['university_id'].toString()),
                              padding: const EdgeInsets.only(
                                  top: 5, left: 10, right: 10),
                              child: Card(
                                clipBehavior: Clip.antiAlias,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15))),
                                elevation: 10,
                                child: CachedNetworkImage(
                                  imageUrl:
                                      "https://luskinconferencecenter.ucla.edu/wp-content/uploads/2018/03/Blog_Luskin.jpg",
                                  placeholder: (context, url) => Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(
                                        child: CircularProgressIndicator()),
                                  ),
                                  errorWidget: (context, url, error) {
                                    _scafKey.currentState.showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Failed to fetch data. Check your internet connection and try again',
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    );
                                    return Icon(Icons.error);
                                  },
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        alignment: Alignment.center,
                                        colorFilter: new ColorFilter.mode(
                                            Colors.black.withAlpha(160),
                                            BlendMode.darken),
                                        image: imageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    child: custom.ExpansionTile(
                                      key: ValueKey(unis[index]['university_id']
                                          .toString()),
                                      leading: Padding(
                                        padding: EdgeInsets.only(left: 0.0),
                                        child: InkWell(
                                            child: unis[index]['request_sent']
                                                ? Icon(
                                                    Icons.check,
                                                    color: Colors.green,
                                                    size: 40,
                                                  )
                                                : unis[index]['request_failed']
                                                    ? Icon(
                                                        Icons.priority_high,
                                                        color: Colors.red,
                                                        size: 40,
                                                      )
                                                    : unis[index]['requesting']
                                                        ? CircularProgressIndicator()
                                                        : Icon(
                                                            Icons.add,
                                                            color: Colors.blue,
                                                            size: 40,
                                                          ),
                                            onTap: () {
                                              if (unis[index]['request_sent']) {
                                                _scafKey.currentState
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Request already sent',
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                unis[index]['requesting'] =
                                                    true;
                                                requestSender(
                                                    unis[index]
                                                        ['university_id'],
                                                    index);
                                              }
                                            }),
                                      ),
                                      title: Text(
                                        unis[index]['university_name'],
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      subtitle: Text(
                                          unis[index]['university_location'],
                                          style: TextStyle(
                                              color: Colors.white
                                                  .withOpacity(0.8))),
                                      children: <Widget>[
                                        Divider(
                                          color: Colors.white70,
                                          indent: 10,
                                          endIndent: 10,
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsets.only(top: 5, left: 20),
                                          child: Row(
                                            children: <Widget>[
                                              Text(
                                                'University Rep: ',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              Text(
                                                '@' +
                                                    unis[index]
                                                        ['university_rep'],
                                                style: TextStyle(
                                                    color: Colors.blue),
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
                                                'US News Ranking: ',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              Text(
                                                unis[index]['usnews_ranking']
                                                    .toString(),
                                                style: TextStyle(
                                                    color: Colors.white
                                                        .withOpacity(0.8)),
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
                                                'Location: ',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              Text(
                                                unis[index]
                                                        ['university_location']
                                                    .toString(),
                                                style: TextStyle(
                                                    color: Colors.white
                                                        .withOpacity(0.8)),
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
                                                'In-State Cost: ',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              Text(
                                                r"$" +
                                                    unis[index]['in_state_cost']
                                                        .toString(),
                                                style: TextStyle(
                                                    color: Colors.white
                                                        .withOpacity(0.8)),
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
                                                'Out-of-State Cost: ',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              Text(
                                                r"$" +
                                                    unis[index][
                                                            'out_of_state_cost']
                                                        .toString(),
                                                style: TextStyle(
                                                    color: Colors.white
                                                        .withOpacity(0.8)),
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
                                                'International Cost: ',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              Text(
                                                r"$" +
                                                    unis[index][
                                                            'international_cost']
                                                        .toString(),
                                                style: TextStyle(
                                                    color: Colors.white
                                                        .withOpacity(0.8)),
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
                                                'Research Institute?: ',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              Text(
                                                unis[index]['research_or_not']
                                                    .toString(),
                                                style: TextStyle(
                                                    color: Colors.white
                                                        .withOpacity(0.8)),
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
                                                'Both Grad and Undergrad?: ',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              Text(
                                                unis[index]['both_ug_and_g']
                                                    .toString(),
                                                style: TextStyle(
                                                    color: Colors.white
                                                        .withOpacity(0.8)),
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
                                                'Top Majors: ',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsets.only(top: 5, left: 20),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Wrap(
                                              spacing: 3,
                                              children: topmajors,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsets.only(top: 5, left: 20),
                                          child: Row(
                                            children: <Widget>[
                                              Text(
                                                'Stand Out Factors: ',
                                                style: TextStyle(
                                                    color: Colors.white),
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
                                              children: standoutfactors,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 30.0),
                      child: Center(
                        child: Text(
                          'Pull down to refresh',
                          style: TextStyle(fontSize: 10, color: Colors.black54),
                        ),
                      ),
                    )
                  ],
                );
              }
              return Center(child: CircularProgressIndicator());
            }),
      ),
    );
  }
}
