import '../imports.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'home.dart';

class MyStudentsScreen extends StatefulWidget {
  @override
  _MyStudentsScreenState createState() => _MyStudentsScreenState();
}

class _MyStudentsScreenState extends State<MyStudentsScreen> {
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  TextEditingController controller = TextEditingController();
  String filter;
  List students;

  Future myStudents;

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
    controller.addListener(() {
      setState(() {
        filter = controller.text.toLowerCase();
      });
    });
    myStudents = getMyStudents();
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

  Future<void> getMyStudents() async {
    String tok = await getToken();
    final response = await http.get(
      dom + 'api/counselor/counseled-students',
      headers: {HttpHeaders.authorizationHeader: "Token $tok"},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body)['counseled_students'];
    } else {
      throw 'failed';
    }
  }

  void refresh() {
    setState(() {
      myStudents = getMyStudents();
    });
  }

  Widget buildCard(student) {
    return Padding(
      padding: EdgeInsets.only(top: 5, left: 10, right: 10),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        elevation: 6,
        child: ListTile(
          leading: CircleAvatar(
            radius: 25,
            backgroundImage: CachedNetworkImageProvider(
              student['student_profile_url'] ??
                  'https://www.pngfind.com/pngs/m/610-6104451_image-placeholder-png-user-profile-placeholder-image-png.png',
            ),
            backgroundColor: Color(0xff005fa8),
          ),
          title: Text(student['student_name']),
          subtitle: Text(
            '@' + student['student_username'],
            style: TextStyle(color: Color(0xff005fa8)),
          ),
          onTap: () async {
            List data = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StudentProfileScreen(
                  student: student,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: NavDrawer(),
      appBar: CustomAppBar('My Students'),
      body: RefreshIndicator(
        key: refreshKey,
        onRefresh: () {
          refresh();
          return myStudents;
        },
        child: FutureBuilder(
          future: myStudents.timeout(Duration(seconds: 10)),
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
                          style: TextStyle(fontSize: 18, color: Colors.black54),
                        ),
                        Padding(
                            padding:
                                EdgeInsets.only(top: 5, left: 30, right: 30),
                            child: Text(
                              "Looks like you don't have counsel\nany students at the moment :(",
                              style: TextStyle(color: Colors.black54),
                              textAlign: TextAlign.center,
                            )),
                        Padding(
                          padding: EdgeInsets.only(top: 3),
                          child: Text(
                              "Request your admin to assign or accept a request to get started!",
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
                    itemCount: snapshot.data.length + 1,
                    itemBuilder: (BuildContext context, int index) {
                      if (index == 0) {
                        return Padding(
                          padding: EdgeInsets.only(
                              top: 5, left: 18, right: 30, bottom: 25),
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
                          ? buildCard(snapshot.data[index - 1])
                          : snapshot.data[index - 1]['student_name']
                                  .toLowerCase()
                                  .contains(filter)
                              ? buildCard(snapshot.data[index - 1])
                              : Container();
                    },
                  ),
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

class StudentProfileScreen extends StatefulWidget {
  final Map student;
  StudentProfileScreen({@required this.student});
  @override
  _StudentProfileScreenState createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  List<Widget> transcripts;
  List<Widget> ecs;
  List<Widget> misc;
  List<Widget> scores;
  List<Widget> reach;
  List<Widget> match;
  List<Widget> safety;
  String countryString;
  String interestString;

  Future documents;
  Future collegeList;

  @override
  void initState() {
    super.initState();
    documents = getDocuments();
    collegeList = getCollegeList();
  }

  Future getDocuments() async {
    String tok = await getToken();
    Map docs = {};
    final response = await http.get(
      dom +
          'api/counselor/get-student-documents/${widget.student['student_id']}',
      headers: {HttpHeaders.authorizationHeader: "Token $tok"},
    );
    if (response.statusCode == 200) {
      docs = json.decode(response.body);
      final result = await http.get(
        dom + 'api/counselor/get-test-scores/${widget.student['student_id']}',
        headers: {HttpHeaders.authorizationHeader: "Token $tok"},
      );
      if (result.statusCode == 200) {
        docs['test_scores'] = json.decode(result.body)['test_scores'];
        return docs;
      } else {
        throw 'failed';
      }
    } else {
      throw 'failed';
    }
  }

  Future getCollegeList() async {
    String tok = await getToken();
    final response = await http.get(
      dom + 'api/counselor/get-college-list/${widget.student['student_id']}',
      headers: {HttpHeaders.authorizationHeader: "Token $tok"},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw 'failed';
    }
  }

  Widget buildCard(uni) {
    Widget cardData(ImageProvider imageProvider, bool isError) => Container(
          decoration: BoxDecoration(
            color: isError ? Color(0xff005fa8) : null,
            image: imageProvider != null
                ? DecorationImage(
                    alignment: Alignment.center,
                    colorFilter: ColorFilter.mode(
                        Colors.black.withAlpha(100), BlendMode.darken),
                    image: imageProvider,
                    fit: BoxFit.cover,
                  )
                : DecorationImage(
                    colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.35), BlendMode.dstIn),
                    image: NetworkImage(
                        'https://www.shareicon.net/data/512x512/2016/08/18/814358_school_512x512.png',
                        scale: 12),
                  ),
          ),
          child: Material(
            color: Colors.transparent,
            child: ListTile(
              dense: true,
              title: Text(
                uni['university_name'],
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                uni['university_location'],
                style: TextStyle(
                    color: Colors.white.withOpacity(0.9), fontSize: 13.5),
              ),
              onTap: () async {
                // ignore: unused_local_variable
                // final data = await Navigator.push(
                //   context,
                //   PageTransition(
                //     type: PageTransitionType.fade,
                //     child: UniversityPage(
                //       university: uni,
                //     ),
                //   ),
                // );
              },
            ),
          ),
        );
    return Hero(
      tag: uni['university_id'].toString(),
      child: Card(
        margin: EdgeInsets.only(top: 3, left: 18, right: 18, bottom: 3),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        elevation: 3,
        child: CachedNetworkImage(
          key: Key(uni['university_id'].toString()),
          imageUrl: uni['image_url'] ??
              'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cd/Black_flag.svg/1200px-Black_flag.svg.png',
          placeholder: (context, url) => CardPlaceHolder(),
          errorWidget: (context, url, error) => cardData(null, true),
          imageBuilder: (context, imageProvider) =>
              cardData(imageProvider, false),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    countryString = '';
    interestString = '';
    for (int i = 0; i < widget.student['student_interests'].length; i++) {
      if (i == 0) {
        interestString += widget.student['student_interests'][i];
      } else {
        interestString += ', ';
        interestString += widget.student['student_interests'][i];
      }
    }
    for (int i = 0; i < widget.student['country_pref'].length; i++) {
      if (i == 0) {
        countryString += widget.student['country_pref'][i];
      } else {
        countryString += ', ';
        countryString += widget.student['country_pref'][i];
      }
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xff005fa8),
        title: Text('Student Profile'),
      ),
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 15, left: 10, right: 10),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              elevation: 4,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage: CachedNetworkImageProvider(
                        widget.student['student_profile_img'] ??
                            'https://www.pngfind.com/pngs/m/610-6104451_image-placeholder-png-user-profile-placeholder-image-png.png',
                      ),
                      backgroundColor: Color(0xff005fa8),
                      radius: 29,
                    ),
                    title: Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: Text(
                        widget.student['student_name'],
                        style: TextStyle(fontSize: 17),
                      ),
                    ),
                    subtitle: Text(
                      '@' + widget.student['student_username'],
                      style: TextStyle(
                        color: Color(0xff005fa8),
                      ),
                    ),
                  ),
                  Divider(
                    thickness: 1,
                    indent: 20,
                    endIndent: 20,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 5, left: 21),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 2.5),
                          child: Text(
                            'EMAIL ID: ',
                            style:
                                TextStyle(color: Colors.black54, fontSize: 12),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.65,
                          child: Text(
                            widget.student['student_email'],
                            style:
                                TextStyle(color: Colors.black87, fontSize: 15),
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10, left: 21),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 2.5),
                          child: Text(
                            'DOB: ',
                            style:
                                TextStyle(color: Colors.black54, fontSize: 12),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.65,
                          child: Text(
                            widget.student['student_dob'],
                            style:
                                TextStyle(color: Colors.black87, fontSize: 15),
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10, left: 21),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 2.5),
                          child: Text(
                            'GRADE: ',
                            style:
                                TextStyle(color: Colors.black54, fontSize: 12),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.65,
                          child: Text(
                            widget.student['student_grade'].toString(),
                            style:
                                TextStyle(color: Colors.black87, fontSize: 15),
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10, left: 21),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 2.5),
                          child: Text(
                            'SCHOOL: ',
                            style:
                                TextStyle(color: Colors.black54, fontSize: 12),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.65,
                          child: Text(
                            widget.student['student_school'],
                            style: TextStyle(
                                color: Colors.black87, fontSize: 14.5),
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10, left: 21, bottom: 15),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 2.5),
                          child: Text(
                            'COUNTRY: ',
                            style:
                                TextStyle(color: Colors.black54, fontSize: 12),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.65,
                          child: Text(
                            widget.student['student_country'],
                            style:
                                TextStyle(color: Colors.black87, fontSize: 15),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 20, top: 18),
            child: Text(
              'Preferences',
              style: TextStyle(fontSize: 20),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 5, left: 14, right: 14),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              elevation: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 10, left: 15),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Text(
                            'MAJOR: ',
                            style:
                                TextStyle(color: Colors.black54, fontSize: 12),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.65,
                          child: Text(
                            widget.student['student_major'],
                            style:
                                TextStyle(color: Colors.black87, fontSize: 15),
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 5, left: 15, bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Text(
                            'DEGREE LEVEL: ',
                            style:
                                TextStyle(color: Colors.black54, fontSize: 12),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.55,
                          child: Text(
                            widget.student['student_degree_level'],
                            style:
                                TextStyle(color: Colors.black87, fontSize: 15),
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 15, bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Text(
                            'AREA PREFERENCE: ',
                            style:
                                TextStyle(color: Colors.black54, fontSize: 12),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: Text(
                            widget.student['college_town_pref'],
                            style:
                                TextStyle(color: Colors.black87, fontSize: 15),
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 15, bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Text(
                            'BUDGET: ',
                            style:
                                TextStyle(color: Colors.black54, fontSize: 12),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: Text(
                            r'$' + widget.student['budget'].toString(),
                            style:
                                TextStyle(color: Colors.black87, fontSize: 15),
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 15, bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Text(
                            'COUNTRIES: ',
                            style:
                                TextStyle(color: Colors.black54, fontSize: 12),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: Text(
                            countryString,
                            style:
                                TextStyle(color: Colors.black87, fontSize: 15),
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 15, bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Text(
                            'RESEARCH INTEREST: ',
                            style:
                                TextStyle(color: Colors.black54, fontSize: 12),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.4,
                          child: Text(
                            widget.student['researcher_status'] ? 'Yes' : 'No',
                            style:
                                TextStyle(color: Colors.black87, fontSize: 15),
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 15, bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Text(
                            'INTERESTS: ',
                            style:
                                TextStyle(color: Colors.black54, fontSize: 12),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: Text(
                            interestString,
                            style:
                                TextStyle(color: Colors.black87, fontSize: 15),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 20, top: 18),
            child: Text(
              'College List',
              style: TextStyle(fontSize: 20),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 5, left: 14, right: 14),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              elevation: 4,
              child: FutureBuilder(
                future: collegeList,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Padding(
                      padding: EdgeInsets.only(
                          left: 3, right: 3, top: 30, bottom: 30),
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
                    );
                  }
                  if (snapshot.hasData) {
                    reach = [];
                    match = [];
                    safety = [];
                    for (int i = 0;
                        i < snapshot.data['reach_college_list_data'].length;
                        i++) {
                      reach.add(buildCard(
                          snapshot.data['reach_college_list_data'][i]));
                    }
                    for (int i = 0;
                        i < snapshot.data['match_college_list_data'].length;
                        i++) {
                      match.add(buildCard(
                          snapshot.data['match_college_list_data'][i]));
                    }
                    for (int i = 0;
                        i < snapshot.data['safety_college_list_data'].length;
                        i++) {
                      safety.add(buildCard(
                          snapshot.data['safety_college_list_data'][i]));
                    }
                    return Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Padding(
                            padding:
                                EdgeInsets.only(left: 15, top: 10, bottom: 3),
                            child: Text(
                              'Reach',
                              style: TextStyle(
                                fontSize: 18.5,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Column(
                            children: reach.length == 0
                                ? [
                                    Padding(
                                      padding: EdgeInsets.only(left: 15),
                                      child: Text(
                                        'No Universities Added',
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 11),
                                      ),
                                    )
                                  ]
                                : reach,
                          ),
                          Padding(
                            padding:
                                EdgeInsets.only(left: 15, top: 8, bottom: 3),
                            child: Text(
                              'Match',
                              style: TextStyle(
                                fontSize: 18.5,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Column(
                            children: match.length == 0
                                ? [
                                    Padding(
                                      padding: EdgeInsets.only(left: 15),
                                      child: Text(
                                        'No Universities Added',
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 11),
                                      ),
                                    )
                                  ]
                                : match,
                          ),
                          Padding(
                            padding:
                                EdgeInsets.only(left: 15, top: 8, bottom: 3),
                            child: Text(
                              'Safety',
                              style: TextStyle(
                                fontSize: 18.5,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Column(
                            children: safety.length == 0
                                ? [
                                    Padding(
                                      padding: EdgeInsets.only(left: 15),
                                      child: Text(
                                        'No Universities Added',
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 11),
                                      ),
                                    )
                                  ]
                                : safety,
                          ),
                        ],
                      ),
                    );
                  }
                  return Padding(
                    padding: EdgeInsets.only(top: 30, bottom: 30),
                    child: Center(
                      child: SpinKitWave(color: Colors.grey, size: 30),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 20, top: 18),
            child: Text(
              'Documents',
              style: TextStyle(fontSize: 20),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 5, left: 14, right: 14),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              elevation: 4,
              child: FutureBuilder(
                future: documents.timeout(Duration(seconds: 10)),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Padding(
                      padding: EdgeInsets.only(
                          left: 3, right: 3, top: 30, bottom: 30),
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
                    );
                  }
                  if (snapshot.hasData) {
                    transcripts = [];
                    ecs = [];
                    misc = [];
                    scores = [];
                    for (int i = 0;
                        i < snapshot.data['transcripts'].length;
                        i++) {
                      transcripts.add(
                        Padding(
                          padding: EdgeInsets.only(
                              top: 4, left: 15, right: 25, bottom: 4),
                          child: Card(
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: Color(0xff005fa8), width: 0.8),
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                            elevation: 2,
                            child: Material(
                              color: Colors.transparent,
                              child: ListTile(
                                dense: true,
                                title: Text(
                                  snapshot.data['transcripts'][i]['title'],
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                  ),
                                ),
                                subtitle: Text(
                                  'Grade ${snapshot.data['transcripts'][i]['grade']}',
                                  style: TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w400),
                                ),
                                onTap: () {
                                  launch(snapshot.data['transcripts'][i]
                                      ['transcript_file_path']);
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    for (int i = 0;
                        i < snapshot.data['extracurriculars'].length;
                        i++) {
                      final key = GlobalKey(
                          debugLabel:
                              snapshot.data['extracurriculars'][i].toString());
                      ecs.add(
                        Padding(
                          padding: EdgeInsets.only(
                              top: 4, left: 15, right: 25, bottom: 4),
                          child: Card(
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                                side: BorderSide(
                                    color: Color(0xff005fa8), width: 0.8),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            elevation: 2,
                            child: Material(
                              color: Colors.transparent,
                              child: Tooltip(
                                padding: EdgeInsets.all(10),
                                margin: EdgeInsets.all(5),
                                key: key,
                                message: 'Description: ' +
                                    (snapshot.data['extracurriculars'][i]
                                                ['ec_description'] !=
                                            ''
                                        ? snapshot.data['extracurriculars'][i]
                                            ['ec_description']
                                        : 'No description provided'),
                                child: ListTile(
                                  dense: true,
                                  title: Text(
                                    snapshot.data['extracurriculars'][i]
                                        ['ec_title'],
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 15),
                                  ),
                                  subtitle: Text(
                                    '${snapshot.data['extracurriculars'][i]['ec_start_date']} to ${snapshot.data['extracurriculars'][i]['ec_end_date']}',
                                    style: TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  onTap: () {
                                    final dynamic tooltip = key.currentState;
                                    tooltip.ensureTooltipVisible();
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    for (int i = 0;
                        i < snapshot.data['misc_docs'].length;
                        i++) {
                      misc.add(
                        Padding(
                          padding: EdgeInsets.only(
                              top: 4, left: 15, right: 25, bottom: 4),
                          child: Card(
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                                side: BorderSide(
                                    color: Color(0xff005fa8), width: 0.8),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            elevation: 2,
                            child: Material(
                              color: Colors.transparent,
                              child: ListTile(
                                dense: true,
                                title: Text(
                                  snapshot.data['misc_docs'][i]['title'],
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 15),
                                ),
                                subtitle: Text(
                                  snapshot.data['misc_docs'][i]
                                      ['misc_doc_type'],
                                  style: TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w400),
                                ),
                                onTap: () {
                                  launch(snapshot.data['misc_docs'][i]
                                      ['misc_doc_path']);
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    for (int i = 0;
                        i < snapshot.data['test_scores'].length;
                        i++) {
                      scores.add(
                        Card(
                          clipBehavior: Clip.antiAlias,
                          elevation: 3,
                          margin: EdgeInsets.only(
                              top: 5, left: 19, right: 29, bottom: 4),
                          shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: Color(0xff005fa8), width: 0.8),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          child: InkWell(
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(left: 6),
                                    child: Row(
                                      children: <Widget>[
                                        SizedBox(
                                          width: 60,
                                          child: Image.network(
                                            snapshot.data['test_scores'][i]
                                                        ['test_type'] ==
                                                    'Advanced Placement'
                                                ? 'https://d31kydh6n6r5j5.cloudfront.net/uploads/sites/202/2020/01/cb-ap-logo.png'
                                                : snapshot.data['test_scores']
                                                            [i]['test_type'] ==
                                                        'SAT'
                                                    ? 'https://p15cdn4static.sharpschool.com/UserFiles/Servers/Server_68836/Image/College%20Board%20SAT.jpg'
                                                    : snapshot.data['test_scores'][i]
                                                                ['test_type'] ==
                                                            'ACT'
                                                        ? 'https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcTSaMTwrkbcLq4PZGW_Z8vcmrL8UEENzymwBA&usqp=CAU'
                                                        : snapshot.data['test_scores'][i]['test_type'] == 'TOEFL'
                                                            ? 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9c/TOEFL_Logo.svg/1280px-TOEFL_Logo.svg.png'
                                                            : snapshot.data['test_scores'][i]['test_type'] == 'IELTS'
                                                                ? 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7f/IELTS_logo.svg/1280px-IELTS_logo.svg.png'
                                                                : snapshot.data['test_scores'][i]
                                                                            ['test_type'] ==
                                                                        'SAT Subject Test'
                                                                    ? 'https://i.ibb.co/9hRGHBS/SUBJECT.png'
                                                                    : null,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 3, left: 6),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          snapshot.data['test_scores'][i]
                                                  ['score']
                                              .toString(),
                                          style: TextStyle(fontSize: 17),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(top: 2),
                                          child: Text(
                                            '/' +
                                                snapshot.data['test_scores'][i]
                                                        ['max_score']
                                                    .toString(),
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.black54),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 2, left: 7),
                                    child: Text(
                                      DateFormat.yMMMMd('en_US').format(
                                        DateTime.parse(
                                            snapshot.data['test_scores'][i]
                                                    ['date_of_test'] +
                                                'T00:00:00Z'),
                                      ),
                                      style: TextStyle(
                                          fontSize: 11.5,
                                          color: Colors.black87),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {
                              launch(snapshot.data['test_scores'][i]
                                  ['document_url']);
                            },
                          ),
                        ),
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(left: 15, top: 14),
                          child: Text(
                            'Transcripts',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Column(
                          children: transcripts.length == 0
                              ? [
                                  Padding(
                                    padding: EdgeInsets.only(left: 17),
                                    child: Text(
                                      'No Transcripts',
                                      style: TextStyle(
                                          color: Colors.black54, fontSize: 11),
                                    ),
                                  )
                                ]
                              : transcripts,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 15, top: 8),
                          child: Text(
                            'Extracurriculars',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Column(
                          children: ecs.length == 0
                              ? [
                                  Padding(
                                    padding: EdgeInsets.only(left: 15),
                                    child: Text(
                                      'No Extracurriculars',
                                      style: TextStyle(
                                          color: Colors.black54, fontSize: 11),
                                    ),
                                  )
                                ]
                              : ecs,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 15, top: 8),
                          child: Text(
                            'Misc',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Column(
                          children: misc.length == 0
                              ? [
                                  Padding(
                                    padding: EdgeInsets.only(left: 15),
                                    child: Text(
                                      'No Misc Documents',
                                      style: TextStyle(
                                          color: Colors.black54, fontSize: 11),
                                    ),
                                  )
                                ]
                              : misc,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 15, top: 8),
                          child: Text(
                            'Test Scores',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 14),
                          child: Column(
                            children: scores.length == 0
                                ? [
                                    Padding(
                                      padding: EdgeInsets.only(left: 17),
                                      child: Text(
                                        'No Test Scores',
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 11),
                                      ),
                                    )
                                  ]
                                : scores,
                          ),
                        ),
                      ],
                    );
                  }
                  return Padding(
                    padding: EdgeInsets.only(top: 30, bottom: 30),
                    child: Center(
                      child: SpinKitWave(color: Colors.grey, size: 30),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
