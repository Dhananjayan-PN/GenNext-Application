import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:http/http.dart' as http;
import '../shimmer_skeleton.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'home.dart';

class DocumentsScreen extends StatefulWidget {
  @override
  _DocumentsScreenState createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  List<Widget> transcriptData;
  List<Widget> extraCurricularData;
  List<Widget> miscDocsData;
  Future documents;

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
    documents = getDocuments();
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

  Future<void> getDocuments() async {
    final response = await http.get(
      dom + 'api/student/get-my-documents',
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
      appBar: CustomAppBar('My Documents'),
      drawer: NavDrawer(
          name: newUser.firstname + ' ' + newUser.lastname,
          email: newUser.email),
      body: FutureBuilder(
        future: documents.timeout(Duration(seconds: 10)),
        builder: (context, snapshot) {
          transcriptData = [
            Padding(
              padding: EdgeInsets.only(left: 12, top: 8, bottom: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Transcripts',
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: 21,
                        fontWeight: FontWeight.w300),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 2, top: 2),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        child: Icon(
                          Icons.add,
                          color: Colors.blue[700],
                        ),
                        onTap: () {},
                      ),
                    ),
                  )
                ],
              ),
            ),
          ];
          extraCurricularData = [
            Padding(
              padding: EdgeInsets.only(left: 12, top: 8, bottom: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Extracurriculars',
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: 21,
                        fontWeight: FontWeight.w300),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 2, top: 2),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        child: Icon(
                          Icons.add,
                          color: Colors.blue[700],
                        ),
                        onTap: () {},
                      ),
                    ),
                  )
                ],
              ),
            ),
          ];
          miscDocsData = [
            Padding(
              padding: EdgeInsets.only(left: 12, top: 8, bottom: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Miscellaneous Documents',
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: 21,
                        fontWeight: FontWeight.w300),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 2, top: 2),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        child: Icon(
                          Icons.add,
                          color: Colors.blue[700],
                        ),
                        onTap: () {},
                      ),
                    ),
                  )
                ],
              ),
            ),
          ];
          if (snapshot.hasError) {
            return Center(
              child: Text('Error'),
            );
          }
          if (snapshot.hasData) {
            if (snapshot.data['transcript_data'].length != 0) {
              for (int i = 0;
                  i < snapshot.data['transcript_data'].length;
                  i++) {
                transcriptData.add(
                  Text(
                    snapshot.data['transcript_data'][i]['transcript_id'],
                  ),
                );
              }
            } else {
              transcriptData.add(
                Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  child: Text('No transcripts uploaded yet.'),
                ),
              );
            }
            if (snapshot.data['extracurricular_data'].length != 0) {
              for (int i = 0;
                  i < snapshot.data['extracurricular_data'].length;
                  i++) {
                extraCurricularData.add(
                  Text(
                    snapshot.data['extracurricular_data'][i]
                        ['extracurricular_id'],
                  ),
                );
              }
            } else {
              extraCurricularData.add(
                Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  child: Text('No extracurriculars added yet.'),
                ),
              );
            }
            if (snapshot.data['misc_docs_data'].length != 0) {
              for (int i = 0; i < snapshot.data['misc_docs_data'].length; i++) {
                miscDocsData.add(
                  Text(
                    snapshot.data['misc_docs_data'][i]['misc_doc_id'],
                  ),
                );
              }
            } else {
              miscDocsData.add(
                Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  child: Text('No miscellaneous documents uploaded yet.'),
                ),
              );
            }
            return ListView(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 10, right: 10, top: 20),
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    elevation: 4,
                    child: Column(
                      children: transcriptData,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    elevation: 4,
                    child: Column(
                      children: extraCurricularData,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    elevation: 4,
                    child: Column(
                      children: miscDocsData,
                    ),
                  ),
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
