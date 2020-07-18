import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:quill_delta/quill_delta.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:zefyr/zefyr.dart';
import 'home.dart';

class EssaysScreen extends StatefulWidget {
  @override
  _EssaysScreenState createState() => _EssaysScreenState();
}

class _EssaysScreenState extends State<EssaysScreen> {
  @override
  void initState() {
    super.initState();
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
            child: CounselorHomeScreen(user: newUser)));
    return true;
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: NavDrawer(
          name: newUser.firstname + ' ' + newUser.lastname,
          email: newUser.email),
      appBar: CustomAppBar('Essays'),
      body: Center(
        child: FlatButton(
          color: Colors.blue,
          child: Text('Essays'),
          onPressed: () {
            Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.fade,
                child: EssayEditor(),
              ),
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
      appBar: AppBar(
        backgroundColor: Color(0xff005fa8),
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
