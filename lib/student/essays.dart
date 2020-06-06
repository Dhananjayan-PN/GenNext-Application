import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:http/http.dart' as http;
import 'package:quill_delta/quill_delta.dart';
import 'dart:math';
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

  Widget buildEssayCard(essay) {
    return Padding(
      padding: EdgeInsets.only(top: 5, left: 10, right: 10),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        elevation: 10,
        child: Material(
          color: Colors.transparent,
          child: ListTile(
            key: Key(essay['essay_id'].toString()),
            title: Text(
              essay['essay_title'],
              style: TextStyle(color: Colors.black),
            ),
            subtitle: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Text(
                    essay['university'].toString(),
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
                /*Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Row(
                    children: <Widget>[
                      Text(
                        'University: ',
                      ),
                      Text(
                        essay['university'].toString(),
                        style: TextStyle(color: Colors.black54),
                      )
                    ],
                  ),
                ),*/
              ],
            ),
            trailing: Wrap(
              children: <Widget>[
                InkWell(
                  child: Transform.rotate(
                      angle: 3.14159, child: Icon(Icons.keyboard_backspace)),
                  onTap: () {},
                )
              ],
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
                              : snapshot.data[index]['essay_prompt']
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
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}

class EssayEditor extends StatefulWidget {
  @override
  _EssayEditorState createState() => _EssayEditorState();
}

class _EssayEditorState extends State<EssayEditor> {
  ZefyrController _controller;
  FocusNode _focusNode;
  Future<NotusDocument> loadDocument;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    loadDocument = _loadDocument();
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

  Future<NotusDocument> _loadDocument() async {
    final Delta delta = Delta()..insert("Essay editor\n");
    return NotusDocument.fromDelta(delta);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: NavDrawer(
          name: newUser.firstname + ' ' + newUser.lastname,
          email: newUser.email),
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
        title: Text(
          'Essay Editor',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xff00AEEF), Color(0xff0072BC)]),
      ),
      body: FutureBuilder(
        future: loadDocument,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _controller = ZefyrController(snapshot.data);
            return ZefyrScaffold(
              child: ZefyrEditor(
                padding: EdgeInsets.all(16),
                controller: _controller,
                focusNode: _focusNode,
              ),
            );
          }
          return CircularProgressIndicator();
        },
      ),
    );
  }
}
