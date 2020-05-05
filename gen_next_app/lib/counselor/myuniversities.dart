import 'package:flutter/material.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:page_transition/page_transition.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../custom_expansion_tile.dart' as custom;
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
  GlobalKey<ScaffoldState> _scafKey = GlobalKey<ScaffoldState>();
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

  Future<void> getUniversities() async {
    final response = await http.get(
      'http://gennext.ml/api/counselor/get-connected-unis',
      headers: {HttpHeaders.authorizationHeader: "Token $tok"},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body)['my_connected_unis'];
    } else {
      return 'failed';
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scafKey,
      backgroundColor: Colors.white,
      drawer: NavDrawer(
          name: newUser.firstname + ' ' + newUser.lastname,
          email: newUser.email),
      appBar: CustomAppBar('My Universities'),
      body: RefreshIndicator(
        key: refreshKey,
        onRefresh: getUniversities,
        child: FutureBuilder(
          future: getUniversities(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: Scrollbar(
                  child: ListView.builder(
                      primary: true,
                      scrollDirection: Axis.vertical,
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
                          List unis = snapshot.data;
                          List<Widget> topmajors = [];
                          List<Widget> standoutfactors = [];
                          for (var i = 0;
                              i < unis[index]['top_majors'].length;
                              i++) {
                            topmajors.add(
                              Padding(
                                padding: EdgeInsets.only(right: 3),
                                child: Theme(
                                  data: ThemeData(
                                      canvasColor: Colors.transparent),
                                  child: Chip(
                                    labelPadding: EdgeInsets.only(
                                        left: 3, right: 3, top: 1, bottom: 1),
                                    elevation: 5,
                                    backgroundColor: Colors.black26,
                                    shape: StadiumBorder(
                                        side: BorderSide(color: Colors.blue)),
                                    label: Text(
                                      unis[index]['top_majors'][i],
                                      style: TextStyle(
                                          fontSize: 13, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                          for (var i = 0;
                              i < unis[index]['stand_out_factors'].length;
                              i++) {
                            standoutfactors.add(
                              Padding(
                                padding: EdgeInsets.only(right: 3),
                                child: Theme(
                                  data: ThemeData(
                                      canvasColor: Colors.transparent),
                                  child: Chip(
                                    labelPadding: EdgeInsets.only(
                                        left: 3, right: 3, top: 1, bottom: 1),
                                    elevation: 5,
                                    backgroundColor: Colors.black26,
                                    shape: StadiumBorder(
                                        side: BorderSide(color: Colors.blue)),
                                    label: Text(
                                      unis[index]['stand_out_factors'][i],
                                      style: TextStyle(
                                          fontSize: 13, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                          return Padding(
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
                                    "https://www.wpr.org/sites/default/files/bascom_hall_summer.jpg",
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
                                    key: Key(unis[index]['university_id']
                                        .toString()),
                                    title: Text(
                                      unis[index]['university_name'],
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    subtitle: Text(
                                      unis[index]['university_location'],
                                      style: TextStyle(
                                          color: Colors.white.withOpacity(0.8)),
                                    ),
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
                                                  unis[index]['university_rep'],
                                              style:
                                                  TextStyle(color: Colors.blue),
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
                                              unis[index]['university_location']
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
                                                  unis[index]
                                                          ['out_of_state_cost']
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
                                                  unis[index]
                                                          ['international_cost']
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
                                        padding: EdgeInsets.only(
                                            left: 20.0, right: 20, top: 5),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Container(
                                            height: 50,
                                            child: ListView(
                                              scrollDirection: Axis.horizontal,
                                              children: <Widget>[
                                                Row(
                                                  children: topmajors,
                                                )
                                              ],
                                            ),
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
                                            left: 20.0,
                                            right: 20,
                                            top: 5,
                                            bottom: 10),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Container(
                                            height: 50,
                                            child: ListView(
                                              scrollDirection: Axis.horizontal,
                                              children: <Widget>[
                                                Row(
                                                  children: standoutfactors,
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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
