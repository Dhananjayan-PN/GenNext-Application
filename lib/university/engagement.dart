import 'package:http/http.dart' as http;
import '../imports.dart';
import 'home.dart';

class StudentEngagementScreen extends StatefulWidget {
  @override
  _StudentEngagementScreenState createState() =>
      _StudentEngagementScreenState();
}

class _StudentEngagementScreenState extends State<StudentEngagementScreen> {
  GlobalKey<RefreshIndicatorState> refreshKey1 =
      GlobalKey<RefreshIndicatorState>();
  GlobalKey<RefreshIndicatorState> refreshKey2 =
      GlobalKey<RefreshIndicatorState>();
  GlobalKey<ScaffoldState> _scafKey = GlobalKey<ScaffoldState>();
  TextEditingController controller1 = TextEditingController();
  String filter1;
  TextEditingController controller2 = TextEditingController();
  String filter2;

  Future interested;
  Future applying;

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
    interested = getInterested();
    applying = getApplying();
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
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    return true;
  }

  Future<void> getInterested() async {
    String tok = await getToken();
    final response = await http.get(
      dom + 'api/university/get-interested-students',
      headers: {HttpHeaders.authorizationHeader: "Token $tok"},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body)['interested_students'];
    } else {
      throw 'failed';
    }
  }

  Future<void> getApplying() async {
    String tok = await getToken();
    final response = await http.get(
      dom + 'api/university/get-applications',
      headers: {HttpHeaders.authorizationHeader: "Token $tok"},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body)['application_data'];
    } else {
      throw 'failed';
    }
  }

  Widget buildInterestedCard(student) {
    return Card(
      margin: EdgeInsets.only(top: 7, left: 15, right: 15, bottom: 7),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      elevation: 6,
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          leading: CircleAvatar(
            radius: 25,
            backgroundImage: CachedNetworkImageProvider(student[
                    'profile_pic_url'] ??
                'https://www.pngfind.com/pngs/m/610-6104451_image-placeholder-png-user-profile-placeholder-image-png.png'),
            backgroundColor: Color(0xff005fa8),
          ),
          title: Padding(
            padding: EdgeInsets.only(top: 2, bottom: 2),
            child: Text('${student['student_name']}'),
          ),
          subtitle: Text(
            '@' + student['username'],
            style: TextStyle(
              color: Color(0xff005fa8),
            ),
          ),
          trailing: Padding(
            padding: EdgeInsets.only(right: 10),
            child: ClipOval(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  child: Icon(
                    Icons.mail_outline,
                    color: Color(0xff005fa8),
                  ),
                  onTap: () async {
                    if (await canLaunch('mailto:${student['email']}')) {
                      launch('mailto:${student['email']}');
                    } else {
                      await ClipboardManager.copyToClipBoard(
                          student['email'] ?? '');
                      _scafKey.currentState.showSnackBar(
                        SnackBar(
                          content: Text(
                            'Unable to open mail. Email copied to clipboard.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildApplyingCard(student) {
    String appString =
        student['completion_status'] ? 'Completed' : 'In Progress';
    Color appColor =
        student['completion_status'] ? Colors.green : Colors.orange;

    return Card(
      margin: EdgeInsets.only(top: 7, left: 15, right: 15, bottom: 7),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      elevation: 6,
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          key: Key(student['student_id'].toString()),
          leading: CircleAvatar(
            radius: 25,
            backgroundImage: CachedNetworkImageProvider(
                student['student_profile_image_url']),
            backgroundColor: Color(0xff005fa8),
          ),
          title: Padding(
            padding: EdgeInsets.only(top: 5, bottom: 2),
            child: Text(
              '${student['student_first_name']} ${student['student_last_name']}',
            ),
          ),
          subtitle: Text('Application ' + appString,
              style: TextStyle(color: appColor, fontSize: 13.5)),
          trailing: Padding(
            padding: EdgeInsets.only(right: 10),
            child: ClipOval(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  child: Icon(
                    Icons.mail_outline,
                    color: Color(0xff005fa8),
                  ),
                  onTap: () async {
                    if (await canLaunch('mailto:${student['student_email']}')) {
                      launch('mailto:${student['student_email']}');
                    } else {
                      await ClipboardManager.copyToClipBoard(
                          student['student_email']);
                      _scafKey.currentState.showSnackBar(
                        SnackBar(
                            content: Text(
                          'Unable to open mail. Email copied to clipboard.',
                          textAlign: TextAlign.center,
                        )),
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void refresh() {
    setState(() {
      interested = getInterested();
      applying = getApplying();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: _scafKey,
        backgroundColor: Colors.white,
        drawer: NavDrawer(),
        appBar: AppBar(
          backgroundColor: Color(0xff005fa8),
          elevation: 6,
          title: Text('Student Engagement'),
          bottom: TabBar(
            tabs: [
              Tab(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.star),
                    Padding(
                      padding: EdgeInsets.only(left: 6, top: 2),
                      child: Text('Interested'),
                    )
                  ],
                ),
              ),
              Tab(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.assignment),
                    Padding(
                      padding: EdgeInsets.only(left: 5),
                      child: Text('Applying'),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            RefreshIndicator(
              key: refreshKey1,
              onRefresh: () {
                refresh();
                return interested;
              },
              child: FutureBuilder(
                future: interested,
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
                                padding: EdgeInsets.only(bottom: 10),
                                child: Icon(
                                  Icons.star,
                                  size: 35,
                                  color: Colors.black.withOpacity(0.75),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: 5, left: 30, right: 30),
                                child: Text(
                                  "No students have shown interest in\nyour university yet.",
                                  style: TextStyle(color: Colors.black54),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 3),
                                child: Text(
                                    "Check back here later to see them show up.",
                                    style: TextStyle(color: Colors.black54),
                                    textAlign: TextAlign.center),
                              )
                            ],
                          ),
                        ),
                      );
                    } else {
                      return Scrollbar(
                        child: ListView.builder(
                          primary: true,
                          scrollDirection: Axis.vertical,
                          itemCount: snapshot.data.length + 1,
                          itemBuilder: (BuildContext context, int index) {
                            if (index == 0) {
                              return Padding(
                                padding: EdgeInsets.only(
                                    top: 5, left: 18, right: 30, bottom: 20),
                                child: Row(
                                  children: <Widget>[
                                    Padding(
                                      padding:
                                          EdgeInsets.only(top: 5, right: 6),
                                      child: Icon(
                                        Icons.search,
                                        size: 30,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    Expanded(
                                      child: TextField(
                                        cursorColor: Color(0xff005fa8),
                                        decoration: InputDecoration(
                                            labelText: "Search",
                                            contentPadding: EdgeInsets.all(2)),
                                        controller: controller1,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              return filter2 == null || filter2 == ""
                                  ? buildInterestedCard(
                                      snapshot.data[index - 1])
                                  : snapshot.data[index - 1]['student_name']
                                          .toLowerCase()
                                          .contains(filter2)
                                      ? buildInterestedCard(
                                          snapshot.data[index - 1])
                                      : snapshot.data[index - 1]
                                                  ['student_username']
                                              .toLowerCase()
                                              .contains(filter2)
                                          ? buildInterestedCard(
                                              snapshot.data[index - 1])
                                          : Container();
                            }
                          },
                        ),
                      );
                    }
                  }
                  return Padding(
                    padding: EdgeInsets.only(top: 20),
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
                return applying;
              },
              child: FutureBuilder(
                future: applying,
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
                                padding: EdgeInsets.only(bottom: 10),
                                child: Icon(
                                  Icons.assignment,
                                  size: 35,
                                  color: Colors.black.withOpacity(0.75),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: 5, left: 30, right: 30),
                                child: Text(
                                  "No students have started their application\nto your university yet.",
                                  style: TextStyle(color: Colors.black54),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 3),
                                child: Text(
                                    "Check back here later to see them show up.",
                                    style: TextStyle(color: Colors.black54),
                                    textAlign: TextAlign.center),
                              )
                            ],
                          ),
                        ),
                      );
                    } else {
                      return Scrollbar(
                        child: ListView.builder(
                          primary: true,
                          scrollDirection: Axis.vertical,
                          itemCount: snapshot.data.length + 1,
                          itemBuilder: (BuildContext context, int index) {
                            if (index == 0) {
                              return Padding(
                                padding: EdgeInsets.only(
                                    top: 5, left: 18, right: 30, bottom: 20),
                                child: Row(
                                  children: <Widget>[
                                    Padding(
                                      padding:
                                          EdgeInsets.only(top: 5, right: 6),
                                      child: Icon(
                                        Icons.search,
                                        size: 30,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    Expanded(
                                      child: TextField(
                                        cursorColor: Color(0xff005fa8),
                                        decoration: InputDecoration(
                                            labelText: "Search",
                                            contentPadding: EdgeInsets.all(2)),
                                        controller: controller2,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              String studentName = snapshot.data[index - 1]
                                      ['student_first_name'] +
                                  ' ' +
                                  snapshot.data[index - 1]['student_last_name'];
                              return filter2 == null || filter2 == ""
                                  ? buildApplyingCard(snapshot.data[index - 1])
                                  : studentName.toLowerCase().contains(filter2)
                                      ? buildApplyingCard(
                                          snapshot.data[index - 1])
                                      : snapshot.data[index - 1]
                                                  ['student_username']
                                              .toLowerCase()
                                              .contains(filter2)
                                          ? buildApplyingCard(
                                              snapshot.data[index - 1])
                                          : Container();
                            }
                          },
                        ),
                      );
                    }
                  }
                  return Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: CardListSkeleton(
                      isBottomLinesActive: false,
                      length: 10,
                    ),
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
