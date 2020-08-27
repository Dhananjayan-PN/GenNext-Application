import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../imports.dart';
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

  void refresh() {
    setState(() {
      applications = getApplications();
    });
  }

  Widget buildAppCard(application) {
    DateTime deadline = DateTime.parse(application["application_deadline"]);
    var timeleft = DateTime.now().isBefore(deadline)
        ? deadline.difference(DateTime.now()).inDays
        : 'Passed';
    Color timecolor =
        timeleft is int && timeleft < 10 ? Colors.red : Colors.white;
    if (timeleft is int) {
      timeleft = timeleft.toString() + ' days';
    }
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
              key: Key(application['application_id'].toString()),
              title: Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  application['university'],
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w500),
                ),
              ),
              subtitle: Padding(
                padding: EdgeInsets.only(top: 2, bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          'Due: ',
                          style: TextStyle(
                            fontSize: 13.5,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          DateFormat.yMMMMd('en_US').format(deadline) +
                              ' ($timeleft)',
                          style: TextStyle(
                              fontSize: 13.5,
                              color: timecolor,
                              fontWeight: timecolor == Colors.red
                                  ? FontWeight.w600
                                  : null),
                        ),
                      ],
                    ),
                    application["completion_status"]
                        ? Text('Completed',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                              fontSize: 13.5,
                            ))
                        : Text(
                            'Pending',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                              fontSize: 13.5,
                            ),
                          )
                  ],
                ),
              ),
              onTap: () async {
                // ignore: unused_local_variable
                final bool data = await Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.rightToLeftWithFade,
                    child: SingleAppScreen(
                      application: application,
                    ),
                  ),
                );
                refresh();
              },
            ),
          ),
        );
    return Hero(
      tag: application['application_id'].toString(),
      child: Card(
        margin: EdgeInsets.only(top: 7, left: 15, right: 15, bottom: 7),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        elevation: 6,
        child: CachedNetworkImage(
          imageUrl: application['image_url'] ??
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
                i++) {
              pending.add(buildAppCard(
                  snapshot.data['incomplete_application_data'][i]));
            }
            for (int i = 0;
                i < snapshot.data['completed_application_data'].length;
                i++) {
              completed.add(
                  buildAppCard(snapshot.data['completed_application_data'][i]));
            }
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

class SingleAppScreen extends StatefulWidget {
  final Map application;
  SingleAppScreen({@required this.application});
  @override
  _SingleAppScreenState createState() => _SingleAppScreenState();
}

class _SingleAppScreenState extends State<SingleAppScreen> {
  TextEditingController _appNotes = TextEditingController();

  List<Widget> essayCards;
  List<Widget> transcriptCards;
  List<Widget> miscCards;
  Map app;
  Map unattachedDocs;
  bool saved = true;
  bool saving = false;
  bool savingfailed = false;
  Future applicationNotes;

  @override
  void initState() {
    super.initState();
    app = widget.application;
    _appNotes.text = app['application_notes'] ?? '';
    getApplication();
  }

  Future<void> getApplication() async {
    String tok = await getToken();
    final response = await http.get(
      dom + 'api/student/get-application/${app['application_id']}',
      headers: {HttpHeaders.authorizationHeader: "Token $tok"},
    );
    if (response.statusCode == 200) {
      setState(() {
        app = json.decode(response.body)['application_data'];
        app['university_id'] = widget.application['university_id'];
      });
      setState(() {});
    } else {
      throw 'failed';
    }
  }

  void refresh() async {
    setState(() {
      getApplication();
    });
  }

  Widget buildEssayCard(essay) {
    return Padding(
      padding: EdgeInsets.only(left: 15, right: 15),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
            side: BorderSide(
                color: essay['essay_approval_status'] == 'Y'
                    ? Colors.green
                    : essay['essay_approval_status'] == 'N' &&
                            essay['student_essay_content'] != ''
                        ? Colors.orange
                        : Colors.red,
                width: 0.8),
            borderRadius: BorderRadius.all(Radius.circular(5))),
        elevation: 2,
        child: Material(
          color: Colors.transparent,
          child: ListTile(
            dense: true,
            key: Key(essay['essay_id'].toString()),
            title: Padding(
              padding: EdgeInsets.only(top: 5),
              child: Text(
                essay['essay_title'],
                style: TextStyle(color: Colors.black, fontSize: 15),
              ),
            ),
            subtitle: essay['essay_approval_status'] == 'Y'
                ? Text(
                    'Complete',
                    style: TextStyle(
                        color: Colors.green, fontWeight: FontWeight.w400),
                  )
                : essay['essay_approval_status'] == 'N' &&
                        essay['student_essay_content'] != ''
                    ? Text(
                        'In Progress',
                        style: TextStyle(
                            color: Colors.orange, fontWeight: FontWeight.w400),
                      )
                    : Text(
                        'Pending',
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.w400),
                      ),
          ),
        ),
      ),
    );
  }

  Widget buildTranscriptCard(transcript) {
    return Padding(
      padding: EdgeInsets.only(left: 15, right: 15),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
            side: BorderSide(
                color: transcript['in_progress'] ? Colors.green : Colors.red,
                width: 0.8),
            borderRadius: BorderRadius.all(Radius.circular(5))),
        elevation: 2,
        child: Material(
          color: Colors.transparent,
          child: ListTile(
            isThreeLine: true,
            dense: true,
            key: Key(transcript['transcript_id'].toString()),
            title: Padding(
              padding: EdgeInsets.only(top: 5),
              child: Text(
                transcript['title'],
                style: TextStyle(color: Colors.black, fontSize: 15),
              ),
            ),
            subtitle: Padding(
              padding: EdgeInsets.only(bottom: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Grade ${transcript['grade']}',
                      style: TextStyle(color: Colors.black54)),
                  transcript['in_progress']
                      ? Text(
                          'Complete',
                          style: TextStyle(
                              color: Colors.green, fontWeight: FontWeight.w400),
                        )
                      : Text(
                          'Pending',
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.w400),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildMiscCard(document) {
    return Padding(
      padding: EdgeInsets.only(left: 15, right: 15),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
            side: BorderSide(
                color: document['in_progress'] ? Colors.green : Colors.red,
                width: 0.8),
            borderRadius: BorderRadius.all(Radius.circular(5))),
        elevation: 2,
        child: Material(
          color: Colors.transparent,
          child: ListTile(
            isThreeLine: true,
            dense: true,
            key: Key(document['misc_doc_id'].toString()),
            title: Padding(
              padding: EdgeInsets.only(top: 5),
              child: Text(
                document['title'],
                style: TextStyle(color: Colors.black, fontSize: 15),
              ),
            ),
            subtitle: Padding(
              padding: EdgeInsets.only(bottom: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(document['misc_doc_type'],
                      style: TextStyle(color: Colors.black54)),
                  document['in_progress']
                      ? Text(
                          'Complete',
                          style: TextStyle(
                              color: Colors.green, fontWeight: FontWeight.w400),
                        )
                      : Text(
                          'Pending',
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.w400),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    essayCards = [];
    transcriptCards = [];
    miscCards = [];
    DateTime deadline = DateTime.parse(app["application_deadline"]);
    var timeleft = DateTime.now().isBefore(deadline)
        ? deadline.difference(DateTime.now()).inDays
        : 'Passed';
    Color timecolor =
        timeleft is int && timeleft < 10 ? Colors.red : Colors.white;
    if (timeleft is int) {
      timeleft = timeleft.toString() + ' days';
    }
    for (int i = 0; i < app['essay_data'].length; i++) {
      essayCards.add(buildEssayCard(app['essay_data'][i]));
    }
    for (int i = 0; i < app['transcript_data'].length; i++) {
      transcriptCards.add(buildTranscriptCard(app['transcript_data'][i]));
    }
    for (int i = 0; i < app['misc_doc_data'].length; i++) {
      miscCards.add(buildMiscCard(app['misc_doc_data'][i]));
    }
    Widget cardData(ImageProvider imageProvider, bool isError) => Container(
          decoration: BoxDecoration(
            color: isError ? Color(0xff005fa8) : null,
            image: imageProvider != null
                ? DecorationImage(
                    alignment: Alignment.center,
                    colorFilter: ColorFilter.mode(
                        Colors.black.withAlpha(120), BlendMode.darken),
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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Spacer(),
                    Padding(
                      padding: EdgeInsets.only(right: 5, top: 5),
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: app['completion_status']
                              ? Colors.green
                              : Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(left: 15),
                  child: Text(
                    app["university"],
                    style: TextStyle(
                        fontSize: 19,
                        color: Colors.white,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 12, left: 15),
                  child: Text(
                    'Deadline',
                    style: TextStyle(
                        fontSize: 14, color: Colors.white.withOpacity(0.9)),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 1, left: 15),
                  child: Text(
                    DateFormat.yMMMMd().format(
                          DateTime.parse(
                            app["application_deadline"],
                          ),
                        ) +
                        ' ($timeleft)',
                    style: TextStyle(
                        color: timecolor,
                        fontSize: 15,
                        fontWeight:
                            timecolor == Colors.red ? FontWeight.w600 : null),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 12, left: 15),
                  child: Text(
                    'Created',
                    style: TextStyle(
                        fontSize: 14, color: Colors.white.withOpacity(0.9)),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 1, left: 15, bottom: 16),
                  child: Text(
                    DateFormat.yMMMMd().format(
                      DateTime.parse(
                        app["created_at"],
                      ),
                    ),
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
        );
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xff005fa8),
        title: Text('Student Application'),
      ),
      body: ListView(
        children: <Widget>[
          Hero(
            tag: app['application_id'].toString(),
            child: Padding(
              padding: EdgeInsets.only(left: 12, right: 12, top: 18),
              child: Material(
                type: MaterialType.transparency,
                shadowColor: Colors.grey.withOpacity(0.5),
                color: Colors.transparent,
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  elevation: 6,
                  child: CachedNetworkImage(
                      key: Key(app['application_id'].toString()),
                      imageUrl: app['image_url'] ??
                          'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cd/Black_flag.svg/1200px-Black_flag.svg.png',
                      placeholder: (context, url) => CardPlaceHolder(),
                      errorWidget: (context, url, error) =>
                          cardData(null, true),
                      imageBuilder: (context, imageProvider) =>
                          cardData(imageProvider, false)),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 12, right: 12, top: 10),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              child: ExpansionTile(
                initiallyExpanded: app['essay_data'].isNotEmpty,
                title: Text('Essays'),
                children: essayCards.isNotEmpty
                    ? [
                        ...essayCards,
                        Padding(
                          padding: EdgeInsets.only(bottom: 10),
                        )
                      ]
                    : [
                        Padding(
                          padding: EdgeInsets.only(
                              left: 20, right: 20, top: 5, bottom: 15),
                          child: Text(
                            'No essays attached to this application.',
                            style:
                                TextStyle(fontSize: 12, color: Colors.black54),
                            textAlign: TextAlign.center,
                          ),
                        )
                      ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 12, right: 12, top: 10),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              elevation: 4,
              child: ExpansionTile(
                initiallyExpanded: app['transcript_data'].isNotEmpty,
                title: Text('Transcripts'),
                children: transcriptCards.isNotEmpty
                    ? [
                        ...transcriptCards,
                        Padding(
                          padding: EdgeInsets.only(bottom: 10),
                        )
                      ]
                    : [
                        Padding(
                          padding: EdgeInsets.only(
                              left: 20, right: 20, top: 5, bottom: 15),
                          child: Text(
                            'No transcripts attached to this application.',
                            style:
                                TextStyle(fontSize: 12, color: Colors.black54),
                            textAlign: TextAlign.center,
                          ),
                        )
                      ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 12, right: 12, top: 10),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              child: ExpansionTile(
                initiallyExpanded: app['misc_doc_data'].isNotEmpty,
                title: Text('Misc Documents'),
                children: miscCards.isNotEmpty
                    ? [
                        ...miscCards,
                        Padding(
                          padding: EdgeInsets.only(bottom: 10),
                        )
                      ]
                    : [
                        Padding(
                          padding: EdgeInsets.only(
                              left: 20, right: 20, top: 5, bottom: 15),
                          child: Text(
                            'No misc documents attached to this application.',
                            style:
                                TextStyle(fontSize: 12, color: Colors.black54),
                            textAlign: TextAlign.center,
                          ),
                        )
                      ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 20, top: 10, left: 12, right: 12),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              elevation: 4,
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
                              padding: EdgeInsets.only(left: 15, right: 5),
                              child: Icon(
                                Icons.edit,
                                size: 20,
                                color: Colors.black.withOpacity(0.8),
                              ),
                            ),
                            Text(
                              'Application Notes',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black.withOpacity(0.8)),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        Spacer(),
                      ],
                    ),
                  ),
                  Divider(thickness: 0, indent: 25, endIndent: 25),
                  Builder(builder: (context) {
                    return Padding(
                      padding: EdgeInsets.only(
                          top: 5, left: 20, right: 20, bottom: 12),
                      child: TextField(
                        enabled: false,
                        cursorColor: Color(0xff005fa8),
                        controller: _appNotes,
                        autocorrect: true,
                        maxLines: null,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black87),
                              borderRadius: BorderRadius.circular(10)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          hintText:
                              'Take note of important stuff for this app...',
                          hintStyle:
                              TextStyle(color: Colors.black54, fontSize: 14),
                        ),
                      ),
                    );
                  })
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
