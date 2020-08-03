import 'package:http/http.dart' as http;
import '../imports.dart';
import 'engagement.dart';
import 'counselorconnect.dart';
import 'home.dart';

class DashBoard extends StatefulWidget {
  final User user;
  DashBoard({this.user});

  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  TextEditingController studentnotes = TextEditingController();
  int userId;
  bool saved = false;
  bool saving = true;
  bool savingfailed = false;

  Future repNotes;
  Future stats;

  @override
  void initState() {
    super.initState();
    repNotes = getRepNotes();
    stats = getStats();
  }

  Future<void> getRepNotes() async {
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

  Future<void> editRepNotes() async {
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

  Future<void> getStats() async {
    Map data = {};
    String tok = await getToken();
    final response1 = await http.get(
      dom + 'api/university/get-interested-students',
      headers: {HttpHeaders.authorizationHeader: "Token $tok"},
    );
    print(response1.body);
    if (response1.statusCode == 200) {
      data['interested_students'] =
          json.decode(response1.body)['interested_students'].length;
      final response2 = await http.get(
        dom + 'api/university/get-applications',
        headers: {HttpHeaders.authorizationHeader: "Token $tok"},
      );
      print(response2.body);
      if (response2.statusCode == 200) {
        data['applying_students'] =
            json.decode(response2.body)['application_data'].length;
        final response3 = await http.get(
          dom + 'api/university/get-connected-counselors',
          headers: {HttpHeaders.authorizationHeader: "Token $tok"},
        );
        if (response3.statusCode == 200) {
          data['connected_counselors'] =
              json.decode(response3.body)['connected_counselor_data'].length;
          final response4 = await http.get(
            dom + 'api/university/profile',
            headers: {HttpHeaders.authorizationHeader: "Token $tok"},
          );
          print(data);
          if (response4.statusCode == 200) {
            data['image_url'] =
                json.decode(response4.body)['university_data']['image_url'];
          }
          return data;
        } else {
          throw 'failed';
        }
      } else {
        throw 'failed';
      }
    } else {
      throw 'failed';
    }
  }

  _editRepNotes() {
    setState(() {
      saved = false;
      saving = true;
    });
    editRepNotes();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 20, top: 18),
          child: Text(
            'Hello,',
            style: TextStyle(
                color: Colors.black54,
                fontSize: 23,
                fontWeight: FontWeight.w300),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 20),
          child: Text(
            '${widget.user.firstname}',
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
                'University Stats',
                style: TextStyle(color: Colors.black87, fontSize: 18.5),
              ),
              Spacer(),
              InkWell(
                child: Text(
                  'See all',
                  style: TextStyle(color: Color(0xff005fa8), fontSize: 15),
                ),
                onTap: () {
                  curPage = StudentEngagementScreen();
                  Navigator.pushAndRemoveUntil(
                    context,
                    PageTransition(
                        type: PageTransitionType.fade,
                        child: StudentEngagementScreen()),
                    (Route<dynamic> route) => false,
                  );
                },
              ),
            ],
          ),
        ),
        FutureBuilder(
          future: stats,
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
                        EdgeInsets.only(left: 3, right: 3, top: 40, bottom: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Icon(
                            Icons.error_outline,
                            size: 35,
                            color: Colors.red.withOpacity(0.8),
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
              Widget cardData(ImageProvider imageProvider, bool isError) =>
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
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: 12, right: 12, top: 10, bottom: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(left: 35, top: 8),
                                child: Container(
                                  width: 75,
                                  height: 75,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black.withOpacity(0.5),
                                  ),
                                  child: Center(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Padding(
                                          padding: EdgeInsets.only(top: 5),
                                          child: Text(
                                            snapshot.data['interested_students']
                                                .toString(),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18.5,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(top: 3),
                                          child: Text(
                                            'INTERESTED',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 9,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Spacer(),
                              Padding(
                                padding: EdgeInsets.only(right: 35, top: 8),
                                child: Container(
                                  width: 75,
                                  height: 75,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black.withOpacity(0.5),
                                  ),
                                  child: Center(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Padding(
                                          padding: EdgeInsets.only(top: 5),
                                          child: Text(
                                            snapshot.data['applying_students']
                                                .toString(),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18.5,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(top: 3),
                                          child: Text(
                                            'APPLYING',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 9,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 8, top: 20),
                            child: Container(
                              width: 75,
                              height: 75,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withOpacity(0.5),
                              ),
                              child: Center(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.only(top: 5),
                                      child: Text(
                                        snapshot.data['connected_counselors']
                                            .toString(),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18.5,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: 3),
                                      child: Text(
                                        'COUNSELORS',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
              return Padding(
                padding: EdgeInsets.only(left: 25, right: 25),
                child: Card(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  margin: EdgeInsets.only(top: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  elevation: 6,
                  child: CachedNetworkImage(
                    imageUrl: snapshot.data['image_url'] ??
                        'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cd/Black_flag.svg/1200px-Black_flag.svg.png',
                    placeholder: (context, url) => SpinKitWave(
                      type: SpinKitWaveType.start,
                      color: Colors.grey.withOpacity(0.20),
                      size: 40,
                    ),
                    errorWidget: (context, url, error) => cardData(null, true),
                    imageBuilder: (context, imageProvider) =>
                        cardData(imageProvider, false),
                  ),
                ),
              );
            }
            return DashCardSkeleton(
              padding: 20,
            );
          },
        ),
        Padding(
          padding: EdgeInsets.only(top: 30, left: 20, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                'Counselor Requests',
                style: TextStyle(color: Colors.black87, fontSize: 18.5),
              ),
              Spacer(),
              InkWell(
                child: Text(
                  'See all',
                  style: TextStyle(color: Color(0xff005fa8), fontSize: 15),
                ),
                onTap: () {
                  curPage = CounselorConnectScreen();
                  Navigator.pushAndRemoveUntil(
                    context,
                    PageTransition(
                      type: PageTransitionType.fade,
                      child: CounselorConnectScreen(),
                    ),
                    (Route<dynamic> route) => false,
                  );
                },
              ),
            ],
          ),
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
                    future: repNotes.timeout(Duration(seconds: 10)),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        saving = false;
                        savingfailed = true;
                        return Padding(
                          padding: EdgeInsets.only(
                              top: 20, left: 20, right: 20, bottom: 30),
                          child: Text(
                            'Unable to load your notes. Try again later',
                            style:
                                TextStyle(fontSize: 12, color: Colors.black54),
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
                                  borderSide: BorderSide(color: Colors.black87),
                                  borderRadius: BorderRadius.circular(10)),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              hintText:
                                  'Take note of your tasks, plans, thoughts...',
                              hintStyle: TextStyle(
                                  color: Colors.black54, fontSize: 14),
                            ),
                            onChanged: (value) => _editRepNotes(),
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
                    },
                  )
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
