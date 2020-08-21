import '../imports.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'home.dart';

class StudentsScreen extends StatefulWidget {
  @override
  _StudentsScreenState createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
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
              student['student_profile_img'] ??
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
                builder: (context) => StudentApplicationsScreen(
                  id: student['student_id'],
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
      appBar: CustomAppBar('Applications'),
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

class StudentApplicationsScreen extends StatefulWidget {
  final int id;
  StudentApplicationsScreen({this.id});
  @override
  _StudentApplicationsScreenState createState() =>
      _StudentApplicationsScreenState();
}

class _StudentApplicationsScreenState extends State<StudentApplicationsScreen> {
  List<Widget> pending;
  List<Widget> completed;
  Future applications;

  @override
  void initState() {
    super.initState();
    applications = getApplications();
  }

  Future<void> getApplications() async {
    String tok = await getToken();
    final response = await http.get(
      dom + 'api/counselor/get-applications/${widget.id}',
      headers: {HttpHeaders.authorizationHeader: "Token $tok"},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw 'failed';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xff005fa8),
        title: Text('Student Applications'),
      ),
      body: FutureBuilder(
        future: applications,
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
            pending = [];
            completed = [];
            for (int i = 0;
                i < snapshot.data['incomplete_application_data'].length;
                i++) {}
            for (int i = 0;
                i < snapshot.data['completed_application_data'].length;
                i++) {}
            return ListView(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 15, top: 20),
                  child: Text(
                    'Pending',
                    style: TextStyle(color: Colors.black87, fontSize: 24),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: pending.length == 0
                      ? [
                          Padding(
                            padding: EdgeInsets.only(left: 16),
                            child: Text(
                              'No Pending Applications',
                              style: TextStyle(
                                  color: Colors.black54, fontSize: 14),
                            ),
                          )
                        ]
                      : pending,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 15, top: 20),
                  child: Text(
                    'Completed',
                    style: TextStyle(color: Colors.black87, fontSize: 24),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: completed.length == 0
                      ? [
                          Padding(
                            padding: EdgeInsets.only(left: 16),
                            child: Text(
                              'No Completed Applications',
                              style: TextStyle(
                                  color: Colors.black54, fontSize: 14),
                            ),
                          )
                        ]
                      : completed,
                ),
              ],
            );
          }
          return Center(
            child: SpinKitWave(color: Colors.grey, size: 40),
          );
        },
      ),
    );
  }
}
