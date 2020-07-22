import 'package:http/http.dart' as http;
import '../imports.dart';
import 'home.dart';

class CounsellingScreen extends StatefulWidget {
  @override
  _CounsellingScreenState createState() => _CounsellingScreenState();
}

class _CounsellingScreenState extends State<CounsellingScreen> {
  GlobalKey<ScaffoldState> _scafKey = GlobalKey<ScaffoldState>();
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  Future counselorInfo;

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
    counselorInfo = getCounselorInfo();
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

  Future<void> getCounselorInfo() async {
    final response = await http.get(
      dom + 'api/student/get-counselor-information',
      headers: {HttpHeaders.authorizationHeader: "Token $tok"},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['Response'] == "Student hasn't requested for counseling.") {
        return 'No counselor';
      } else if (data['Response'] ==
          "Student yet to be connected with a counselor.") {
        return 'Request sent';
      } else {
        return data;
      }
    } else {
      throw 'failed';
    }
  }

  refresh() {
    setState(() {
      //add future call here
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scafKey,
      backgroundColor: Colors.white,
      drawer: NavDrawer(
          name: newUser.firstname + ' ' + newUser.lastname,
          email: newUser.email),
      appBar: CustomAppBar('Counselling'),
      body: RefreshIndicator(
        key: refreshKey,
        onRefresh: () {
          refresh();
          return counselorInfo;
        },
        child: FutureBuilder(
          future: counselorInfo.timeout(Duration(seconds: 10)),
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
              if (snapshot.data == 'No counselor') {
                return Padding(
                  padding: EdgeInsets.all(15),
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    elevation: 6,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(top: 20, bottom: 10),
                            child: Image.asset(
                              'images/gennextlonglogo-4.png',
                              height: 90,
                              width: 270,
                              fit: BoxFit.fill,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                left: 20, right: 20, bottom: 50),
                            child: Text(
                              'Whether you know exactly what and where you want to study or are completely confused about where to start, we’re here for you.' +
                                  '\nFrom program and university selection, to completing applications, to meeting deadlines, to preparing for the visa interview,' +
                                  ' we will guide you every step of the way to ensure your success.'
                                      '\n\nTake advantage of our years of experience guiding thousands of students just like you achieve their dreams, all for FREE.',
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                          Padding(
                              padding:
                                  EdgeInsets.only(top: 15, left: 30, right: 30),
                              child: Text(
                                "You haven't requested for counselling yet.",
                                style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900),
                                textAlign: TextAlign.center,
                              )),
                          Padding(
                            padding: EdgeInsets.only(top: 5, bottom: 20),
                            child: Text("Click the button to get started!",
                                style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900),
                                textAlign: TextAlign.center),
                          ),
                          RaisedButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textColor: Colors.white,
                            padding: EdgeInsets.all(0.0),
                            child: Container(
                              padding: EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                color: Color(0xff005fa8),
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Request Counselling',
                                style: TextStyle(),
                              ),
                            ),
                            onPressed: () {},
                          )
                        ],
                      ),
                    ),
                  ),
                );
              } else if (snapshot.data == 'Request sent') {
                return Padding(
                  padding: EdgeInsets.all(15),
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    elevation: 6,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(top: 20, bottom: 10),
                            child: Image.asset(
                              'images/gennextlonglogo-4.png',
                              height: 90,
                              width: 270,
                              fit: BoxFit.fill,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                left: 20, right: 20, bottom: 50),
                            child: Text(
                              'Whether you know exactly what and where you want to study or are completely confused about where to start, we’re here for you.' +
                                  '\nFrom program and university selection, to completing applications, to meeting deadlines, to preparing for the visa interview,' +
                                  ' we will guide you every step of the way to ensure your success.'
                                      '\n\nTake advantage of our years of experience guiding thousands of students just like you achieve their dreams, all for FREE.',
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                          Padding(
                            padding:
                                EdgeInsets.only(top: 15, left: 30, right: 30),
                            child: Text(
                              "We have received you're request for counselling!",
                              style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding:
                                EdgeInsets.only(top: 15, left: 30, right: 30),
                            child: Text(
                              "Please be patient while we assign you a counselor.",
                              style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                return Column(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(top: 25, left: 25),
                        child: Text(
                          'My Counselor',
                          style: TextStyle(fontSize: 21),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 12, left: 10, right: 10),
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        elevation: 6,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ListTile(
                              contentPadding: EdgeInsets.only(left: 20, top: 5),
                              leading: CircleAvatar(
                                backgroundImage: CachedNetworkImageProvider(
                                    snapshot.data['counselor_profile_pic']),
                                backgroundColor: Colors.blue[800],
                                radius: 28,
                              ),
                              title: Text(
                                snapshot.data['counselor_name'],
                                style: TextStyle(fontSize: 17),
                              ),
                              subtitle: Text('Counselor'),
                            ),
                            Divider(
                              thickness: 1,
                              indent: 20,
                              endIndent: 20,
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 5, left: 20),
                              child: Row(
                                children: <Widget>[
                                  Text(
                                    'Username: ',
                                  ),
                                  Text(
                                    '@' + snapshot.data['counselor_username'],
                                    style: TextStyle(color: Colors.black54),
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 15, left: 20),
                              child: Row(
                                children: <Widget>[
                                  Text(
                                    'Email ID: ',
                                  ),
                                  Text(
                                    snapshot.data['counselor_email'],
                                    style: TextStyle(color: Colors.black54),
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: 15, left: 20, bottom: 15),
                              child: Row(
                                children: <Widget>[
                                  Text(
                                    'Country: ',
                                  ),
                                  Text(
                                    snapshot.data['counselor_country'],
                                    style: TextStyle(color: Colors.black54),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 25),
                      child: Text(
                        'Not satisfied with your counselor?',
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        splashColor: Colors.blue[700],
                        onTap: () {},
                        child: Text(
                          'Request for another',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xff005fa8),
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                  ],
                );
              }
            }
            return Center(
              child: SpinKitWave(color: Colors.grey, size: 40),
            );
          },
        ),
      ),
    );
  }
}
