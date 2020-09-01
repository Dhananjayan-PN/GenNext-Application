import 'package:http/http.dart' as http;
import '../imports.dart';
import 'home.dart';

class EssaysScreen extends StatefulWidget {
  @override
  _EssaysScreenState createState() => _EssaysScreenState();
}

class _EssaysScreenState extends State<EssaysScreen> {
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
            // ignore: unused_local_variable
            List data = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StudentEssays(
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
      appBar: CustomAppBar('Essays'),
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
                        Text(
                          'Oh Snap!',
                          style: TextStyle(fontSize: 18, color: Colors.black54),
                        ),
                        Padding(
                            padding:
                                EdgeInsets.only(top: 5, left: 30, right: 30),
                            child: Text(
                              "Looks like you don't counsel\nany students at the moment :(",
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

class StudentEssays extends StatefulWidget {
  final int id;
  StudentEssays({@required this.id});
  @override
  _StudentEssaysState createState() => _StudentEssaysState();
}

class _StudentEssaysState extends State<StudentEssays> {
  Future essayList;

  @override
  void initState() {
    super.initState();
    essayList = getEssays();
  }

  Future<void> getEssays() async {
    String tok = await getToken();
    final response = await http.get(
      dom + 'api/counselor/essays/${widget.id}',
      headers: {HttpHeaders.authorizationHeader: "Token $tok"},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body)['essay_data'];
    } else {
      throw 'failed';
    }
  }

  Widget buildEssayCard(essay) {
    return Card(
      margin: EdgeInsets.only(top: 7, left: 15, right: 15, bottom: 7),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      elevation: 6,
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          key: Key(essay['essay_id'].toString()),
          title: Padding(
            padding: EdgeInsets.only(top: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.65,
                    child: Text(
                      essay['essay_title'],
                      style: TextStyle(color: Colors.black, fontSize: 17),
                    ),
                  ),
                ),
                Spacer(),
                Padding(
                  padding: EdgeInsets.only(top: 5, right: 10),
                  child: ClipOval(
                    child: Material(
                      child: InkWell(
                        child: Icon(
                          Icons.create,
                          color: Colors.black.withOpacity(0.75),
                        ),
                        onTap: () async {
                          String studentString = essay[
                                          'student_essay_content'] ==
                                      '' ||
                                  essay['student_essay_content'] == null
                              ? '[{\"attributes\":{\"align\":\"justify\"},\"insert\":\"\\n\"},{\"insert\":\"\\n\"}]'
                              : essay['student_essay_content'];
                          String counselorString = essay[
                                          'counselor_essay_content'] ==
                                      '' ||
                                  essay['counselor_essay_content'] == null
                              ? '[{\"attributes\":{\"align\":\"justify\"},\"insert\":\"\\n\"},{\"insert\":\"\\n\"}]'
                              : essay['counselor_essay_content'];
                          // ignore: unused_local_variable
                          final editedEssayContent = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EssayEditor(
                                essayTitle: essay['essay_title'],
                                essayPrompt: essay['essay_prompt'],
                                studentEdit:
                                    QuillZefyrBijection.convertJSONToZefyrDelta(
                                        '{\"ops\":' + studentString + '}'),
                                counselorEdit:
                                    QuillZefyrBijection.convertJSONToZefyrDelta(
                                        '{\"ops\":' + counselorString + '}'),
                              ),
                            ),
                          );
                          // if (editedEssayContent != null) {
                          //   editEssay(essay, editedEssayContent);
                          //   loading(context);
                          // }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          subtitle: Padding(
            padding: EdgeInsets.only(left: 2, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                essay['essay_approval_status'] == 'Y'
                    ? Text(
                        'Complete',
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.green,
                            fontWeight: FontWeight.w400),
                      )
                    : essay['essay_approval_status'] == 'N' &&
                            essay['student_essay_content'] != ''
                        ? Text(
                            'In Progress',
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.orange,
                                fontWeight: FontWeight.w400),
                          )
                        : Text(
                            'Pending',
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.red,
                                fontWeight: FontWeight.w400),
                          ),
              ],
            ),
          ),
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
        title: Text(
          'Student Essays',
        ),
      ),
      body: FutureBuilder(
        future: essayList.timeout(Duration(seconds: 10)),
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
                        padding: EdgeInsets.only(bottom: 10),
                        child: Icon(
                          Icons.edit,
                          size: 35,
                          color: Colors.black.withOpacity(0.75),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 5, left: 30, right: 30),
                        child: Text(
                          "Student hasn't added any essays yet.",
                          style: TextStyle(color: Colors.black54),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 3),
                        child: Text(
                            "Schedule a session with them to start one!",
                            style: TextStyle(color: Colors.black54),
                            textAlign: TextAlign.center),
                      )
                    ],
                  ),
                ),
              );
            } else {
              return ListView.builder(
                padding: EdgeInsets.only(top: 20),
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) =>
                    buildEssayCard(snapshot.data[index]),
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
    );
  }
}

class EssayEditor extends StatefulWidget {
  final Delta studentEdit;
  final Delta counselorEdit;
  final String essayTitle;
  final String essayPrompt;

  EssayEditor(
      {this.essayTitle,
      this.essayPrompt,
      this.studentEdit,
      this.counselorEdit});

  @override
  _EssayEditorState createState() => _EssayEditorState(
      essayTitle: essayTitle,
      essayPrompt: essayPrompt,
      studentEdit: studentEdit,
      counselorEdit: counselorEdit);
}

class _EssayEditorState extends State<EssayEditor> {
  final Delta studentEdit;
  final Delta counselorEdit;
  final String essayTitle;
  final String essayPrompt;
  ZefyrController _controller1;
  ZefyrController _controller2;
  FocusNode _focusNode1;
  FocusNode _focusNode2;
  NotusDocument studentDocument;
  NotusDocument counselorDocument;

  _EssayEditorState(
      {this.essayTitle,
      this.essayPrompt,
      this.studentEdit,
      this.counselorEdit});

  @override
  void initState() {
    super.initState();
    _focusNode1 = FocusNode();
    studentDocument = _loadSDocument();
    _controller1 = ZefyrController(studentDocument);
    _focusNode2 = FocusNode();
    counselorDocument = _loadCDocument();
    _controller2 = ZefyrController(counselorDocument);
    BackButtonInterceptor.add(myInterceptor);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    Navigator.pop(context);
    return true;
  }

  NotusDocument _loadSDocument() {
    return NotusDocument.fromDelta(studentEdit);
  }

  NotusDocument _loadCDocument() {
    return NotusDocument.fromDelta(counselorEdit);
  }

  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Color(0xff005fa8),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'SAVE',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 15),
              ),
              onPressed: () {
                final data = jsonEncode(_controller2.document);
                Navigator.pop(context, data);
              },
            )
          ],
          title: Text(
            essayTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          bottom: TabBar(
            tabs: [
              Tab(
                  child: Padding(
                padding: EdgeInsets.only(left: 3.0),
                child: Text('Student Version'),
              )),
              Tab(
                  child: Padding(
                padding: EdgeInsets.only(left: 3.0),
                child: Text('My Version'),
              )),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            Theme(
              data: ThemeData(cursorColor: Color(0xff005fa8)),
              child: ZefyrScaffold(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 13, left: 15, right: 15),
                      child: Text(
                        'Prompt:',
                        style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 15, right: 15),
                      child: ExpandText(
                        this.essayPrompt ?? '',
                        expandOnGesture: true,
                        textAlign: TextAlign.left,
                        style: TextStyle(color: Colors.black87, fontSize: 15),
                        arrowPadding: EdgeInsets.all(0),
                        maxLines: 1,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 5, bottom: 5),
                      child: Divider(
                        thickness: 0.5,
                        endIndent: 40,
                        indent: 40,
                      ),
                    ),
                    Expanded(
                      child: ZefyrEditor(
                        mode: ZefyrMode(
                            canEdit: false, canFormat: false, canSelect: true),
                        padding: EdgeInsets.only(
                            left: 16, right: 16, top: 0, bottom: 10),
                        controller: _controller1,
                        focusNode: _focusNode1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Theme(
              data: ThemeData(cursorColor: Color(0xff005fa8)),
              child: ZefyrScaffold(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 13, left: 15, right: 15),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Prompt:',
                          style: TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 15, right: 15),
                      child: ExpandText(
                        this.essayPrompt ?? '',
                        textAlign: TextAlign.left,
                        arrowPadding: EdgeInsets.all(0),
                        maxLines: 1,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 5, bottom: 5),
                      child: Divider(
                        thickness: 0.5,
                        endIndent: 40,
                        indent: 40,
                      ),
                    ),
                    Expanded(
                      child: ZefyrEditor(
                        padding: EdgeInsets.only(
                            left: 16, right: 16, top: 0, bottom: 10),
                        controller: _controller2,
                        focusNode: _focusNode2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
