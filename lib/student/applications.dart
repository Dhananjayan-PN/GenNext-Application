import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'home.dart';
import 'essays.dart';
import 'documents.dart';
import '../shimmer_skeleton.dart';

class ApplicationsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ApplicationsScreenState();
}

class ApplicationsScreenState extends State<ApplicationsScreen> {
  GlobalKey<ScaffoldState> _scafKey = GlobalKey<ScaffoldState>();
  var refreshKey1 = GlobalKey<RefreshIndicatorState>();
  var refreshKey2 = GlobalKey<RefreshIndicatorState>();
  TextEditingController controller1 = TextEditingController();
  TextEditingController controller2 = TextEditingController();
  String filter1;
  String filter2;
  Map<String, int> uniIds = {};
  List<DropdownMenuItem<String>> uniList = [];
  Future completedApps;
  Future pendingApps;

  @override
  void initState() {
    super.initState();
    controller1.addListener(() {
      setState(() {
        filter1 = controller1.text.toLowerCase();
      });
    });
    controller2.addListener(() {
      setState(() {
        filter2 = controller2.text.toLowerCase();
      });
    });
    completedApps = getCompletedApplications();
    pendingApps = getPendingApplications();
    getAvailableUniversities();
    BackButtonInterceptor.add(myInterceptor);
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

  Future<void> getAvailableUniversities() async {
    uniIds = {};
    uniList = [];
    final response = await http.get(
      dom + 'api/student/get-all-universities',
      headers: {HttpHeaders.authorizationHeader: "Token $tok"},
    );
    if (response.statusCode == 200) {
      List universities = json.decode(response.body)['university_data'];
      for (var i = 0; i < universities.length; i++) {
        var name = universities[i]['university_name'];
        var id = universities[i]['university_id'];
        uniIds[name] = id;
        uniList.add(
          DropdownMenuItem<String>(
            value: name,
            child: Text(
              name,
              style: TextStyle(fontSize: 15),
            ),
          ),
        );
      }
    } else {
      Navigator.pop(context);
      error(context);
    }
  }

  Future<void> getCompletedApplications() async {
    final response = await http.get(
      dom + 'api/student/get-applications',
      headers: {HttpHeaders.authorizationHeader: "Token $tok"},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body)['completed_application_data'];
    } else {
      throw 'failed';
    }
  }

  Future<void> getPendingApplications() async {
    final response = await http.get(
      dom + 'api/student/get-applications',
      headers: {HttpHeaders.authorizationHeader: "Token $tok"},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body)['incomplete_application_data'];
    } else {
      throw 'failed';
    }
  }

  Future<void> editApplication(
      Map application, DateTime deadline, String notes) async {
    List essayList = [];
    List transcriptList = [];
    List miscList = [];
    for (int i = 0; i < application['essay_data'].length; i++) {
      essayList.add(application['essay_data'][i]['essay_id']);
    }
    for (int i = 0; i < application['transcript_data'].length; i++) {
      transcriptList.add(application['transcript_data'][i]['transcript_id']);
    }
    for (int i = 0; i < application['misc_doc_data'].length; i++) {
      miscList.add(application['misc_doc_data'][i]['misc_doc_id']);
    }
    final response = await http.put(
      dom + 'api/student/edit-application',
      headers: {
        HttpHeaders.authorizationHeader: "Token $tok",
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
        <String, dynamic>{
          'application_id': application['application_id'],
          'university_id': uniIds[application['university']],
          'application_deadline': deadline.toIso8601String().substring(0, 10),
          'application_notes': notes,
          'application_status': application['completion_status'],
          'essay_ids': essayList.toString(),
          'transcript_ids': transcriptList.toString(),
          'misc_doc_ids': miscList.toString(),
        },
      ),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['response'] == 'Application successfully edited.') {
        Navigator.pop(context);
        success(context, 'Application successfully edited\nGet working!');
        refresh();
      } else {
        Navigator.pop(context);
        error(context);
      }
    } else {
      Navigator.pop(context);
      error(context);
    }
  }

  Future<void> deleteApplication(int id) async {
    final response = await http.delete(
      dom + 'api/student/delete-application/$id',
      headers: {HttpHeaders.authorizationHeader: "Token $tok"},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['Response'] == 'Application successfully deleted.') {
        Navigator.pop(context);
        success(context,
            'Application successfully deleted\nTap + to make a new one');
        refresh();
      } else {
        Navigator.pop(context);
        error(context);
      }
    } else {
      Navigator.pop(context);
      error(context);
    }
  }

  Future<void> createApplication(
      String uniName, DateTime deadline, String notes) async {
    final response = await http.post(
      dom + 'api/student/create-application',
      headers: <String, String>{
        HttpHeaders.authorizationHeader: "Token $tok",
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: json.encode(
        <String, dynamic>{
          "student_id": newUser.id,
          "university_id": uniIds[uniName],
          "application_deadline": deadline.toIso8601String().substring(0, 10),
          "application_notes": notes,
        },
      ),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['response'] == 'Application successfully created.') {
        Navigator.pop(context);
        success(context, 'Application successfully created\nGet working!');
        refresh();
      } else {
        Navigator.pop(context);
        error(context);
      }
    } else {
      Navigator.pop(context);
      error(context);
    }
  }

  _deleteApplication(int id) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(0),
          elevation: 20,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          content: Container(
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 18),
                  child: Icon(
                    Icons.delete,
                    size: 40,
                    color: Colors.red.withOpacity(0.9),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Text(
                    'Are you sure you want to delete\nthis application?',
                    style: TextStyle(color: Colors.black, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: Color(0xff005fa8)),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.pop(context);
                deleteApplication(id);
                loading(context);
              },
            ),
          ],
        );
      },
    );
  }

  void refresh() {
    setState(() {
      completedApps = getCompletedApplications();
      pendingApps = getPendingApplications();
      getAvailableUniversities();
    });
  }

  Widget buildCard(application) {
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
            gradient: isError
                ? LinearGradient(
                    end: Alignment.topRight,
                    begin: Alignment.bottomLeft,
                    colors: [Color(0xff00AEEF), Color(0xff0072BC)])
                : null,
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
                      Text(
                        'Due: ' +
                            DateFormat.yMMMMd('en_US').format(deadline) +
                            ' ($timeleft)',
                        style: TextStyle(
                            fontSize: 13.5,
                            color: timecolor,
                            fontWeight: timecolor == Colors.red
                                ? FontWeight.w600
                                : null),
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
                trailing: Padding(
                  padding: EdgeInsets.only(top: 9.5, right: 3),
                  child: PopupMenuButton(
                    child: Icon(
                      Icons.more_vert,
                      color: Colors.white,
                    ),
                    itemBuilder: (BuildContext context) {
                      return {'Edit', 'Delete'}.map((String choice) {
                        return PopupMenuItem<String>(
                          height: 35,
                          value: choice,
                          child: Text(choice,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w400)),
                        );
                      }).toList();
                    },
                    onSelected: (value) async {
                      switch (value) {
                        case 'Edit':
                          final List details = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NewApplicationScreen(
                                op: 'Edit',
                                deadline: deadline,
                                notes: application['application_notes'],
                                university: application['university'],
                              ),
                            ),
                          );
                          editApplication(application, details[1], details[2]);
                          loading(context);
                          break;
                        case 'Delete':
                          _deleteApplication(application['application_id']);
                          break;
                      }
                    },
                  ),
                ),
                onTap: () async {
                  final bool data = await Navigator.push(
                    context,
                    PageTransition(
                        type: PageTransitionType.rightToLeftWithFade,
                        child: SingleAppScreen(
                          application: application,
                        )),
                  );
                  refresh();
                }),
          ),
        );
    return Hero(
      tag: application['application_id'].toString(),
      child: Padding(
        padding: EdgeInsets.only(top: 5, left: 10, right: 10),
        child: Material(
          shadowColor: Colors.grey.withOpacity(0.5),
          color: Colors.transparent,
          elevation: 8,
          child: Card(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10))),
            elevation: 0,
            child: CachedNetworkImage(
              imageUrl: application['image_url'] ??
                  'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cd/Black_flag.svg/1200px-Black_flag.svg.png',
              placeholder: (context, url) => CardSkeleton(
                padding: 0,
                isBottomLinesActive: false,
              ),
              errorWidget: (context, url, error) => cardData(null, true),
              imageBuilder: (context, imageProvider) =>
                  cardData(imageProvider, false),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: _scafKey,
        backgroundColor: Colors.white,
        drawer: NavDrawer(
            name: newUser.firstname + ' ' + newUser.lastname,
            email: newUser.email),
        appBar: AppBar(
          backgroundColor: Color(0xff005fa8),
          elevation: 6,
          title: Text(
            'My Applications',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: Platform.isIOS ? FontWeight.w500 : FontWeight.w400),
          ),
          bottom: TabBar(
            tabs: [
              Tab(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                    Icon(Icons.assignment_turned_in),
                    Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Text('Completed'),
                    )
                  ])),
              Tab(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                    Icon(Icons.assignment_late),
                    Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Text('Pending'),
                    )
                  ])),
            ],
          ),
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 8),
              child: IconButton(
                icon: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 26,
                ),
                onPressed: () async {
                  List data = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewApplicationScreen(
                        op: 'Create',
                        uniList: uniList,
                      ),
                    ),
                  );
                  if (data != null) {
                    createApplication(data[0], data[1], data[2]);
                    loading(context);
                  }
                },
              ),
            )
          ],
        ),
        body: TabBarView(
          children: <Widget>[
            RefreshIndicator(
              key: refreshKey1,
              onRefresh: () {
                refresh();
                return completedApps;
              },
              child: FutureBuilder(
                future: completedApps.timeout(Duration(seconds: 10)),
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
                                    "You haven't completed any applications yet.",
                                    style: TextStyle(color: Colors.black54),
                                    textAlign: TextAlign.center,
                                  )),
                              Padding(
                                padding: EdgeInsets.only(top: 3),
                                child: Text(
                                    "Complete a few to see them show up here!",
                                    style: TextStyle(color: Colors.black54),
                                    textAlign: TextAlign.center),
                              )
                            ],
                          ),
                        ),
                      );
                    } else {
                      return Column(
                        children: <Widget>[
                          Padding(
                            padding:
                                EdgeInsets.only(top: 5, left: 18, right: 30),
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
                                    decoration: InputDecoration(
                                        labelText: "Search",
                                        contentPadding: EdgeInsets.all(2)),
                                    controller: controller1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(top: 20.0),
                              child: Scrollbar(
                                child: ListView.builder(
                                    primary: true,
                                    scrollDirection: Axis.vertical,
                                    itemCount: snapshot.data.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return filter1 == null || filter1 == ""
                                          ? buildCard(snapshot.data[index])
                                          : snapshot.data[index]['university']
                                                  .toLowerCase()
                                                  .contains(filter1)
                                              ? buildCard(snapshot.data[index])
                                              : Container();
                                    }),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  }
                  return Padding(
                    padding: EdgeInsets.only(top: 60),
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
                return pendingApps;
              },
              child: FutureBuilder(
                future: pendingApps.timeout(Duration(seconds: 10)),
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
                                    "There are no pending applications at the time.",
                                    style: TextStyle(color: Colors.black54),
                                    textAlign: TextAlign.center,
                                  )),
                              Padding(
                                padding: EdgeInsets.only(top: 3),
                                child: Text("Tap + to create one in no time!",
                                    style: TextStyle(color: Colors.black54),
                                    textAlign: TextAlign.center),
                              )
                            ],
                          ),
                        ),
                      );
                    } else {
                      return Column(
                        children: <Widget>[
                          Padding(
                            padding:
                                EdgeInsets.only(top: 5, left: 18, right: 30),
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
                                    decoration: InputDecoration(
                                        labelText: "Search",
                                        contentPadding: EdgeInsets.all(2)),
                                    controller: controller2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(top: 20.0),
                              child: Scrollbar(
                                child: ListView.builder(
                                    primary: true,
                                    scrollDirection: Axis.vertical,
                                    itemCount: snapshot.data.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return filter2 == null || filter2 == ""
                                          ? buildCard(snapshot.data[index])
                                          : snapshot.data[index]['university']
                                                  .toLowerCase()
                                                  .contains(filter2)
                                              ? buildCard(snapshot.data[index])
                                              : Container();
                                    }),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  }
                  return CardListSkeleton(
                    isBottomLinesActive: false,
                    length: 10,
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

class NewApplicationScreen extends StatefulWidget {
  final String op;
  final List<DropdownMenuItem<String>> uniList;
  final String university;
  final String notes;
  final DateTime deadline;
  NewApplicationScreen(
      {@required this.op,
      this.uniList,
      this.notes,
      this.deadline,
      this.university});

  @override
  _NewApplicationScreenState createState() => _NewApplicationScreenState();
}

class _NewApplicationScreenState extends State<NewApplicationScreen> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _notes = TextEditingController();
  String uniName;
  TextEditingController _datetimecontroller = TextEditingController();
  DateTime _deadline;

  @override
  void initState() {
    super.initState();
    if (widget.deadline != null) {
      _datetimecontroller.text = DateFormat.yMMMMd().format(widget.deadline);
      _deadline = widget.deadline;
    } else {
      _datetimecontroller.text = null;
    }
    _notes.text = widget.notes ?? '';
    uniName = widget.university ?? null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xff005fa8),
        actions: <Widget>[
          FlatButton(
            child: Text(
              widget.op == 'Create' ? 'CREATE' : 'SAVE',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
            onPressed: () {
              if (uniName != null && _deadline != null) {
                List data = [uniName, _deadline, _notes.text];
                Navigator.pop(context, data);
              }
            },
          )
        ],
        title: Text(
          widget.op == 'Create' ? 'New Application' : 'Edit Application',
          maxLines: 1,
          style: TextStyle(
              color: Colors.white,
              fontWeight: Platform.isIOS ? FontWeight.w500 : FontWeight.w400),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 30, left: 25),
              child: Text(
                'University',
                style: TextStyle(fontSize: 20, color: Colors.black87),
              ),
            ),
            if (widget.op == 'Create') ...[
              Padding(
                padding: EdgeInsets.only(left: 25, right: 40),
                child: SearchableDropdown.single(
                  isCaseSensitiveSearch: false,
                  dialogBox: true,
                  menuBackgroundColor: Colors.white,
                  icon: Icon(
                    Icons.arrow_drop_down,
                    size: 25,
                    color: Colors.black,
                  ),
                  items: widget.uniList,
                  value: uniName,
                  style: TextStyle(color: Colors.black),
                  hint: Padding(
                    padding: EdgeInsets.only(top: 12, bottom: 10),
                    child: Text(
                      "University",
                      style: TextStyle(color: Colors.black54, fontSize: 15),
                    ),
                  ),
                  searchHint: "Pick a University",
                  onChanged: (value) {
                    setState(() {
                      uniName = value;
                    });
                  },
                  isExpanded: true,
                ),
              ),
            ],
            if (widget.op == 'Edit') ...[
              Padding(
                padding: EdgeInsets.only(top: 10, left: 26),
                child: Text(
                  widget.university,
                  style: TextStyle(color: Colors.black54, fontSize: 17),
                ),
              ),
            ],
            Padding(
              padding: EdgeInsets.only(left: 25, top: 30),
              child: Text(
                'Deadline',
                style: TextStyle(fontSize: 20, color: Colors.black87),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 25, right: 40),
              child: DateTimeField(
                initialValue: widget.deadline ?? null,
                controller: _datetimecontroller,
                decoration: InputDecoration(
                  border: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Color(0xff005fa8), width: 0.0),
                  ),
                ),
                format: DateFormat.yMMMMd(),
                onChanged: (value) {
                  setState(() {
                    _deadline = value;
                  });
                },
                onShowPicker: (context, currentValue) async {
                  final _date = await showDatePicker(
                      context: context,
                      firstDate: DateTime(1900),
                      initialDate: currentValue ?? DateTime.now(),
                      lastDate: DateTime(2150));
                  if (_date != null) {
                    return _date;
                  } else {
                    return currentValue;
                  }
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 25, top: 30),
              child: Text(
                'Notes',
                style: TextStyle(fontSize: 20, color: Colors.black87),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 25, top: 20, right: 35),
              child: TextFormField(
                controller: _notes,
                maxLines: null,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color(0xff005fa8), width: 0.0),
                  ),
                ),
                validator: (value) {
                  return null;
                },
              ),
            )
          ],
        ),
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
  Map app;
  bool saved = true;
  bool saving = false;
  bool savingfailed = false;
  Future applicationNotes;

  @override
  void initState() {
    super.initState();
    app = widget.application;
    _appNotes.text = app['application_notes'] ?? '';
  }

  Future<void> getApplication(int id) async {
    final response = await http.get(
      dom + 'api/student/get-application/$id',
      headers: {HttpHeaders.authorizationHeader: "Token $tok"},
    );
    if (response.statusCode == 200) {
      setState(() {
        app = json.decode(response.body)['application_data'];
      });
    } else {
      throw 'failed';
    }
  }

  Future<void> editAppNotes(String notes) async {
    List essayList = [];
    List transcriptList = [];
    List miscList = [];
    for (int i = 0; i < app['essay_data'].length; i++) {
      essayList.add(app['essay_data'][i]['essay_id']);
    }
    for (int i = 0; i < app['transcript_data'].length; i++) {
      transcriptList.add(app['transcript_data'][i]['transcript_id']);
    }
    for (int i = 0; i < app['misc_doc_data'].length; i++) {
      miscList.add(app['misc_doc_data'][i]['misc_doc_id']);
    }
    setState(() {
      saved = false;
      saving = true;
    });
    final response = await http.put(
      dom + 'api/student/edit-application',
      headers: {
        HttpHeaders.authorizationHeader: "Token $tok",
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode(
        <String, dynamic>{
          'application_id': app['application_id'],
          'university_id': app['university_id'],
          'application_deadline': app["application_deadline"],
          'application_notes': notes,
          'application_status': app['completion_status'],
          'essay_ids': essayList.toString(),
          'transcript_ids': transcriptList.toString(),
          'misc_doc_ids': miscList.toString(),
        },
      ),
    );
    if (response.statusCode == 200) {
      if (json.decode(response.body)['response'] ==
          'Application successfully edited.') {
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

  Future<void> detachDocument(String category, int id) async {
    List essayList = [];
    List transcriptList = [];
    List miscList = [];
    for (int i = 0; i < app['essay_data'].length; i++) {
      if (category == 'essay' && id == app['essay_data'][i]['essay_id']) {
      } else {
        essayList.add(app['essay_data'][i]['essay_id']);
      }
    }
    for (int i = 0; i < app['transcript_data'].length; i++) {
      if (category == 'transcript' &&
          id == app['transcript_data'][i]['transcript_id']) {
      } else {
        transcriptList.add(app['transcript_data'][i]['transcript_id']);
      }
    }
    for (int i = 0; i < app['misc_doc_data'].length; i++) {
      if (category == 'miscdoc' &&
          id == app['misc_doc_data'][i]['misc_doc_id']) {
      } else {
        miscList.add(app['misc_doc_data'][i]['misc_doc_id']);
      }
    }
    setState(() {
      saved = false;
      saving = true;
    });
    final response = await http.put(
      dom + 'api/student/edit-application',
      headers: {
        HttpHeaders.authorizationHeader: "Token $tok",
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode(
        <String, dynamic>{
          'application_id': app['application_id'],
          'university_id': app['university_id'],
          'application_deadline': app["application_deadline"],
          'application_notes': app["application_notes"],
          'application_status': app['completion_status'],
          'essay_ids': essayList.toString(),
          'transcript_ids': transcriptList.toString(),
          'misc_doc_ids': miscList.toString(),
        },
      ),
    );
    if (response.statusCode == 200) {
      if (json.decode(response.body)['response'] ==
          'Application successfully edited.') {
        refresh();
      } else {
        refresh();
        error(context);
      }
    } else {
      refresh();
      error(context);
    }
  }

  _detachDocument(String category, int id) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(0),
          elevation: 20,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          content: Container(
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 18),
                  child: Icon(
                    Icons.delete,
                    size: 40,
                    color: Colors.red.withOpacity(0.9),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Text(
                    'Are you sure you want to detach\nthis document?',
                    style: TextStyle(color: Colors.black, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: Color(0xff005fa8)),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text(
                'Detach',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.pop(context);
                detachDocument(category, id);
              },
            ),
          ],
        );
      },
    );
  }

  void refresh() async {
    setState(() {
      getApplication(widget.application['application_id']);
    });
  }

  Widget buildEssayCard(essay) {
    return Padding(
      padding: EdgeInsets.only(top: 5, left: 15, right: 15, bottom: 8),
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
            trailing: IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _detachDocument('essay', essay['essay_id']);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTranscriptCard(transcript) {
    return Padding(
      padding: EdgeInsets.only(top: 5, left: 15, right: 15, bottom: 8),
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
            dense: true,
            key: Key(transcript['transcript_id'].toString()),
            title: Padding(
              padding: EdgeInsets.only(top: 5),
              child: Text(
                transcript['title'],
                style: TextStyle(color: Colors.black, fontSize: 15),
              ),
            ),
            subtitle: transcript['in_progress']
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
            trailing: IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _detachDocument('transcript', transcript['transcript_id']);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget buildMiscCard(document) {
    return Padding(
      padding: EdgeInsets.only(top: 5, left: 15, right: 15, bottom: 8),
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
                      ? Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Text(
                            'Complete',
                            style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w400),
                          ),
                        )
                      : Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Text(
                            'Pending',
                            style: TextStyle(
                                color: Colors.red, fontWeight: FontWeight.w400),
                          ),
                        ),
                ],
              ),
            ),
            trailing: IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _detachDocument('miscdoc', document['misc_doc_id']);
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> essayCards = [];
    List<Widget> transcriptCards = [];
    List<Widget> miscCards = [];
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
            gradient: isError
                ? LinearGradient(
                    end: Alignment.topRight,
                    begin: Alignment.bottomLeft,
                    colors: [Color(0xff00AEEF), Color(0xff0072BC)])
                : null,
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
        title: Text(
          'Manage Application',
          maxLines: 1,
          style: TextStyle(
              color: Colors.white,
              fontWeight: Platform.isIOS ? FontWeight.w500 : FontWeight.w400),
        ),
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
                initiallyExpanded: essayCards.isNotEmpty,
                title: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Essays'),
                    Padding(
                      padding: EdgeInsets.only(left: 3),
                      child: PopupMenuButton(
                        child: Icon(
                          Icons.add,
                          size: 20,
                          color: Color(0xff005fa8),
                        ),
                        itemBuilder: (BuildContext context) {
                          return {'Create New', 'Attach Existing'}
                              .map((String choice) {
                            return PopupMenuItem<String>(
                              height: 35,
                              value: choice,
                              child: Text(choice,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w400)),
                            );
                          }).toList();
                        },
                        onSelected: (value) async {
                          switch (value) {
                            case 'Create New':
                              break;
                            case 'Attach Existing':
                              break;
                          }
                        },
                      ),
                    )
                  ],
                ),
                children: essayCards.isNotEmpty
                    ? essayCards
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
                initiallyExpanded: transcriptCards.isNotEmpty,
                title: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Transcripts'),
                    Padding(
                      padding: EdgeInsets.only(left: 3),
                      child: PopupMenuButton(
                        child: Icon(
                          Icons.add,
                          size: 20,
                          color: Color(0xff005fa8),
                        ),
                        itemBuilder: (BuildContext context) {
                          return {'Create New', 'Attach Existing'}
                              .map((String choice) {
                            return PopupMenuItem<String>(
                              height: 35,
                              value: choice,
                              child: Text(choice,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w400)),
                            );
                          }).toList();
                        },
                        onSelected: (value) async {
                          switch (value) {
                            case 'Create New':
                              break;
                            case 'Attach Existing':
                              break;
                          }
                        },
                      ),
                    )
                  ],
                ),
                children: transcriptCards.isNotEmpty
                    ? transcriptCards
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
                initiallyExpanded: miscCards.isNotEmpty,
                title: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Misc Documents'),
                    Padding(
                      padding: EdgeInsets.only(left: 3),
                      child: PopupMenuButton(
                        child: Icon(
                          Icons.add,
                          size: 20,
                          color: Color(0xff005fa8),
                        ),
                        itemBuilder: (BuildContext context) {
                          return {'Create New', 'Attach Existing'}
                              .map((String choice) {
                            return PopupMenuItem<String>(
                              height: 35,
                              value: choice,
                              child: Text(choice,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w400)),
                            );
                          }).toList();
                        },
                        onSelected: (value) async {
                          switch (value) {
                            case 'Create New':
                              break;
                            case 'Attach Existing':
                              break;
                          }
                        },
                      ),
                    )
                  ],
                ),
                children: miscCards.isNotEmpty
                    ? miscCards
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
                                    padding:
                                        EdgeInsets.only(right: 17, top: 4.0),
                                    child: SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: SpinKitThreeBounce(
                                            color: Colors.black87, size: 11)),
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
                  Divider(thickness: 0, indent: 25, endIndent: 25),
                  Builder(builder: (context) {
                    return Padding(
                      padding: EdgeInsets.only(
                          top: 5, left: 20, right: 20, bottom: 12),
                      child: TextField(
                        controller: _appNotes,
                        autocorrect: true,
                        maxLines: null,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black87),
                              borderRadius: BorderRadius.circular(10)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          hintText: 'Take note of your tasks for this app...',
                          hintStyle:
                              TextStyle(color: Colors.black54, fontSize: 14),
                        ),
                        onChanged: (value) => editAppNotes(_appNotes.text),
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
