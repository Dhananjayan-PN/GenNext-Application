import 'package:flutter/material.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:page_transition/page_transition.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../custom_expansion_tile.dart' as custom;
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'home.dart';

class AllUniversitiesScreen extends StatefulWidget {
  @override
  _AllUniversitiesScreenState createState() => _AllUniversitiesScreenState();
}

class _AllUniversitiesScreenState extends State<AllUniversitiesScreen> {
  GlobalKey<ScaffoldState> _scafKey = GlobalKey<ScaffoldState>();
  var refreshKey1 = GlobalKey<RefreshIndicatorState>();
  var refreshKey2 = GlobalKey<RefreshIndicatorState>();
  TextEditingController controller = new TextEditingController();
  String filter;
  List unis;
  Future allUniList;
  Future recoUniList;

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
    controller.addListener(() {
      setState(() {
        filter = controller.text;
      });
    });
    allUniList = getAllUniversities();
    recoUniList = getRecommended();
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
            child: StudentHomeScreen(
              user: newUser,
            )));
    return true;
  }

  Future<void> getAllUniversities() async {
    final response = await http.get(
      dom + 'api/student/get-all-universities',
      headers: {HttpHeaders.authorizationHeader: "Token $tok"},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body)['university_data'];
    } else {
      throw 'failed';
    }
  }

  Future<void> getRecommended() async {
    final response = await http.get(
      dom + 'api/student/recommend-universities',
      headers: {HttpHeaders.authorizationHeader: "Token $tok"},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body)['recommended_universities'];
    } else {
      throw 'failed';
    }
  }

  void refresh() {
    setState(() {
      allUniList = getAllUniversities();
      recoUniList = getRecommended();
    });
  }

  Widget buildCard(snapshot, int index) {
    var _isStarred = true;
    unis = snapshot;
    List<Widget> topmajors = [];
    List<Widget> standoutfactors = [];
    List<Widget> degreelevels = [];
    List<Widget> testing = [];
    for (var i = 0; i < unis[index]['top_majors'].length; i++) {
      topmajors.add(
        Padding(
          padding: EdgeInsets.only(right: 3),
          child: Theme(
            data: ThemeData(canvasColor: Colors.transparent),
            child: Chip(
              labelPadding:
                  EdgeInsets.only(left: 3, right: 3, top: 1, bottom: 1),
              elevation: 5,
              backgroundColor: Colors.black26,
              shape: StadiumBorder(side: BorderSide(color: Colors.blue)),
              label: Text(
                unis[index]['top_majors'][i],
                style: TextStyle(fontSize: 13, color: Colors.white),
              ),
            ),
          ),
        ),
      );
    }
    for (var i = 0; i < unis[index]['stand_out_factors'].length; i++) {
      standoutfactors.add(
        Padding(
          padding: EdgeInsets.only(right: 3),
          child: Theme(
            data: ThemeData(canvasColor: Colors.transparent),
            child: Chip(
              labelPadding:
                  EdgeInsets.only(left: 3, right: 3, top: 1, bottom: 1),
              elevation: 5,
              backgroundColor: Colors.black26,
              shape: StadiumBorder(side: BorderSide(color: Colors.blue)),
              label: Text(
                unis[index]['stand_out_factors'][i],
                style: TextStyle(fontSize: 13, color: Colors.white),
              ),
            ),
          ),
        ),
      );
    }
    for (var i = 0; i < unis[index]['degree_levels'].length; i++) {
      degreelevels.add(
        Padding(
          padding: EdgeInsets.only(right: 3),
          child: Theme(
            data: ThemeData(canvasColor: Colors.transparent),
            child: Chip(
              labelPadding:
                  EdgeInsets.only(left: 3, right: 3, top: 1, bottom: 1),
              elevation: 5,
              backgroundColor: Colors.black26,
              shape: StadiumBorder(side: BorderSide(color: Colors.blue)),
              label: Text(
                unis[index]['degree_levels'][i],
                style: TextStyle(fontSize: 13, color: Colors.white),
              ),
            ),
          ),
        ),
      );
    }
    for (var i = 0; i < unis[index]['testing_requirements'].length; i++) {
      testing.add(
        Padding(
          padding: EdgeInsets.only(right: 3),
          child: Theme(
            data: ThemeData(canvasColor: Colors.transparent),
            child: Chip(
              labelPadding:
                  EdgeInsets.only(left: 3, right: 3, top: 1, bottom: 1),
              elevation: 5,
              backgroundColor: Colors.black26,
              shape: StadiumBorder(side: BorderSide(color: Colors.blue)),
              label: Text(
                unis[index]['testing_requirements'][i],
                style: TextStyle(fontSize: 13, color: Colors.white),
              ),
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
            borderRadius: BorderRadius.all(Radius.circular(10))),
        elevation: 10,
        child: CachedNetworkImage(
          imageUrl:
              "https://www.wpr.org/sites/default/files/bascom_hall_summer.jpg",
          placeholder: (context, url) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(child: CircularProgressIndicator()),
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
          imageBuilder: (context, imageProvider) => Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                alignment: Alignment.center,
                colorFilter: new ColorFilter.mode(
                    Colors.black.withAlpha(160), BlendMode.darken),
                image: imageProvider,
                fit: BoxFit.cover,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: ListTile(
                key: Key(unis[index]['university_id'].toString()),
                title: Text(
                  unis[index]['university_name'],
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  unis[index]['university_location'],
                  style: TextStyle(color: Colors.white.withOpacity(0.8)),
                ),
                trailing: Wrap(
                  children: <Widget>[
                    InkWell(
                      child: _isStarred
                          ? Icon(Icons.star, color: Colors.white)
                          : Icon(Icons.star_border, color: Colors.white),
                      onTap: () {
                        setState(() {
                          _isStarred = !_isStarred;
                        });
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: InkWell(
                        child: Icon(
                          Icons.more_vert,
                          color: Colors.white,
                        ),
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: _scafKey,
        backgroundColor: Colors.white,
        drawer: NavDrawer(
            name: newUser.firstname + ' ' + newUser.lastname,
            email: newUser.email),
        appBar: GradientAppBar(
          elevation: 20,
          title: Text(
            'Explore',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xff00AEEF), Color(0xff0072BC)]),
          bottom: TabBar(
            tabs: [
              Tab(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                    Icon(Icons.assessment),
                    Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Text('Recommended'),
                    )
                  ])),
              Tab(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                    Icon(Icons.all_inclusive),
                    Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Text('All Universities'),
                    )
                  ])),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            RefreshIndicator(
              key: refreshKey1,
              onRefresh: () {
                refresh();
                return recoUniList;
              },
              child: FutureBuilder(
                future: recoUniList.timeout(Duration(seconds: 10)),
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
                    if (snapshot.data.length == 0) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 70),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(Icons.sentiment_satisfied),
                              Padding(
                                  padding: EdgeInsets.only(
                                      top: 5, left: 30, right: 30),
                                  child: Text(
                                    "There aren't any recommendations\nat the moment",
                                    style: TextStyle(color: Colors.black54),
                                    textAlign: TextAlign.center,
                                  )),
                              Padding(
                                padding: EdgeInsets.only(top: 3),
                                child: Text(
                                    "Come back later to explore your recommendations!",
                                    style: TextStyle(color: Colors.black54),
                                    textAlign: TextAlign.center),
                              )
                            ],
                          ),
                        ),
                      );
                    } else {
                      return Column(
                        children: <Widget>[
                          Padding(
                            padding:
                                EdgeInsets.only(top: 5, left: 18, right: 30),
                            child: Row(
                              children: <Widget>[
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 5, right: 6),
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
                              padding: EdgeInsets.only(top: 20.0),
                              child: Scrollbar(
                                child: ListView.builder(
                                    primary: true,
                                    scrollDirection: Axis.vertical,
                                    itemCount: snapshot.data.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return filter == null || filter == ""
                                          ? buildCard(snapshot.data, index)
                                          : snapshot.data[index]
                                                      ['university_name']
                                                  .toLowerCase()
                                                  .contains(filter)
                                              ? buildCard(snapshot.data, index)
                                              : Container();
                                    }),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  }
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
            RefreshIndicator(
              key: refreshKey2,
              onRefresh: () {
                refresh();
                return allUniList;
              },
              child: FutureBuilder(
                future: allUniList.timeout(Duration(seconds: 10)),
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
                    if (snapshot.data.length == 0) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 70),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Opacity(
                                opacity: 0.9,
                                child: Image.asset(
                                  "images/snap.gif",
                                  height: 100.0,
                                  width: 100.0,
                                ),
                              ),
                              Text(
                                'Oh Snap!',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.black54),
                              ),
                              Padding(
                                  padding: EdgeInsets.only(
                                      top: 5, left: 30, right: 30),
                                  child: Text(
                                    "Looks like you haven't added\nany universites yet :(",
                                    style: TextStyle(color: Colors.black54),
                                    textAlign: TextAlign.center,
                                  )),
                              Padding(
                                padding: EdgeInsets.only(top: 3),
                                child: Text(
                                    "Head over to the 'Explore Universities' section to get started!",
                                    style: TextStyle(color: Colors.black54),
                                    textAlign: TextAlign.center),
                              )
                            ],
                          ),
                        ),
                      );
                    } else {
                      return Column(
                        children: <Widget>[
                          Padding(
                            padding:
                                EdgeInsets.only(top: 5, left: 18, right: 30),
                            child: Row(
                              children: <Widget>[
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 5, right: 6),
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
                              padding: EdgeInsets.only(top: 20.0),
                              child: Scrollbar(
                                child: ListView.builder(
                                    primary: true,
                                    scrollDirection: Axis.vertical,
                                    itemCount: snapshot.data.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return filter == null || filter == ""
                                          ? buildCard(snapshot.data, index)
                                          : snapshot.data[index]
                                                      ['university_name']
                                                  .toLowerCase()
                                                  .contains(filter)
                                              ? buildCard(snapshot.data, index)
                                              : Container();
                                    }),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  }
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
