import '../imports.dart';
import 'package:http/http.dart' as http;
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
              student['profile_pic'] ??
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
  @override
  Widget build(BuildContext context) {
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
              elevation: 6,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage: CachedNetworkImageProvider(
                        widget.student['profile_pic'] ??
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
                            widget.student['student_grade'],
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
            padding: EdgeInsets.only(top: 15, left: 10, right: 10),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              elevation: 6,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(left: 22, top: 15, bottom: 5),
                    child: Row(
                      children: [
                        Icon(
                          Icons.contact_mail,
                          size: 18,
                          color: Color(0xff005fa8).withOpacity(0.8),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text(
                            'Student Preferences',
                            style: TextStyle(fontSize: 17),
                          ),
                        ),
                      ],
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
                    padding: EdgeInsets.only(top: 5, left: 21, bottom: 15),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
