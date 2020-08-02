import 'package:http/http.dart' as http;
import '../imports.dart';
import 'home.dart';

class CounselorConnectScreen extends StatefulWidget {
  @override
  _CounselorConnectScreenState createState() => _CounselorConnectScreenState();
}

class _CounselorConnectScreenState extends State<CounselorConnectScreen> {
  GlobalKey<ScaffoldState> _scafKey = GlobalKey<ScaffoldState>();

  Future requests;
  Future connected;

  @override
  void initState() {
    super.initState();
    requests = getCounselorRequests();
    connected = getConnectedCounselors();
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: _scafKey,
        backgroundColor: Colors.white,
        drawer: NavDrawer(
            user: newUser,
            name: newUser.firstname + ' ' + newUser.lastname,
            email: newUser.email),
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
                  ])),
              Tab(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                    Icon(Icons.insert_link),
                    Padding(
                      padding: EdgeInsets.only(left: 3.0),
                      child: Text('Connected'),
                    )
                  ])),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            FutureBuilder(
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
                              padding:
                                  EdgeInsets.only(top: 5, left: 30, right: 30),
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
                  } else {}
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
            FutureBuilder(
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
                              padding:
                                  EdgeInsets.only(top: 5, left: 30, right: 30),
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
                  } else {}
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
          ],
        ),
      ),
    );
  }
}
