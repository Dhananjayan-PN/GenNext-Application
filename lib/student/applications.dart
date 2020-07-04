import 'package:flutter/material.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import '../shimmer_skeleton.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:page_transition/page_transition.dart';
// import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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
  Future pendingApps;

  @override
  void initState() {
    super.initState();
    controller1.addListener(() {
      setState(() {
        filter1 = controller1.text.toLowerCase();
      });
    });
    controller2.addListener(() {
      setState(() {
        filter2 = controller2.text.toLowerCase();
      });
    });
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
      return json.decode(response.body)['completed_application_data'];
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
      return json.decode(response.body)['incomplete_application_data'];
    } else {
      throw 'failed';
    }
  }

  Future<void> editApplication() async {}

  Future<void> deleteApplication(int id) async {
    final response = await http.delete(
      dom + 'api/student/delete-application/$id',
      headers: {HttpHeaders.authorizationHeader: "Token $tok"},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['Response'] == 'Essay successfully deleted.') {
        Navigator.pop(context);
        _success('delete');
        refresh();
      } else {
        Navigator.pop(context);
        _error();
      }
    } else {
      Navigator.pop(context);
      _error();
    }
  }

  _loading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(0),
          elevation: 20,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          content: Container(
            height: 150,
            width: 80,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 50,
                    width: 50,
                    child: SpinKitWave(
                      color: Colors.grey.withOpacity(0.8),
                      size: 25,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 23.0),
                    child: Text(
                      "Saving your changes",
                      style: TextStyle(color: Colors.black, fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  _error() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(0),
          elevation: 20,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          content: Container(
            height: 150,
            width: 80,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.error_outline,
                    size: 40,
                    color: Colors.red.withOpacity(0.9),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(
                      'Something went wrong.\nCheck your connection and try again later.',
                      style: TextStyle(color: Colors.black, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  _success(String op) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(0),
          elevation: 20,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          content: Container(
            height: 150,
            width: 80,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.check_circle_outline,
                    size: 40,
                    color: Colors.green,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(
                      op == 'delete'
                          ? 'Application successfully deleted\nTap + to make a new one'
                          : op == 'create'
                              ? 'Application successfully created\nGet working!'
                              : 'Application successfully edited!\nCome back anytime to make more changes',
                      style: TextStyle(color: Colors.black, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  _editApplication() {}

  _deleteApplication(int id) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(0),
          elevation: 20,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          content: Container(
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 18),
                  child: Icon(
                    Icons.delete,
                    size: 40,
                    color: Colors.red.withOpacity(0.9),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Text(
                    'Are you sure you want to delete\nthis application?',
                    style: TextStyle(color: Colors.black, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.blue),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.pop(context);
                deleteApplication(id);
                _loading();
              },
            ),
          ],
        );
      },
    );
  }

  void refresh() {
    setState(() {
      completedApps = getCompletedApplications();
      pendingApps = getPendingApplications();
    });
  }

  Widget buildCard(application) {
    DateTime deadline =
        DateTime.parse(application["application_deadline"]).toLocal();
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
      child: Material(
        shadowColor: Colors.grey.withOpacity(0.5),
        color: Colors.transparent,
        elevation: 8,
        child: Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))),
          elevation: 0,
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
              child: ListTile(
                isThreeLine: true,
                key: Key(application['application_id'].toString()),
                title: Padding(
                  padding: EdgeInsets.only(top: 1),
                  child: Text(
                    application['university'],
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
                      application["completion_status"]
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
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            )
                    ],
                  ),
                ),
                trailing: Wrap(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 8.0, top: 15),
                      child: PopupMenuButton(
                        child: Icon(
                          Icons.more_vert,
                          color: Colors.white,
                        ),
                        itemBuilder: (BuildContext context) {
                          return {'Edit', 'Delete'}.map((String choice) {
                            return PopupMenuItem<String>(
                              height: 35,
                              value: choice,
                              child: Text(choice,
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w400)),
                            );
                          }).toList();
                        },
                        onSelected: (value) async {
                          switch (value) {
                            case 'Edit':
                              // final List details = await Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) => NewEssayScreen(
                              //             op: 'Edit',
                              //             title: essay['essay_title'],
                              //             prompt: essay['essay_prompt'])));
                              // editEssayDetails(essay, details[0], details[1]);
                              // _loading();
                              break;
                            case 'Delete':
                              _deleteApplication(application['application_id']);
                              break;
                          }
                        },
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
          elevation: 6,
          title: Text(
            'My Applications',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: Platform.isIOS ? FontWeight.w500 : FontWeight.w400),
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
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 8),
              child: IconButton(
                icon: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 26,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    PageTransition(
                        type: PageTransitionType.fade,
                        child: NewApplicationScreen()),
                  );
                },
              ),
            )
          ],
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
                        padding: EdgeInsets.only(bottom: 100),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                  padding: EdgeInsets.only(
                                      top: 5, left: 30, right: 30),
                                  child: Text(
                                    "No Applications have been completed yet",
                                    style: TextStyle(color: Colors.black54),
                                    textAlign: TextAlign.center,
                                  )),
                              Padding(
                                padding: EdgeInsets.only(top: 3),
                                child: Text(
                                    "Complete a few from the 'Pending' tab to\nsee them show up here!",
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

class NewApplicationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: GradientAppBar(
          actions: <Widget>[
            FlatButton(
              child: Text(
                'DONE',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
          title: Text(
            'New Application',
            maxLines: 1,
            style: TextStyle(
                color: Colors.white,
                fontWeight: Platform.isIOS ? FontWeight.w500 : FontWeight.w400),
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xff00AEEF), Color(0xff0072BC)],
          ),
        ),
        body: Container());
  }
}
