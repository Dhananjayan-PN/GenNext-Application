import 'package:http/http.dart' as http;
// import 'package:badges/badges.dart';
import 'package:intl/intl.dart';
import 'schedule.dart';
import '../usermodel.dart';
import 'universitypage.dart';
import 'allunis.dart';
import 'counselor.dart';
import '../imports.dart';
import 'home.dart';

class DashBoard extends StatefulWidget {
  final User user;
  DashBoard({this.user});

  @override
  _DashBoardState createState() => _DashBoardState(user: user);
}

class _DashBoardState extends State<DashBoard> {
  final User user;
  _DashBoardState({this.user});

  TextEditingController studentnotes = TextEditingController();
  int userId;
  bool saved = false;
  bool saving = true;
  bool savingfailed = false;

  Future recommendedUnis;
  Future upcomingSessions;
  Future allUnis;
  Future studentNotes;

  @override
  void initState() {
    super.initState();
    recommendedUnis = getRecommendedUnis();
    upcomingSessions = getUpcomingSessions();
    allUnis = getAllUniversities();
    studentNotes = getStudentNotes();
  }

  Color colorPicker(double rating) {
    if (0 <= rating && rating < 30) {
      return Colors.red;
    } else if (30 <= rating && rating < 60) {
      return Colors.orange;
    } else if (60 <= rating && rating < 80) {
      return Colors.yellow;
    } else if (80 <= rating && rating <= 100) {
      return Colors.green;
    } else {
      return Colors.white;
    }
  }

  Future<void> getRecommendedUnis() async {
    String tok = await getToken();
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

  Future<void> getAllUniversities() async {
    String tok = await getToken();
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

  Future<void> getUpcomingSessions() async {
    String tok = await getToken();
    final response = await http.get(
      dom + 'api/student/get-counselor-sessions',
      headers: {
        HttpHeaders.authorizationHeader: 'Token $tok',
      },
    );
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['Response'] ==
          'Student yet to be connected with a counselor.') {
        return 'No Counselor';
      } else {
        List sessions = json.decode(response.body)['session_data'];
        List upcoming = [];
        for (var i = 0;
            sessions.length < 4 ? i < sessions.length : i < 5;
            i++) {
          upcoming.add(sessions[i]);
        }
        return upcoming;
      }
    } else {
      throw ('error');
    }
  }

  Future<void> getStudentNotes() async {
    String tok = await getToken();
    saving = true;
    final response = await http.get(dom + 'authenticate/get-notes', headers: {
      HttpHeaders.authorizationHeader: 'Token $tok',
    });
    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      userId = json.decode(response.body)['user_id'];
      if (result['response'] == 'Access Denied.') {
        setState(() {
          saving = false;
          savingfailed = true;
        });
        throw ('error');
      } else {
        String notes = json.decode(response.body)['notes'];
        setState(() {
          saving = false;
          saved = true;
          studentnotes.text = notes;
        });
        return notes;
      }
    } else {
      setState(() {
        saving = false;
        savingfailed = true;
      });
      throw ('error');
    }
  }

  Future<void> editStudentNotes() async {
    String tok = await getToken();
    final response = await http.put(
      dom + 'authenticate/edit-notes',
      headers: {
        HttpHeaders.authorizationHeader: "Token $tok",
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode(
        <String, dynamic>{"user_id": userId, "notes": studentnotes.text},
      ),
    );
    if (response.statusCode == 200) {
      if (json.decode(response.body)['response'] ==
          'Notes Successfuly Updated.') {
        setState(() {
          saving = false;
          saved = true;
        });
      } else {
        setState(() {
          saving = false;
          savingfailed = true;
        });
        error(context);
      }
    } else {
      setState(() {
        saving = false;
        savingfailed = true;
      });
      error(context);
    }
  }

  _editStudentNotes() {
    setState(() {
      saved = false;
      saving = true;
    });
    editStudentNotes();
  }

  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(0),
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 20, top: 18),
          child: Text(
            'Hello,',
            style: TextStyle(
                color: Colors.black54,
                fontSize: 24,
                fontWeight: FontWeight.w300),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 20),
          child: Text(
            '${user.firstname}',
            style: TextStyle(
                color: Colors.black87,
                fontSize: 25,
                fontWeight: FontWeight.w400),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 20, left: 20, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                'Recommended Universities',
                style: TextStyle(color: Colors.black87, fontSize: 18.5),
              ),
              Spacer(),
              InkWell(
                child: Text(
                  'See all',
                  style: TextStyle(color: Color(0xff005fa8), fontSize: 15),
                ),
                onTap: () {
                  curPage = AllUniversitiesScreen();
                  Navigator.pushAndRemoveUntil(
                    context,
                    PageTransition(
                        type: PageTransitionType.fade,
                        child: AllUniversitiesScreen()),
                    (Route<dynamic> route) => false,
                  );
                },
              ),
            ],
          ),
        ),
        FutureBuilder(
          future: recommendedUnis.timeout(Duration(seconds: 10)),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Padding(
                padding: EdgeInsets.only(left: 25, right: 25),
                child: Card(
                  margin: EdgeInsets.only(top: 20, bottom: 20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  elevation: 6,
                  child: Padding(
                    padding:
                        EdgeInsets.only(left: 5, right: 5, top: 55, bottom: 50),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Icon(
                            Icons.error_outline,
                            size: 35,
                            color: Colors.red.withOpacity(0.75),
                          ),
                        ),
                        Text(
                          'Unable to establish a connection\nwith our servers.\nCheck your connection and try again later.',
                          style: TextStyle(color: Colors.black54),
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  ),
                ),
              );
            }
            if (snapshot.hasData) {
              if (snapshot.data.length == 0) {
                return Padding(
                  padding: EdgeInsets.only(left: 25, right: 25),
                  child: Card(
                    margin: EdgeInsets.only(top: 20, bottom: 25),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    elevation: 6,
                    child: Padding(
                      padding: EdgeInsets.only(top: 50, bottom: 50),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Icon(
                              Icons.assessment,
                              size: 35,
                              color: Colors.black.withOpacity(0.75),
                            ),
                          ),
                          Text(
                            "No recommendations at the moment",
                            style: TextStyle(color: Colors.black54),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            "Head over to the Explore section to\nexplore universities",
                            style: TextStyle(color: Colors.black54),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                return Container(
                  height: 260,
                  child: Swiper(
                    loop: false,
                    itemCount: snapshot.data.length,
                    viewportFraction: 0.87,
                    scale: 0.9,
                    itemBuilder: (BuildContext context, int index) {
                      Widget cardData(
                              ImageProvider imageProvider, bool isError) =>
                          Container(
                            decoration: BoxDecoration(
                              color: isError ? Color(0xff005fa8) : null,
                              image: imageProvider != null
                                  ? DecorationImage(
                                      alignment: Alignment.center,
                                      colorFilter: ColorFilter.mode(
                                          Colors.black.withAlpha(100),
                                          BlendMode.darken),
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    )
                                  : DecorationImage(
                                      image: NetworkImage(
                                          'https://www.shareicon.net/data/512x512/2016/08/18/814358_school_512x512.png',
                                          scale: 6.5),
                                    ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                splashColor: Colors.white.withOpacity(0.3),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    PageTransition(
                                      type: PageTransitionType.fade,
                                      child: UniversityPage(
                                        university: snapshot.data[index],
                                        rec: true,
                                      ),
                                    ),
                                  );
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Padding(
                                      padding:
                                          EdgeInsets.only(top: 12, right: 13),
                                      child: Row(
                                        children: <Widget>[
                                          Spacer(),
                                          CircularPercentIndicator(
                                            footer: Text('Match',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w300,
                                                    color: Colors.white,
                                                    fontSize: 10)),
                                            radius: 45.0,
                                            lineWidth: 2.5,
                                            animation: true,
                                            percent: snapshot.data[index]
                                                    ["match_rating"] /
                                                100,
                                            center: Text(
                                              " ${snapshot.data[index]["match_rating"].toString().substring(0, 4)}%",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w300,
                                                  color: Colors.white,
                                                  fontSize: 11.5),
                                            ),
                                            circularStrokeCap:
                                                CircularStrokeCap.round,
                                            backgroundColor: Colors.transparent,
                                            progressColor: colorPicker(snapshot
                                                .data[index]["match_rating"]),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Spacer(),
                                    Padding(
                                      padding: EdgeInsets.only(left: 15),
                                      child: Text(
                                        snapshot.data[index]['university_name'],
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.only(bottom: 14, left: 15),
                                      child: Text(
                                        snapshot.data[index]
                                            ['university_location'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            color:
                                                Colors.white.withOpacity(0.9),
                                            fontSize: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                      return Hero(
                        tag: snapshot.data[index]['university_id'].toString() +
                            'rec',
                        child: Card(
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          margin: EdgeInsets.only(top: 20, bottom: 30),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          elevation: 6,
                          child: CachedNetworkImage(
                              key: Key(snapshot.data[index]['university_id']
                                  .toString()),
                              imageUrl: snapshot.data[index]['image_url'] ??
                                  'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cd/Black_flag.svg/1200px-Black_flag.svg.png',
                              placeholder: (context, url) => SpinKitWave(
                                    type: SpinKitWaveType.start,
                                    color: Colors.grey.withOpacity(0.20),
                                    size: 40,
                                  ),
                              errorWidget: (context, url, error) =>
                                  cardData(null, true),
                              imageBuilder: (context, imageProvider) =>
                                  cardData(imageProvider, false)),
                        ),
                      );
                    },
                  ),
                );
              }
            }
            return Padding(
              padding: EdgeInsets.only(bottom: 25),
              child: DashCardSkeleton(
                padding: 18,
              ),
            );
          },
        ),
        Padding(
          padding: EdgeInsets.only(top: 5, left: 20, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                'Upcoming Sessions',
                style: TextStyle(color: Colors.black87, fontSize: 19),
              ),
              Spacer(),
              InkWell(
                child: Text(
                  'See all',
                  style: TextStyle(color: Color(0xff005fa8), fontSize: 15),
                ),
                onTap: () {
                  curPage = ScheduleScreen();
                  Navigator.pushAndRemoveUntil(
                    context,
                    PageTransition(
                        type: PageTransitionType.fade, child: ScheduleScreen()),
                    (Route<dynamic> route) => false,
                  );
                },
              ),
            ],
          ),
        ),
        FutureBuilder(
          future: upcomingSessions.timeout(Duration(seconds: 10)),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Padding(
                padding: EdgeInsets.only(left: 25, right: 25),
                child: Card(
                  margin: EdgeInsets.only(top: 20, bottom: 20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  elevation: 6,
                  child: Padding(
                    padding:
                        EdgeInsets.only(left: 3, right: 3, top: 30, bottom: 30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Icon(
                            Icons.error_outline,
                            size: 35,
                            color: Colors.red.withOpacity(0.6),
                          ),
                        ),
                        Text(
                          'Unable to establish a connection\nwith our servers.\nCheck your connection and try again later.',
                          style: TextStyle(color: Colors.black54),
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  ),
                ),
              );
            }
            if (snapshot.hasData) {
              if (snapshot.data == 'No Counselor') {
                return Padding(
                  padding: EdgeInsets.only(left: 25, right: 25),
                  child: Card(
                    margin: EdgeInsets.only(top: 20),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    elevation: 6,
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: 12, right: 12, top: 10, bottom: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                              padding: EdgeInsets.only(bottom: 0),
                              child: SizedBox(
                                height: 70,
                                width: 140,
                                child: Image.asset(
                                  'images/gennextlonglogo-4.png',
                                  fit: BoxFit.contain,
                                ),
                              )),
                          Text(
                            'This feature is available only to students assigned to a counselor.\nRequest now to unlock all benefits.',
                            style: TextStyle(color: Colors.black54),
                            textAlign: TextAlign.center,
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 6, bottom: 1),
                            child: ActionChip(
                              visualDensity: VisualDensity.compact,
                              shape: StadiumBorder(
                                  side: BorderSide(
                                      color: Color(0xff005fa8), width: 0.0)),
                              backgroundColor: Colors.white,
                              label: Text('Request'),
                              onPressed: () {
                                curPage = CounsellingScreen();
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  PageTransition(
                                      type: PageTransitionType.fade,
                                      child: CounsellingScreen()),
                                  (Route<dynamic> route) => false,
                                );
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              }
              if (snapshot.data.length == 0) {
                return Padding(
                  padding: EdgeInsets.only(left: 25, right: 25),
                  child: Card(
                    margin: EdgeInsets.only(top: 20, bottom: 30),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    elevation: 6,
                    child: Padding(
                      padding: EdgeInsets.only(top: 50, bottom: 50),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Icon(
                              Icons.schedule,
                              size: 35,
                              color: Colors.black.withOpacity(0.75),
                            ),
                          ),
                          Text(
                            "No upcoming sessions",
                            style: TextStyle(color: Colors.black54),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            "Enjoy your day!",
                            style: TextStyle(color: Colors.black54),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                return Container(
                  height: 230,
                  child: Swiper(
                    loop: false,
                    pagination: snapshot.data.length == 1
                        ? null
                        : SwiperPagination(margin: EdgeInsets.all(0)),
                    itemCount: snapshot.data.length,
                    viewportFraction: 0.83,
                    scale: 0.9,
                    itemBuilder: (BuildContext context, int index) {
                      DateTime sessionDateTime = DateTime.parse(
                              snapshot.data[index]['session_timestamp'])
                          .toLocal();
                      final int hour =
                          snapshot.data[index]['session_duration'] ~/ 60;
                      final int minutes =
                          snapshot.data[index]['session_duration'] % 60;
                      return Card(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        margin: EdgeInsets.only(top: 20, bottom: 30),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        elevation: 6,
                        child: Padding(
                          padding:
                              EdgeInsets.only(top: 10, left: 20, right: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Text(
                                    DateFormat.d().format(sessionDateTime),
                                    style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 38,
                                        fontWeight: FontWeight.w200),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.only(left: 2, bottom: 2.9),
                                    child: Text(
                                      DateFormat.MMM()
                                          .format(sessionDateTime)
                                          .toUpperCase(),
                                      style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 25,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                  Spacer(),
                                  Padding(
                                    padding:
                                        EdgeInsets.only(left: 2, bottom: 12),
                                    child: Text(
                                      hour == 0
                                          ? minutes.toString() + 'm'
                                          : hour.toString() +
                                              'h ' +
                                              minutes.toString() +
                                              'm',
                                      style: TextStyle(
                                          color: Color(0xff005fa8),
                                          fontSize: 18,
                                          fontWeight: FontWeight.w200),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 3, bottom: 0),
                                child: Text(
                                  DateFormat.jm()
                                      .format(sessionDateTime)
                                      .toUpperCase(),
                                  style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w200),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 2, top: 13),
                                child: Text(
                                  snapshot.data[index]['subject_of_session'],
                                  style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                              snapshot.data[index]['session_notes'] == ''
                                  ? Container()
                                  : Padding(
                                      padding: EdgeInsets.only(
                                          left: 3, top: 3, right: 8),
                                      child: Text(
                                        snapshot.data[index]['session_notes'],
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        style: TextStyle(
                                            color:
                                                Colors.black.withOpacity(0.6),
                                            fontSize: 15,
                                            fontWeight: FontWeight.w300),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
            }
            return DashCardSkeleton(
              padding: 20,
            );
          },
        ),
        Padding(
          padding: EdgeInsets.only(top: 20, left: 20, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                'All Universities',
                style: TextStyle(color: Colors.black87, fontSize: 18.5),
              ),
              Spacer(),
              InkWell(
                child: Text(
                  'See all',
                  style: TextStyle(color: Color(0xff005fa8), fontSize: 15),
                ),
                onTap: () {
                  curPage = AllUniversitiesScreen();
                  Navigator.pushAndRemoveUntil(
                    context,
                    PageTransition(
                        type: PageTransitionType.fade,
                        child: AllUniversitiesScreen()),
                    (Route<dynamic> route) => false,
                  );
                },
              ),
            ],
          ),
        ),
        FutureBuilder(
          future: allUnis.timeout(Duration(seconds: 10)),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Padding(
                padding: EdgeInsets.only(left: 25, right: 25),
                child: Card(
                  margin: EdgeInsets.only(top: 20, bottom: 20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  elevation: 6,
                  child: Padding(
                    padding:
                        EdgeInsets.only(left: 5, right: 5, top: 55, bottom: 50),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Icon(
                            Icons.error_outline,
                            size: 35,
                            color: Colors.red.withOpacity(0.75),
                          ),
                        ),
                        Text(
                          'Unable to establish a connection\nwith our servers.\nCheck your connection and try again later.',
                          style: TextStyle(color: Colors.black54),
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  ),
                ),
              );
            }
            if (snapshot.hasData) {
              if (snapshot.data.length == 0) {
                return Padding(
                  padding: EdgeInsets.only(left: 25, right: 25),
                  child: Card(
                    margin: EdgeInsets.only(top: 20, bottom: 25),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    elevation: 6,
                    child: Padding(
                      padding: EdgeInsets.only(top: 50, bottom: 50),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Icon(
                              Icons.assessment,
                              size: 35,
                              color: Colors.black.withOpacity(0.75),
                            ),
                          ),
                          Text(
                            "There no universities at the moment",
                            style: TextStyle(color: Colors.black54),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            "Come back again to explore",
                            style: TextStyle(color: Colors.black54),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                return Container(
                  height: 260,
                  child: Swiper(
                    loop: false,
                    itemCount: snapshot.data.length,
                    viewportFraction: 0.87,
                    scale: 0.9,
                    itemBuilder: (BuildContext context, int index) {
                      Widget cardData(
                              ImageProvider imageProvider, bool isError) =>
                          Container(
                            decoration: BoxDecoration(
                              color: isError ? Color(0xff005fa8) : null,
                              image: imageProvider != null
                                  ? DecorationImage(
                                      alignment: Alignment.center,
                                      colorFilter: ColorFilter.mode(
                                          Colors.black.withAlpha(100),
                                          BlendMode.darken),
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    )
                                  : DecorationImage(
                                      image: NetworkImage(
                                          'https://www.shareicon.net/data/512x512/2016/08/18/814358_school_512x512.png',
                                          scale: 6.5),
                                    ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                splashColor: Colors.white.withOpacity(0.3),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    PageTransition(
                                        type: PageTransitionType.fade,
                                        child: UniversityPage(
                                            university: snapshot.data[index])),
                                  );
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Padding(
                                      padding:
                                          EdgeInsets.only(top: 12, right: 13),
                                      child: Row(
                                        children: <Widget>[
                                          Spacer(),
                                          CircularPercentIndicator(
                                            footer: Text('Match',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w300,
                                                    color: Colors.white,
                                                    fontSize: 10)),
                                            radius: 45.0,
                                            lineWidth: 2.5,
                                            animation: true,
                                            percent: snapshot.data[index]
                                                    ["match_rating"] /
                                                100,
                                            center: Text(
                                              " ${snapshot.data[index]["match_rating"].toString().substring(0, 4)}%",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w300,
                                                  color: Colors.white,
                                                  fontSize: 11.5),
                                            ),
                                            circularStrokeCap:
                                                CircularStrokeCap.round,
                                            backgroundColor: Colors.transparent,
                                            progressColor: colorPicker(snapshot
                                                .data[index]["match_rating"]),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Spacer(),
                                    Padding(
                                      padding: EdgeInsets.only(left: 15),
                                      child: Text(
                                        snapshot.data[index]['university_name'],
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.only(bottom: 14, left: 15),
                                      child: Text(
                                        snapshot.data[index]
                                            ['university_location'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            color:
                                                Colors.white.withOpacity(0.9),
                                            fontSize: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                      return Hero(
                        tag: snapshot.data[index]['university_id'],
                        child: Card(
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          margin: EdgeInsets.only(top: 20, bottom: 30),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          elevation: 6,
                          child: CachedNetworkImage(
                              key: Key(snapshot.data[index]['university_id']
                                  .toString()),
                              imageUrl: snapshot.data[index]['image_url'] ??
                                  'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cd/Black_flag.svg/1200px-Black_flag.svg.png',
                              placeholder: (context, url) => SpinKitWave(
                                    type: SpinKitWaveType.start,
                                    color: Colors.grey.withOpacity(0.20),
                                    size: 40,
                                  ),
                              errorWidget: (context, url, error) =>
                                  cardData(null, true),
                              imageBuilder: (context, imageProvider) =>
                                  cardData(imageProvider, false)),
                        ),
                      );
                    },
                  ),
                );
              }
            }
            return Padding(
              padding: EdgeInsets.only(bottom: 25),
              child: DashCardSkeleton(
                padding: 18,
              ),
            );
          },
        ),
        Padding(
          padding: EdgeInsets.only(top: 20),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(width: 0.2, color: Colors.black54),
              ),
            ),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              elevation: 0,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Spacer(),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(right: 5),
                              child: Icon(
                                Icons.edit,
                                color: Colors.black.withOpacity(0.8),
                              ),
                            ),
                            Text(
                              'Notepad',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black.withOpacity(0.8)),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        Spacer(),
                        saved
                            ? Padding(
                                padding: EdgeInsets.only(right: 13),
                                child: Icon(
                                  Icons.check,
                                  color: Colors.green,
                                ),
                              )
                            : saving
                                ? Padding(
                                    padding: EdgeInsets.only(right: 17),
                                    child: SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: SpinKitThreeBounce(
                                            color: Colors.black87, size: 10)),
                                  )
                                : savingfailed
                                    ? Padding(
                                        padding: EdgeInsets.only(right: 10),
                                        child: Icon(
                                          Icons.priority_high,
                                          color: Colors.red,
                                        ),
                                      )
                                    : Container(),
                      ],
                    ),
                  ),
                  Text(
                    "Changes will be synced across devices",
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: 10,
                        fontWeight: FontWeight.w400),
                    textAlign: TextAlign.center,
                  ),
                  Divider(thickness: 0, indent: 25, endIndent: 25),
                  FutureBuilder(
                      future: studentNotes.timeout(Duration(seconds: 10)),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          saving = false;
                          savingfailed = true;
                          return Padding(
                            padding: EdgeInsets.only(
                                top: 20, left: 20, right: 20, bottom: 30),
                            child: Text(
                              'Unable to load your notes. Try again later',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.black54),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }
                        if (snapshot.hasData) {
                          saving = false;
                          saved = true;
                          return Padding(
                            padding: EdgeInsets.only(
                                top: 0, left: 20, right: 20, bottom: 30),
                            child: TextField(
                              cursorColor: Color(0xff005fa8),
                              controller: studentnotes,
                              autocorrect: true,
                              maxLines: null,
                              decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.black87),
                                    borderRadius: BorderRadius.circular(10)),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                hintText:
                                    'Take note of your tasks, plans, thoughts...',
                                hintStyle: TextStyle(
                                    color: Colors.black54, fontSize: 14),
                              ),
                              onChanged: (value) => _editStudentNotes(),
                            ),
                          );
                        }
                        return Padding(
                          padding: EdgeInsets.only(
                              top: 30, left: 20, right: 20, bottom: 50),
                          child: Center(
                              child: SpinKitWave(
                            color: Colors.grey.withOpacity(0.4),
                            size: 30,
                          )),
                        );
                      })
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
