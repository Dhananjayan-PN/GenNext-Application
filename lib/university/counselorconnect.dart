import 'package:http/http.dart' as http;
import '../imports.dart';
import 'home.dart';

class CounselorConnectScreen extends StatefulWidget {
  @override
  _CounselorConnectScreenState createState() => _CounselorConnectScreenState();
}

class _CounselorConnectScreenState extends State<CounselorConnectScreen> {
  GlobalKey<RefreshIndicatorState> refreshKey1 =
      GlobalKey<RefreshIndicatorState>();
  GlobalKey<RefreshIndicatorState> refreshKey2 =
      GlobalKey<RefreshIndicatorState>();
  GlobalKey<ScaffoldState> _scafKey = GlobalKey<ScaffoldState>();
  TextEditingController controller = TextEditingController();

  String filter;

  Future requests;
  Future connected;

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
    requests = getCounselorRequests();
    connected = getConnectedCounselors();
    controller.addListener(() {
      setState(() {
        filter = controller.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    return true;
  }

  Future<void> getCounselorRequests() async {
    String tok = await getToken();
    final response = await http.get(
      dom + 'api/university/get-pending-counselor-reqs',
      headers: {HttpHeaders.authorizationHeader: "Token $tok"},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body)['pending_counselor_reqs_data'];
    } else {
      throw 'failed';
    }
  }

  Future<void> getConnectedCounselors() async {
    String tok = await getToken();
    final response = await http.get(
      dom + 'api/university/get-connected-counselors',
      headers: {HttpHeaders.authorizationHeader: "Token $tok"},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body)['connected_counselor_data'];
    } else {
      throw 'failed';
    }
  }

  Future<void> sendRequestDecision(int id, String decision) async {
    String tok = await getToken();
    final response = await http.put(
      dom + 'api/university/decision-for-counselor-req/$id/$decision',
      headers: {
        HttpHeaders.authorizationHeader: "Token $tok",
        'Content-Type': 'application/json; charset=UTF-8',
      },
    ).timeout(Duration(seconds: 10));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (decision == 'A' &&
          data['Response'] == 'Counselor request successfully accepted.') {
        Navigator.pop(context);
        refresh();
        _scafKey.currentState.showSnackBar(
          SnackBar(
              content: Text(
            'Request Accepted',
            textAlign: TextAlign.center,
          )),
        );
      } else if (decision == 'R' &&
          data['Response'] == 'Counselor request successfully denied.') {
        Navigator.pop(context);
        refresh();
        _scafKey.currentState.showSnackBar(
          SnackBar(
              content: Text(
            'Request Denied',
            textAlign: TextAlign.center,
          )),
        );
      } else {
        Navigator.pop(context);
        error(context);
      }
    } else {
      Navigator.pop(context);
      error(context);
    }
  }

  Widget buildRequestCard(request) {
    return Card(
      margin: EdgeInsets.only(top: 7, left: 15, right: 15, bottom: 7),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      elevation: 6,
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          key: Key(request['user_id'].toString()),
          leading: CircleAvatar(
            radius: 25,
            backgroundImage:
                CachedNetworkImageProvider(request['profile_image_url']),
            backgroundColor: Color(0xff005fa8),
          ),
          title: Padding(
            padding: EdgeInsets.only(top: 2, bottom: 2),
            child: Text(request['name']),
          ),
          subtitle: Text(
            '@' + request['username'],
            style: TextStyle(
              color: Color(0xff005fa8),
            ),
          ),
          trailing: Wrap(
            children: <Widget>[
              ClipOval(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    child: Icon(
                      Icons.check,
                      color: Colors.green,
                    ),
                    onTap: () {
                      sendRequestDecision(request['user_id'], 'A');
                      loading(context);
                    },
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 12),
                child: ClipOval(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      child: Icon(
                        Icons.close,
                        color: Colors.red,
                      ),
                      onTap: () {
                        sendRequestDecision(request['user_id'], 'R');
                        loading(context);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCounselorCard(counselor) {
    return Card(
      margin: EdgeInsets.only(top: 7, left: 15, right: 15, bottom: 7),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      elevation: 6,
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          key: Key(counselor['username'].toString()),
          leading: CircleAvatar(
            radius: 25,
            backgroundImage:
                CachedNetworkImageProvider(counselor['profile_image_url']),
            backgroundColor: Color(0xff005fa8),
          ),
          title: Padding(
            padding: EdgeInsets.only(top: 2, bottom: 2),
            child: Text(counselor['name']),
          ),
          subtitle: Text(
            '@' + counselor['username'],
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
                    if (await canLaunch('mailto:${counselor['email']}')) {
                      launch('mailto:${counselor['email']}');
                    } else {
                      await ClipboardManager.copyToClipBoard(
                          counselor['email']);
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
      requests = getCounselorRequests();
      connected = getConnectedCounselors();
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
          title: Text('Counselor Connect'),
          bottom: TabBar(
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.hourglass_empty),
                    Padding(
                      padding: EdgeInsets.only(left: 3.0),
                      child: Text('Requests'),
                    )
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.insert_link),
                    Padding(
                      padding: EdgeInsets.only(left: 3.0),
                      child: Text('Connected'),
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
                return requests;
              },
              child: FutureBuilder(
                future: requests,
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
                                  "There are no pending requests at the moment.",
                                  style: TextStyle(color: Colors.black54),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 3),
                                child: Text(
                                    "Check back here to see them show up.",
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
                          padding: EdgeInsets.only(top: 20, bottom: 20),
                          primary: true,
                          scrollDirection: Axis.vertical,
                          itemCount: snapshot.data.length,
                          itemBuilder: (BuildContext context, int index) =>
                              buildRequestCard(snapshot.data[index]),
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
                return connected;
              },
              child: FutureBuilder(
                future: connected,
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
                                  "You haven't connected with any counselor yet.",
                                  style: TextStyle(color: Colors.black54),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 3),
                                child: Text(
                                    "Connect with a few to see them show up here.",
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
                                        controller: controller,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return filter == null || filter == ""
                                ? buildCounselorCard(snapshot.data[index - 1])
                                : snapshot.data[index - 1]['name']
                                        .toLowerCase()
                                        .contains(filter)
                                    ? buildCounselorCard(
                                        snapshot.data[index - 1])
                                    : snapshot.data[index - 1]['username']
                                            .toLowerCase()
                                            .contains(filter)
                                        ? buildCounselorCard(
                                            snapshot.data[index - 1])
                                        : Container();
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
