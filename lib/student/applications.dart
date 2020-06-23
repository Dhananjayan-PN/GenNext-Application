import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import '../shimmer_skeleton.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:page_transition/page_transition.dart';
import 'package:url_launcher/url_launcher.dart';
import '../custom_expansion_tile.dart' as custom;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'home.dart';

class ApplicationsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ApplicationsScreenState();
}

class ApplicationsScreenState extends State<ApplicationsScreen> {
  GlobalKey<ScaffoldState> _scafKey = GlobalKey<ScaffoldState>();
  var refreshKey1 = GlobalKey<RefreshIndicatorState>();
  var refreshKey2 = GlobalKey<RefreshIndicatorState>();
  TextEditingController controller1 = TextEditingController();
  TextEditingController controller2 = TextEditingController();
  String filter1;
  String filter2;
  Future completedApps;
  Future pendingApp;

  @override
  void initState() {
    super.initState();
    completedApps = getCompletedApplications();
    pendingApps = getPendingApplications();
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
            child: StudentHomeScreen(user: newUser)));
    return true;
  }

  Future<void> getCompletedApplications() async {
    final response = await http.get(
      dom + 'api/student/get-applications',
      headers: {HttpHeaders.authorizationHeader: "Token $tok"},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body)['application_data'];
    } else {
      throw 'failed';
    }
  }

  Future<void> getPendingApplications() async {
    final response = await http.get(
      dom + 'api/student/get-applications',
      headers: {HttpHeaders.authorizationHeader: "Token $tok"},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body)['application_data'];
    } else {
      throw 'failed';
    }
  }

  void refresh() {
    setState(() {
      completedApps = getCompletedApplications();
      pendingApps = getPendingApplications();
    });
  }

  Widget buildCard(uni) {
    List<Widget> essays = [];
    List<Widget> transcripts = [];
    List<Widget> misc = [];
    for (var i = 0; i < uni["essay_data"].length; i++) {
      final curEssay = uni["essay_data"][i];
      essays.add(Card(
        shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.white30, width: 1),
            borderRadius: BorderRadius.all(Radius.circular(10))),
        color: Colors.black.withOpacity(0.2),
        child: ListTile(
          dense: true,
          title: Text(
            curEssay["essay_title"],
            style: TextStyle(color: Colors.white),
          ),
          subtitle: curEssay["in_progress"] &&
                  curEssay["essay_approval_status"] == "Y"
              ? Text('Completed', style: TextStyle(color: Colors.green))
              : curEssay["in_progress"] &&
                      curEssay["essay_approval_status"] == "N"
                  ? Text('In Progress', style: TextStyle(color: Colors.yellow))
                  : Text('Not Started', style: TextStyle(color: Colors.red)),
          trailing: IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.arrow_forward,
              color: Colors.white,
            ),
          ),
        ),
      ));
    }
    for (var i = 0; i < uni["transcript_data"].length; i++) {
      final curTranscript = uni["transcript_data"][i];
      transcripts.add(Theme(
        data: ThemeData(canvasColor: Colors.black.withOpacity(0.3)),
        child: ActionChip(
          key: Key(curTranscript["transcript_id"].toString()),
          avatar: curTranscript["in_progress"]
              ? Icon(Icons.check, color: Colors.green)
              : Icon(Icons.priority_high, color: Colors.red),
          labelPadding: EdgeInsets.only(left: 2, right: 5),
          backgroundColor: Colors.black.withOpacity(0.2),
          shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.white30, width: 0.5),
              borderRadius: BorderRadius.all(Radius.circular(10))),
          label: Text(curTranscript["title"],
              style: TextStyle(color: Colors.white)),
          onPressed: () {
            curTranscript["in_progress"]
                ? launch(
                    curTranscript["transcript_file_path"] ??
                        'https://user-images.githubusercontent.com/1825286/26859182-9d8c266c-4afb-11e7-8913-93d29b3f47e5.png',
                    forceWebView: true,
                    enableJavaScript: true)
                : _scafKey.currentState.showSnackBar(
                    SnackBar(
                      content: Text(
                        'No Document Uploaded',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
          },
        ),
      ));
    }
    for (var i = 0; i < uni["misc_doc_data"].length; i++) {
      final curDoc = uni["misc_doc_data"][i];
      misc.add(Theme(
        data: ThemeData(canvasColor: Colors.black.withOpacity(0.3)),
        child: ActionChip(
          key: Key(curDoc["misc_doc_id"].toString()),
          avatar: curDoc["in_progress"]
              ? Icon(Icons.check, color: Colors.green)
              : Icon(Icons.priority_high, color: Colors.red),
          labelPadding: EdgeInsets.only(left: 2, right: 5),
          backgroundColor: Colors.black.withOpacity(0.2),
          shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.white30, width: 0.5),
              borderRadius: BorderRadius.all(Radius.circular(10))),
          label: Text(curDoc["title"], style: TextStyle(color: Colors.white)),
          onPressed: () {
            curDoc["in_progress"]
                ? launch(
                    curDoc["misc_doc_path"] ??
                        'https://user-images.githubusercontent.com/1825286/26859182-9d8c266c-4afb-11e7-8913-93d29b3f47e5.png',
                    forceWebView: true,
                    enableJavaScript: true)
                : _scafKey.currentState.showSnackBar(
                    SnackBar(
                      content: Text(
                        'No Document Uploaded',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
          },
        ),
      ));
    }
    DateTime deadline = DateTime.parse(uni["application_deadline"]).toLocal();
    var timeleft = DateTime.now().isBefore(deadline)
        ? deadline.difference(DateTime.now()).inDays
        : 'Passed';
    Color timecolor = timeleft is int && timeleft < 10
        ? Colors.red
        : Colors.white.withOpacity(0.9);
    if (timeleft is int) {
      timeleft = timeleft.toString() + ' days';
    }
    return Padding(
      padding: EdgeInsets.only(top: 5, left: 10, right: 10),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        elevation: 10,
        child: CachedNetworkImage(
          imageUrl:
              "https://www.wpr.org/sites/default/files/bascom_hall_summer.jpg",
          placeholder: (context, url) => CardSkeleton(
            padding: 0,
            isBottomLinesActive: false,
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
                colorFilter: ColorFilter.mode(
                    Colors.black.withAlpha(160), BlendMode.darken),
                image: imageProvider,
                fit: BoxFit.cover,
              ),
            ),
            child: custom.ExpansionTile(
              key: Key(uni['application_id'].toString()),
              title: Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  uni['university'],
                  style: TextStyle(color: Colors.white),
                ),
              ),
              subtitle: Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Due: ' +
                          DateFormat.yMMMMd('en_US')
                              .format(deadline.toLocal()) +
                          ' ($timeleft)',
                      style: TextStyle(fontSize: 14, color: timecolor),
                    ),
                    uni["completion_status"]
                        ? Text('Completed',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ))
                        : Text(
                            'Pending',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          )
                  ],
                ),
              ),
              children: <Widget>[
                Divider(
                  color: Colors.white70,
                  indent: 10,
                  endIndent: 10,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 5, left: 20),
                  child: Row(
                    children: <Widget>[
                      Text(
                        'Essays',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 25, right: 30, top: 5),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      runAlignment: WrapAlignment.start,
                      children: essays,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10, left: 20),
                  child: Row(
                    children: <Widget>[
                      Text(
                        'Transcripts',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 30, right: 30),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      runAlignment: WrapAlignment.start,
                      children: transcripts,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10, left: 20),
                  child: Row(
                    children: <Widget>[
                      Text(
                        'Misc Documents',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 30, right: 30),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      runAlignment: WrapAlignment.start,
                      children: misc,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 20),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        splashColor: Colors.blue[900],
                        child: Text('View University',
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.blue,
                                fontWeight: FontWeight.w900)),
                        onTap: () {},
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
            'My Applications',
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
                    Icon(Icons.assignment_turned_in),
                    Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Text('Completed'),
                    )
                  ])),
              Tab(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                    Icon(Icons.assignment_late),
                    Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Text('Pending'),
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
                return completedApps;
              },
              child: FutureBuilder(
                future: completedApps.timeout(Duration(seconds: 10)),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 40.0),
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
                              Padding(
                                  padding: EdgeInsets.only(
                                      top: 5, left: 30, right: 30),
                                  child: Text(
                                    "There aren't any completed applications at the time",
                                    style: TextStyle(color: Colors.black54),
                                    textAlign: TextAlign.center,
                                  )),
                              Padding(
                                padding: EdgeInsets.only(top: 3),
                                child: Text(
                                    "Complete a few from the 'Pending' tab to see them show up here!",
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
                                  padding: EdgeInsets.only(top: 5, right: 6),
                                  child: Icon(
                                    Icons.search,
                                    size: 30,
                                    color: Colors.black54,
                                  ),
                                ),
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                        labelText: "Search",
                                        contentPadding: EdgeInsets.all(2)),
                                    controller: controller1,
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
                                      return filter1 == null || filter1 == ""
                                          ? buildCard(snapshot.data[index])
                                          : snapshot.data[index]['university']
                                                  .toLowerCase()
                                                  .contains(filter1)
                                              ? buildCard(snapshot.data[index])
                                              : Container();
                                    }),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  }
                  return Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: CardListSkeleton(
                      isBottomLinesActive: false,
                      length: 10,
                    ),
                  );
                },
              ),
            ),
            RefreshIndicator(
              key: refreshKey2,
              onRefresh: () {
                refresh();
                return pendingApps;
              },
              child: FutureBuilder(
                future: pendingApps.timeout(Duration(seconds: 10)),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 40.0),
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
                                  padding: EdgeInsets.only(top: 5, right: 6),
                                  child: Icon(
                                    Icons.search,
                                    size: 30,
                                    color: Colors.black54,
                                  ),
                                ),
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                        labelText: "Search",
                                        contentPadding: EdgeInsets.all(2)),
                                    controller: controller2,
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
                                      return filter2 == null || filter2 == ""
                                          ? buildCard(snapshot.data[index])
                                          : snapshot.data[index]['university']
                                                  .toLowerCase()
                                                  .contains(filter2)
                                              ? buildCard(snapshot.data[index])
                                              : Container();
                                    }),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  }
                  return CardListSkeleton(
                    isBottomLinesActive: false,
                    length: 10,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
