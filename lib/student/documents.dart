import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:path_provider/path_provider.dart';
import 'package:page_transition/page_transition.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:dio/dio.dart' as dio;
import 'package:file_picker/file_picker.dart';
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

  Future<void> deleteDocument(String type, int id) async {
    final response = await http.delete(
      dom + 'api/student/delete-document/$type/$id',
      headers: {HttpHeaders.authorizationHeader: "Token $tok"},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['Response'] == 'Document successfully deleted.') {
        Navigator.pop(context);
        success(
            context, 'Document successfully deleted\nTap + to add a new one');
        refresh();
      } else {
        Navigator.pop(context);
        error(context);
        refresh();
      }
    } else {
      Navigator.pop(context);
      error(context);
      refresh();
    }
  }

  Future<void> uploadTranscript(String op, int id, String title, int grade,
      String spec, File transcript) async {
    var dioRequest = dio.Dio();
    dioRequest.options.headers = {
      HttpHeaders.authorizationHeader: "Token $tok",
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    var formData = dio.FormData.fromMap({
      "user_id": newUser.id,
      "transcript_grade": grade,
      "transcript_title": title,
      "transcript_special_circumstances": spec,
      "transcript_is_flagged": false,
    });
    if (op == 'edit') {
      formData.fields.add(MapEntry('transcript_id', id.toString()));
    }
    var file = await dio.MultipartFile.fromFile(
      transcript.path,
    );
    formData.files.add(MapEntry('transcript', file));
    var response = op == 'create'
        ? await dioRequest.post(
            dom + 'api/student/upload-document/',
            data: formData,
          )
        : await dioRequest.put(
            dom + 'api/student/edit-document',
            data: formData,
          );
    if (response.statusCode == 200) {
      if (op == 'edit' &&
          response.data['Response'] == 'Document successfully edited.') {
        Navigator.pop(context);
        success(context, 'Document successfully edited\nGet working!');
        refresh();
      } else if (op == 'create' &&
          response.data['Response'] == 'Document successfully uploaded.') {
        Navigator.pop(context);
        success(context, 'Document successfully added\nGreat work!');
        refresh();
      } else {
        Navigator.pop(context);
        error(context);
        refresh();
      }
    } else {
      Navigator.pop(context);
      error(context);
      refresh();
    }
  }

  Future<void> addExtracurricular(String op, int id, String title,
      DateTime startDate, DateTime endDate, String desc) async {
    final response = op == 'create'
        ? await http.post(
            dom + 'api/student/upload-document/',
            headers: <String, String>{
              HttpHeaders.authorizationHeader: "Token $tok",
              'Content-Type': 'application/json; charset=UTF-8'
            },
            body: json.encode(
              <String, dynamic>{
                "user_id": newUser.id,
                "ec_title": title,
                "ec_start_date": startDate.toIso8601String().substring(0, 10),
                "ec_end_date": endDate.toIso8601String().substring(0, 10),
                "ec_description": desc == '' ? 'No description' : desc,
                "ec_is_flagged": false
              },
            ),
          )
        : await http.put(
            dom + 'api/student/edit-document',
            headers: <String, String>{
              HttpHeaders.authorizationHeader: "Token $tok",
              'Content-Type': 'application/json; charset=UTF-8'
            },
            body: json.encode(
              <String, dynamic>{
                "user_id": newUser.id,
                "ec_id": id,
                "ec_title": title,
                "ec_start_date": startDate.toIso8601String().substring(0, 10),
                "ec_end_date": endDate.toIso8601String().substring(0, 10),
                "ec_description": desc == '' ? 'No description' : desc,
                "ec_is_flagged": false
              },
            ),
          );
    print(response.body);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (op == 'edit' && data['Response'] == 'Document successfully edited.') {
        Navigator.pop(context);
        success(context, 'Document successfully edited\nGet working!');
        refresh();
      } else if (op == 'create' &&
          data['Response'] == 'Document successfully uploaded.') {
        Navigator.pop(context);
        success(context, 'Document successfully added\nGreat work!');
        refresh();
      } else {
        Navigator.pop(context);
        error(context);
        refresh();
      }
    } else {
      Navigator.pop(context);
      error(context);
    }
  }

  Future<void> uploadMiscDoc(
      String op, int id, String title, String type, File transcript) async {
    var dioRequest = dio.Dio();
    dioRequest.options.headers = {
      HttpHeaders.authorizationHeader: "Token $tok",
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    var formData = dio.FormData.fromMap({
      "user_id": newUser.id,
      "misc_title": title,
      "misc_doc_type": type,
      "misc_is_flagged": false,
    });
    if (op == 'edit') {
      formData.fields.add(MapEntry('misc_id', id.toString()));
    }
    var file = await dio.MultipartFile.fromFile(
      transcript.path,
    );
    formData.files.add(MapEntry('misc_document', file));
    var response = op == 'create'
        ? await dioRequest.post(
            dom + 'api/student/upload-document/',
            data: formData,
          )
        : await dioRequest.put(
            dom + 'api/student/edit-document',
            data: formData,
          );
    if (response.statusCode == 200) {
      if (op == 'edit' &&
          response.data['Response'] == 'Document successfully edited.') {
        Navigator.pop(context);
        success(context, 'Document successfully edited\nGet working!');
        refresh();
      } else if (op == 'create' &&
          response.data['Response'] == 'Document successfully uploaded.') {
        Navigator.pop(context);
        success(context, 'Document successfully added\nGreat work!');
        refresh();
      } else {
        Navigator.pop(context);
        error(context);
        refresh();
      }
    } else {
      Navigator.pop(context);
      error(context);
      refresh();
    }
  }

  Future<File> urlToFile(String fileUrl) async {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    File file = File('$tempPath/' + fileUrl.split('/').last);
    http.Response response = await http.get(fileUrl);
    await file.writeAsBytes(response.bodyBytes);
    return file;
  }

  _deleteDocument(String type, int id) {
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
                    'Are you sure you want to delete\nthis document?',
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
                deleteDocument(type, id);
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
      documents = getDocuments();
    });
  }

  Widget buildTranscriptCard(transcript) {
    return Padding(
      padding: EdgeInsets.only(top: 2, left: 15, right: 15),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
            side: BorderSide(color: Color(0xff005fa8), width: 0.8),
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
            subtitle: Text(
              'Grade ${transcript['grade']}',
              style:
                  TextStyle(color: Colors.black87, fontWeight: FontWeight.w400),
            ),
            trailing: PopupMenuButton(
              child: Icon(
                Icons.more_vert,
                color: Colors.black87,
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
                    File file =
                        await urlToFile(transcript['transcript_file_path']);
                    List data = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TranscriptScreen(
                          op: 'Edit',
                          title: transcript['title'],
                          grade: transcript['grade'],
                          spec: transcript['special_circumstances'],
                          file: file,
                        ),
                      ),
                    );
                    if (data != null) {
                      uploadTranscript('edit', transcript['transcript_id'],
                          data[0], data[1], data[2], data[3]);
                      loading(context);
                    }
                    break;
                  case 'Delete':
                    _deleteDocument('transcript', transcript['transcript_id']);
                    break;
                }
              },
            ),
            onTap: () {
              launch(transcript['transcript_file_path']);
            },
          ),
        ),
      ),
    );
  }

  Widget buildECCard(ec) {
    final key = GlobalKey(debugLabel: ec['ec_id'].toString());
    return Padding(
      padding: EdgeInsets.only(
        top: 2,
        left: 15,
        right: 15,
      ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
            side: BorderSide(color: Color(0xff005fa8), width: 0.8),
            borderRadius: BorderRadius.all(Radius.circular(5))),
        elevation: 2,
        child: Material(
          color: Colors.transparent,
          child: Tooltip(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.all(5),
            key: key,
            message: 'Description: ' +
                (ec['ec_description'] != ''
                    ? ec['ec_description']
                    : 'No description provided'),
            child: ListTile(
              dense: true,
              key: Key(ec['ec_id'].toString()),
              title: Padding(
                padding: EdgeInsets.only(top: 5),
                child: Text(
                  ec['ec_title'],
                  style: TextStyle(color: Colors.black, fontSize: 15),
                ),
              ),
              subtitle: Text(
                '${ec['ec_start_date']} to ${ec['ec_end_date']}',
                style: TextStyle(
                    color: Colors.black87, fontWeight: FontWeight.w400),
              ),
              trailing: PopupMenuButton(
                child: Icon(
                  Icons.more_vert,
                  color: Colors.black87,
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
                      List data = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ECScreen(
                            op: 'Edit',
                            title: ec['ec_title'],
                            startDate: DateTime.parse(ec['ec_start_date']),
                            endDate: DateTime.parse(ec['ec_end_date']),
                            desc: ec['ec_description'],
                          ),
                        ),
                      );
                      if (data != null) {
                        addExtracurricular('edit', ec['ec_id'], data[0],
                            data[1], data[2], data[3]);
                        loading(context);
                      }
                      break;
                    case 'Delete':
                      _deleteDocument('extracurricular', ec['ec_id']);
                      break;
                  }
                },
              ),
              onTap: () {
                final dynamic tooltip = key.currentState;
                tooltip.ensureTooltipVisible();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget buildMiscCard(document) {
    return Padding(
      padding: EdgeInsets.only(top: 2, left: 15, right: 15),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
            side: BorderSide(color: Color(0xff005fa8), width: 0.8),
            borderRadius: BorderRadius.all(Radius.circular(5))),
        elevation: 2,
        child: Material(
          color: Colors.transparent,
          child: ListTile(
            dense: true,
            key: Key(document['misc_doc_id'].toString()),
            title: Padding(
              padding: EdgeInsets.only(top: 5),
              child: Text(
                document['title'],
                style: TextStyle(color: Colors.black, fontSize: 15),
              ),
            ),
            subtitle: Text(
              document['misc_doc_type'],
              style:
                  TextStyle(color: Colors.black87, fontWeight: FontWeight.w400),
            ),
            trailing: PopupMenuButton(
              child: Icon(
                Icons.more_vert,
                color: Colors.black87,
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
                    File file = await urlToFile(document['misc_doc_path']);
                    List data = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MiscDocsScreen(
                          op: 'Edit',
                          title: document['title'],
                          type: document['misc_doc_type'],
                          file: file,
                        ),
                      ),
                    );
                    if (data != null) {
                      uploadMiscDoc('edit', document['misc_doc_id'], data[0],
                          data[1], data[2]);
                      loading(context);
                    }
                    break;
                  case 'Delete':
                    _deleteDocument('miscellaneous', document['misc_doc_id']);
                    break;
                }
              },
            ),
            onTap: () {
              launch(document['misc_doc_path']);
            },
          ),
        ),
      ),
    );
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
              padding: EdgeInsets.only(left: 12, top: 10, bottom: 5, right: 12),
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
                  Spacer(),
                  Padding(
                    padding: EdgeInsets.only(left: 2, top: 2),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        child: Icon(
                          Icons.add,
                          color: Color(0xff005fa8),
                        ),
                        onTap: () async {
                          List data = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TranscriptScreen(
                                op: 'Create',
                              ),
                            ),
                          );
                          if (data != null) {
                            uploadTranscript('create', null, data[0], data[1],
                                data[2], data[3]);
                            loading(context);
                          }
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
          ];
          extraCurricularData = [
            Padding(
              padding: EdgeInsets.only(left: 12, top: 10, bottom: 5, right: 12),
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
                  Spacer(),
                  Padding(
                    padding: EdgeInsets.only(left: 2, top: 2),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        child: Icon(
                          Icons.add,
                          color: Color(0xff005fa8),
                        ),
                        onTap: () async {
                          List data = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ECScreen(
                                op: 'Create',
                              ),
                            ),
                          );
                          if (data != null) {
                            addExtracurricular('create', null, data[0], data[1],
                                data[2], data[3]);
                            loading(context);
                          }
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
          ];
          miscDocsData = [
            Padding(
              padding: EdgeInsets.only(left: 12, top: 10, bottom: 5, right: 12),
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
                  Spacer(),
                  Padding(
                    padding: EdgeInsets.only(left: 2, top: 2),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        child: Icon(
                          Icons.add,
                          color: Color(0xff005fa8),
                        ),
                        onTap: () async {
                          List data = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MiscDocsScreen(
                                op: 'Create',
                              ),
                            ),
                          );
                          if (data != null) {
                            uploadMiscDoc(
                                'create', null, data[0], data[1], data[2]);
                            loading(context);
                          }
                        },
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
                  buildTranscriptCard(
                    snapshot.data['transcript_data'][i],
                  ),
                );
              }
            } else {
              transcriptData.add(
                Padding(
                  padding: EdgeInsets.only(top: 15, bottom: 15),
                  child: Text(
                    'No transcripts uploaded yet.',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              );
            }
            if (snapshot.data['extracurricular_data'].length != 0) {
              for (int i = 0;
                  i < snapshot.data['extracurricular_data'].length;
                  i++) {
                extraCurricularData.add(
                  buildECCard(
                    snapshot.data['extracurricular_data'][i],
                  ),
                );
              }
            } else {
              extraCurricularData.add(
                Padding(
                  padding: EdgeInsets.only(top: 15, bottom: 15),
                  child: Text(
                    'No extracurriculars added yet.',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              );
            }
            if (snapshot.data['misc_docs_data'].length != 0) {
              for (int i = 0; i < snapshot.data['misc_docs_data'].length; i++) {
                miscDocsData.add(
                  buildMiscCard(
                    snapshot.data['misc_docs_data'][i],
                  ),
                );
              }
            } else {
              miscDocsData.add(
                Padding(
                  padding: EdgeInsets.only(top: 15, bottom: 15),
                  child: Text(
                    'No miscellaneous documents uploaded yet.',
                    style: TextStyle(color: Colors.black54),
                  ),
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
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Column(
                        children: transcriptData,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    elevation: 4,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Column(
                        children: extraCurricularData,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    elevation: 4,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Column(
                        children: miscDocsData,
                      ),
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

class TranscriptScreen extends StatefulWidget {
  final String title;
  final int grade;
  final String spec;
  final File file;
  final String op;
  TranscriptScreen(
      {@required this.op, this.title, this.grade, this.spec, this.file});
  @override
  _TranscriptScreenState createState() => _TranscriptScreenState();
}

class _TranscriptScreenState extends State<TranscriptScreen> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _title = TextEditingController();
  TextEditingController _grade = TextEditingController();
  TextEditingController _spec = TextEditingController();
  File transcript;

  @override
  void initState() {
    super.initState();
    _title.text = widget.title ?? '';
    _grade.text = widget.op == 'Edit' ? widget.grade.toString() : '';
    _spec.text = widget.spec ?? '';
    transcript = widget.file;
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
              widget.op == 'Create' ? 'ADD' : 'SAVE',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
            onPressed: () {
              if (_title.text != null &&
                  _grade != null &&
                  _spec != null &&
                  transcript != null) {
                final data = [
                  _title.text,
                  int.parse(_grade.text),
                  _spec.text,
                  transcript
                ];
                Navigator.pop(context, data);
              }
            },
          )
        ],
        title: Text(
          widget.op == 'Create' ? 'Add Transcript' : 'Edit Transcript',
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
              padding: EdgeInsets.only(left: 25, top: 35),
              child: Text(
                'Title',
                style: TextStyle(fontSize: 20, color: Colors.black87),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 25, right: 45),
              child: TextFormField(
                controller: _title,
                validator: (value) {
                  return null;
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 25, top: 30),
              child: Text(
                'Grade',
                style: TextStyle(fontSize: 20, color: Colors.black87),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 26, right: 45),
              child: TextFormField(
                controller: _grade,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (int.parse(value) < 5 || int.parse(value) > 12) {
                    return 'Enter a value between 5 and 12';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 25, top: 30),
              child: Text(
                'Transcript',
                style: TextStyle(fontSize: 20, color: Colors.black87),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 25, right: 25, top: 10),
              child: Row(
                children: <Widget>[
                  RaisedButton(
                    elevation: 2,
                    color: Colors.grey[50],
                    textColor: Color(0xff005fa8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5))),
                    child: Text('Choose File'),
                    onPressed: () async {
                      File file = await FilePicker.getFile(
                        type: FileType.any,
                      );
                      if (file != null) {
                        setState(() {
                          transcript = file;
                        });
                      }
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                        transcript?.path?.split('/')?.last ?? 'No file chosen'),
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 25, top: 30),
              child: Text(
                'Special Circumstances',
                style: TextStyle(fontSize: 20, color: Colors.black87),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 26, right: 45, top: 20),
              child: Theme(
                data: ThemeData(primaryColor: Color(0xff005fa8)),
                child: TextFormField(
                  cursorColor: Color(0xff005fa8),
                  controller: _spec,
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
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ECScreen extends StatefulWidget {
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final String desc;
  final String op;
  ECScreen(
      {@required this.op, this.title, this.startDate, this.endDate, this.desc});
  @override
  _ECScreenState createState() => _ECScreenState();
}

class _ECScreenState extends State<ECScreen> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _title = TextEditingController();
  TextEditingController _desc = TextEditingController();
  TextEditingController _startDateController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();

  DateTime _startDate;
  DateTime _endDate;

  @override
  void initState() {
    super.initState();
    _title.text = widget.title ?? '';
    _desc.text = widget.desc ?? '';
    if (widget.startDate != null) {
      _startDate = widget.startDate;
      _startDateController.text = DateFormat.yMMMMd().format(widget.startDate);
    }
    if (widget.endDate != null) {
      _endDate = widget.endDate;
      _endDateController.text = DateFormat.yMMMMd().format(widget.endDate);
    }
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
              widget.op == 'Create' ? 'ADD' : 'SAVE',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
            onPressed: () {
              if (_title.text != null &&
                  _desc != null &&
                  _startDate != null &&
                  _endDate != null) {
                final data = [_title.text, _startDate, _endDate, _desc.text];
                Navigator.pop(context, data);
              }
            },
          )
        ],
        title: Text(
          widget.op == 'Create'
              ? 'Add Extracurricular'
              : 'Edit Extracurricular',
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
              padding: EdgeInsets.only(left: 25, top: 35),
              child: Text(
                'Title',
                style: TextStyle(fontSize: 20, color: Colors.black87),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 25, right: 45),
              child: TextFormField(
                cursorColor: Color(0xff005fa8),
                controller: _title,
                validator: (value) {
                  return null;
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 25, top: 30),
              child: Text(
                'Start Date',
                style: TextStyle(fontSize: 20, color: Colors.black87),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 25, right: 45),
              child: Theme(
                data: ThemeData(primaryColor: Color(0xff005fa8)),
                child: DateTimeField(
                  cursorColor: Color(0xff005fa8),
                  initialValue: widget.startDate ?? null,
                  controller: _startDateController,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xff005fa8), width: 0.0),
                    ),
                  ),
                  format: DateFormat.yMMMMd(),
                  onChanged: (value) {
                    setState(() {
                      _startDate = value;
                    });
                  },
                  onShowPicker: (context, currentValue) async {
                    final _date = await showDatePicker(
                        context: context,
                        firstDate: DateTime(1900),
                        initialDate:
                            currentValue ?? widget.startDate ?? DateTime.now(),
                        lastDate: DateTime(2150));
                    if (_date != null) {
                      return _date;
                    } else {
                      return currentValue;
                    }
                  },
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 25, top: 30),
              child: Text(
                'End Date',
                style: TextStyle(fontSize: 20, color: Colors.black87),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 25, right: 45),
              child: Theme(
                data: ThemeData(primaryColor: Color(0xff005fa8)),
                child: DateTimeField(
                  cursorColor: Color(0xff005fa8),
                  initialValue: widget.endDate ?? null,
                  controller: _endDateController,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xff005fa8), width: 0.0),
                    ),
                  ),
                  format: DateFormat.yMMMMd(),
                  onChanged: (value) {
                    setState(() {
                      _endDate = value;
                    });
                  },
                  onShowPicker: (context, currentValue) async {
                    final _date = await showDatePicker(
                        context: context,
                        firstDate: DateTime(1900),
                        initialDate:
                            currentValue ?? widget.endDate ?? DateTime.now(),
                        lastDate: DateTime(2150));
                    if (_date != null) {
                      return _date;
                    } else {
                      return currentValue;
                    }
                  },
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 25, top: 30),
              child: Text(
                'Description',
                style: TextStyle(fontSize: 20, color: Colors.black87),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 25, right: 45, top: 15),
              child: Theme(
                data: ThemeData(primaryColor: Color(0xff005fa8)),
                child: TextFormField(
                  cursorColor: Color(0xff005fa8),
                  controller: _desc,
                  maxLines: null,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 0.0),
                    ),
                  ),
                  validator: (value) {
                    return null;
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class MiscDocsScreen extends StatefulWidget {
  final String title;
  final String type;
  final File file;
  final String op;
  MiscDocsScreen({@required this.op, this.title, this.type, this.file});

  @override
  _MiscDocsScreenState createState() => _MiscDocsScreenState();
}

class _MiscDocsScreenState extends State<MiscDocsScreen> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _title = TextEditingController();
  String _type;
  File transcript;

  @override
  void initState() {
    super.initState();
    _title.text = widget.title ?? '';
    transcript = widget.file;
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
              widget.op == 'Create' ? 'ADD' : 'SAVE',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
            onPressed: () {
              if (_title.text != null && _type != null && transcript != null) {
                final data = [_title.text, _type, transcript];
                Navigator.pop(context, data);
              }
            },
          )
        ],
        title: Text(
          widget.op == 'Create' ? 'Add Document' : 'Edit Document',
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
              padding: EdgeInsets.only(left: 25, top: 35),
              child: Text(
                'Title',
                style: TextStyle(fontSize: 20, color: Colors.black87),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 25, right: 45),
              child: Theme(
                data: ThemeData(primaryColor: Color(0xff005fa8)),
                child: TextFormField(
                  cursorColor: Color(0xff005fa8),
                  controller: _title,
                  validator: (value) {
                    return null;
                  },
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 25, top: 30),
              child: Text(
                'Type',
                style: TextStyle(fontSize: 20, color: Colors.black87),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 26, right: 45),
              child: DropdownButtonFormField(
                hint: Text(
                  "Type of document",
                  style: TextStyle(color: Colors.black54, fontSize: 16),
                ),
                itemHeight: kMinInteractiveDimension,
                items: [
                  DropdownMenuItem(
                      child: Text(
                        'Letter of Recommendation',
                        style: TextStyle(fontSize: 16),
                      ),
                      value: 'Letter of Recommendation'),
                  DropdownMenuItem(
                      child: Text(
                        'Certificate of Achievement',
                        style: TextStyle(fontSize: 16),
                      ),
                      value: 'Certificate of Achievement'),
                  DropdownMenuItem(
                      child: Text(
                        'Financial Document',
                        style: TextStyle(fontSize: 16),
                      ),
                      value: 'Financial Document'),
                  DropdownMenuItem(
                      child: Text(
                        'Other',
                        style: TextStyle(fontSize: 16),
                      ),
                      value: 'Other'),
                ],
                value: _type,
                validator: (value) => value == null
                    ? 'Do tell us what type of document this is'
                    : null,
                isExpanded: true,
                onChanged: (value) {
                  setState(() {
                    _type = value;
                    print(_type);
                  });
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 25, top: 30),
              child: Text(
                'Document',
                style: TextStyle(fontSize: 20, color: Colors.black87),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 25, right: 25, top: 10),
              child: Row(
                children: <Widget>[
                  RaisedButton(
                    elevation: 2,
                    color: Colors.grey[50],
                    textColor: Color(0xff005fa8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5))),
                    child: Text('Choose File'),
                    onPressed: () async {
                      File file = await FilePicker.getFile(
                        type: FileType.any,
                      );
                      if (file != null) {
                        setState(() {
                          transcript = file;
                        });
                      }
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                        transcript?.path?.split('/')?.last ?? 'No file chosen'),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
