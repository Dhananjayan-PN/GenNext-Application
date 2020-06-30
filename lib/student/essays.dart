import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:expand_widget/expand_widget.dart';
import 'package:http/http.dart' as http;
import '../shimmer_skeleton.dart';
import 'package:quill_delta/quill_delta.dart';
import 'package:quill_zefyr_bijection/quill_zefyr_bijection.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:zefyr/zefyr.dart';
import 'home.dart';

class EssaysScreen extends StatefulWidget {
  @override
  _EssaysScreenState createState() => _EssaysScreenState();
}

class _EssaysScreenState extends State<EssaysScreen> {
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  TextEditingController controller = TextEditingController();
  String filter;
  Future essayList;

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
    controller.addListener(() {
      setState(() {
        filter = controller.text.toLowerCase();
      });
    });
    essayList = getEssays();
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

  void refresh() {
    setState(() {
      essayList = getEssays();
    });
  }

  Future<void> getEssays() async {
    final response = await http.get(
      dom + 'api/student/get-my-essays',
      headers: {HttpHeaders.authorizationHeader: "Token $tok"},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body)['essay_data'];
    } else {
      throw 'failed';
    }
  }

  Future<void> editEssay() async {}

  Future<void> deleteEssay() async {}

  Future<void> editEssaydetail() async {}

  _editEssay() {}

  _deleteEssay() {}

  _editEssayDetails() {}

  Widget buildEssayCard(essay) {
    return Padding(
      padding: EdgeInsets.only(top: 5, left: 10, right: 10),
      child: Card(
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
                    child: Text(
                      essay['essay_title'],
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    ),
                  ),
                  Spacer(),
                  Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: InkWell(
                      child: Icon(
                        Icons.create,
                        color: Colors.black.withOpacity(0.75),
                      ),
                      onTap: () {
                        String studentString = essay['student_essay_content'] ==
                                ''
                            ? '[{\"attributes\":{\"align\":\"justify\"},\"insert\":\"\\n\"},{\"insert\":\"\\n\"}]'
                            : essay['student_essay_content'];
                        String counselorString = essay[
                                    'counselor_essay_content'] ==
                                ''
                            ? '[{\"attributes\":{\"align\":\"justify\"},\"insert\":\"\\n\"},{\"insert\":\"\\n\"}]'
                            : essay['counselor_essay_content'];
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.rightToLeft,
                            child: EssayEditor(
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
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10, top: 5),
                    child: PopupMenuButton(
                      child: Icon(Icons.more_vert),
                      itemBuilder: (BuildContext context) {
                        return {'Edit Details', 'Delete'}.map((String choice) {
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
                      onSelected: (value) {
                        switch (value) {
                          case 'Edit Details':
                            break;
                          case 'Delete':
                            break;
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            subtitle: Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  essay['essay_approval_status'] == 'Y'
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
                                  color: Colors.orange,
                                  fontWeight: FontWeight.w400),
                            )
                          : Text(
                              'Pending',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w400),
                            ),
                  if (essay['universities'].length != 0) ...[
                    Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: Stack(
                        textDirection: TextDirection.ltr,
                        overflow: Overflow.visible,
                        children: <Widget>[
                          essay['universities'].length == 1
                              ? Positioned(
                                  left: 20,
                                  child: InkWell(
                                    child: CircleAvatar(
                                      radius: 17.8,
                                      backgroundColor: Colors.blue,
                                      child: CircleAvatar(
                                        backgroundImage: CachedNetworkImageProvider(
                                            'https://upload.wikimedia.org/wikipedia/en/thumb/4/4f/University_of_Massachusetts_Amherst_seal.svg/1200px-University_of_Massachusetts_Amherst_seal.svg.png'),
                                        backgroundColor: Colors.blue[400],
                                        radius: 17,
                                      ),
                                    ),
                                    onTap: () {
                                      print('lmao');
                                    },
                                  ),
                                )
                              : Container(),
                          InkWell(
                            child: CircleAvatar(
                              radius: 17.8,
                              backgroundColor: Colors.blue,
                              child: CircleAvatar(
                                backgroundImage: CachedNetworkImageProvider(
                                    'https://bloximages.chicago2.vip.townnews.com/madison.com/content/tncms/assets/v3/editorial/6/7a/67a00837-e31a-5fca-b89f-98985000d03e/5978bc84a81af.image.jpg'),
                                backgroundColor: Colors.blue[400],
                                radius: 17,
                              ),
                            ),
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: NavDrawer(
          name: newUser.firstname + ' ' + newUser.lastname,
          email: newUser.email),
      appBar: CustomAppBar('Essays'),
      body: RefreshIndicator(
        key: refreshKey,
        onRefresh: () {
          refresh();
          return essayList;
        },
        child: FutureBuilder(
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
                              "Looks like you haven't added\nany essays yet",
                              style: TextStyle(color: Colors.black54),
                              textAlign: TextAlign.center,
                            )),
                        Padding(
                          padding: EdgeInsets.only(top: 3),
                          child: Text(
                              "Click the '+' to add one and get writing!",
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
                      padding: EdgeInsets.only(
                          top: 5, left: 18, right: 30, bottom: 20),
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
                              controller: controller,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, index) {
                          return filter == null || filter == ""
                              ? buildEssayCard(snapshot.data[index])
                              : snapshot.data[index]['essay_title']
                                      .toLowerCase()
                                      .contains(filter)
                                  ? buildEssayCard(snapshot.data[index])
                                  : snapshot.data[index]['university']
                                          .toLowerCase()
                                          .contains(filter)
                                      ? buildEssayCard(snapshot.data[index])
                                      : Container();
                        },
                      ),
                    ),
                  ],
                );
              }
            }
            return Padding(
              padding: EdgeInsets.only(top: 70),
              child: CardListSkeleton(
                isBottomLinesActive: false,
                length: 10,
              ),
            );
          },
        ),
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

  bool myInterceptor(bool stopDefaultButtonEvent) {
    print("BACK BUTTON!");
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
          appBar: GradientAppBar(
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  'SAVE',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w500),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
            title: Text(
              essayTitle,
              maxLines: 1,
              style: TextStyle(color: Colors.white, fontSize: 17),
            ),
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xff00AEEF), Color(0xff0072BC)]),
            bottom: TabBar(
              tabs: [
                Tab(
                    child: Padding(
                  padding: EdgeInsets.only(left: 3.0),
                  child: Text('My Version'),
                )),
                Tab(
                    child: Padding(
                  padding: EdgeInsets.only(left: 3.0),
                  child: Text('Counselor Version'),
                )),
              ],
            ),
          ),
          body: TabBarView(
            children: <Widget>[
              ZefyrScaffold(
                child: Column(
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
                    Expanded(
                      child: ZefyrEditor(
                        padding: EdgeInsets.only(
                            left: 16, right: 16, top: 0, bottom: 10),
                        controller: _controller1,
                        focusNode: _focusNode1,
                      ),
                    ),
                  ],
                ),
              ),
              ZefyrScaffold(
                child: Column(
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
                    Expanded(
                      child: ZefyrEditor(
                        mode: ZefyrMode(
                            canEdit: false, canFormat: false, canSelect: true),
                        padding: EdgeInsets.only(
                            left: 16, right: 16, top: 0, bottom: 10),
                        controller: _controller2,
                        focusNode: _focusNode2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}
