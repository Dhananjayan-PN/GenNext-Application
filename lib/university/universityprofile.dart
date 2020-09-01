import 'package:http/http.dart' as http;
import 'package:dio/dio.dart' as dio;
import 'package:intl/intl.dart';
import '../imports.dart';
import 'home.dart';

class UniProfileScreen extends StatefulWidget {
  @override
  _UniProfileScreenState createState() => _UniProfileScreenState();
}

class _UniProfileScreenState extends State<UniProfileScreen> {
  GlobalKey<ScaffoldState> _scafKey = GlobalKey<ScaffoldState>();
  Future uniData;
  List<Widget> standOutFactors;
  List<Widget> appChips;
  List<Widget> deadlines;
  List<Widget> topMajors;
  List<Widget> testingReqs;
  List<Widget> documentChips;
  String educationString = '';
  bool descShowFull = false;
  bool isStarred;
  bool inList;

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
    uniData = getUniversity();
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    return true;
  }

  Future<void> getUniversity() async {
    String tok = await getToken();
    final response = await http.get(
      dom + 'api/university/profile',
      headers: {HttpHeaders.authorizationHeader: "Token $tok"},
    );
    if (response.statusCode == 200) {
      final result = await http.get(
        dom + 'api/university/get-documents',
        headers: {HttpHeaders.authorizationHeader: "Token $tok"},
      );
      if (result.statusCode == 200) {
        Map uniData = json.decode(response.body)['university_data'];
        uniData['document_data'] = json.decode(result.body)['document_data'];
        return uniData;
      } else {
        throw 'failed';
      }
    } else {
      throw 'failed';
    }
  }

  Future<void> editImage(Map profile, File image) async {
    String tok = await getToken();
    var dioRequest = dio.Dio();
    dioRequest.options.headers = {
      HttpHeaders.authorizationHeader: "Token $tok",
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    var formData = dio.FormData.fromMap({
      'university_id': profile['university_id'],
    });
    var file = await dio.MultipartFile.fromFile(
      image.path,
    );
    formData.files.add(MapEntry('university_image', file));
    var response = await dioRequest.put(
      dom + 'api/university/edit-profile',
      data: formData,
    );
    if (response.statusCode == 200) {
      if (response.data['Response'] == 'University successfully edited.') {
        Navigator.pop(context);
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

  Future<void> editLogo(Map profile, File image) async {
    String tok = await getToken();
    var dioRequest = dio.Dio();
    dioRequest.options.headers = {
      HttpHeaders.authorizationHeader: "Token $tok",
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    var formData = dio.FormData.fromMap({
      'university_id': profile['university_id'],
    });
    var file = await dio.MultipartFile.fromFile(
      image.path,
    );
    formData.files.add(MapEntry('university_logo', file));
    var response = await dioRequest.put(
      dom + 'api/university/edit-profile',
      data: formData,
    );
    if (response.statusCode == 200) {
      if (response.data['Response'] == 'University successfully edited.') {
        Navigator.pop(context);
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

  Future<void> editDetails(Map profile, List details) async {
    String tok = await getToken();
    String newFactors = '[';
    String newDegrees = '[';
    for (int i = 0; i < details[5].length; i++) {
      if (i == 0) {
        newFactors += r'"' + details[5][0] + r'"';
      } else {
        newFactors += ", " + r'"' + details[5][i] + r'"';
      }
    }
    for (int i = 0; i < details[3].length; i++) {
      if (i == 0) {
        newDegrees += r'"' + details[3][0] + r'"';
      } else {
        newDegrees += ", " + r'"' + details[3][i] + r'"';
      }
    }
    print(newFactors);
    final response = await http
        .put(
          dom + 'api/university/edit-profile',
          headers: {
            HttpHeaders.authorizationHeader: "Token $tok",
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(
            <String, dynamic>{
              'university_id': profile['university_id'],
              'degree_levels':
                  newDegrees + ']' == '[]' ? null : newDegrees + ']',
              'university_stand_out_factors':
                  newFactors + ']' == '[]' ? null : newFactors + ']',
              'acceptance_rate': details[0],
              'university_ranking': details[1],
              'university_research_or_not': details[2],
              'website': details[4]
            },
          ),
        )
        .timeout(Duration(seconds: 10));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['Response'] == 'University successfully edited.') {
        Navigator.pop(context);
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

  Future<void> editAbout(Map profile, String newAbout) async {
    String tok = await getToken();
    final response = await http
        .put(
          dom + 'api/university/edit-profile',
          headers: {
            HttpHeaders.authorizationHeader: "Token $tok",
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(
            <String, dynamic>{
              'university_id': profile['university_id'],
              'university_description': newAbout,
            },
          ),
        )
        .timeout(Duration(seconds: 10));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['Response'] == 'University successfully edited.') {
        Navigator.pop(context);
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

  Future<void> editTopMajors(Map profile, List newTopMajors) async {
    String tok = await getToken();
    String newMajorString = '[';
    for (int i = 0; i < newTopMajors.length; i++) {
      if (i == 0) {
        newMajorString += r'"' + newTopMajors[0] + r'"';
      } else {
        newMajorString += ", " + r'"' + newTopMajors[i] + r'"';
      }
    }
    final response = await http
        .put(
          dom + 'api/university/edit-profile',
          headers: {
            HttpHeaders.authorizationHeader: "Token $tok",
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(
            <String, dynamic>{
              'university_id': profile['university_id'],
              'top_majors':
                  newMajorString + ']' == '[]' ? null : newMajorString + ']',
            },
          ),
        )
        .timeout(Duration(seconds: 10));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['Response'] == 'University successfully edited.') {
        Navigator.pop(context);
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

  Future<void> editCost(Map profile, List<int> costs) async {
    String tok = await getToken();
    final response = await http
        .put(
          dom + 'api/university/edit-profile',
          headers: {
            HttpHeaders.authorizationHeader: "Token $tok",
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(
            <String, dynamic>{
              'university_id': profile['university_id'],
              'cost_of_attendance': '${costs[0]}:${costs[1]}:${costs[2]}',
            },
          ),
        )
        .timeout(Duration(seconds: 10));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['Response'] == 'University successfully edited.') {
        Navigator.pop(context);
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

  Future<void> editTesting(Map profile, List newTesting) async {
    String tok = await getToken();
    String newTestingString = '[';
    for (int i = 0; i < newTesting.length; i++) {
      if (i == 0) {
        newTestingString += r'"' + newTesting[0] + r'"';
      } else {
        newTestingString += ", " + r'"' + newTesting[i] + r'"';
      }
    }
    final response = await http
        .put(
          dom + 'api/university/edit-profile',
          headers: {
            HttpHeaders.authorizationHeader: "Token $tok",
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(
            <String, dynamic>{
              'university_id': profile['university_id'],
              'testing_requirements': newTestingString + ']' == '[]'
                  ? null
                  : newTestingString + ']',
            },
          ),
        )
        .timeout(Duration(seconds: 10));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['Response'] == 'University successfully edited.') {
        Navigator.pop(context);
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

  Future<void> editApplication(Map profile, int fee, bool commonApp,
      bool coalition, Map applicationTypes) async {
    String tok = await getToken();
    String appTypesString = '[';
    for (int i = 0; i < applicationTypes.length; i++) {
      if (i == 0) {
        String mapString = '{"' +
            applicationTypes.keys.elementAt(0).toString() +
            r'"' +
            ': ' +
            r'"' +
            applicationTypes[applicationTypes.keys.elementAt(0).toString()] +
            r'"}';
        appTypesString += mapString;
      } else {
        String mapString = ', {"' +
            applicationTypes.keys.elementAt(i).toString() +
            r'"' +
            ': ' +
            r'"' +
            applicationTypes[applicationTypes.keys.elementAt(i).toString()] +
            r'"}';
        appTypesString += mapString;
      }
    }
    final response = await http
        .put(
          dom + 'api/university/edit-profile',
          headers: {
            HttpHeaders.authorizationHeader: "Token $tok",
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(
            <String, dynamic>{
              'university_id': profile['university_id'],
              'application_fee': fee,
              'common_app_accepted_status': commonApp,
              'coalition_app_accepted_status': coalition,
              'application_types': appTypesString + ']'
            },
          ),
        )
        .timeout(Duration(seconds: 10));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['Response'] == 'University successfully edited.') {
        Navigator.pop(context);
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

  Future<void> addDocument(Map profile, String title, File document) async {
    try {
      String tok = await getToken();
      var dioRequest = dio.Dio();
      dioRequest.options.headers = {
        HttpHeaders.authorizationHeader: "Token $tok",
        'Content-Type': 'application/x-www-form-urlencoded',
      };
      var formData = dio.FormData.fromMap({
        'university_id': profile['university_id'],
        'title': title,
      });
      var file = await dio.MultipartFile.fromFile(
        document.path,
      );
      formData.files.add(MapEntry('document', file));
      var response = await dioRequest.post(
        dom + 'api/university/create-document/',
        data: formData,
      );
      if (response.statusCode == 200) {
        if (response.data['Response'] ==
            'University document successfully created.') {
          Navigator.pop(context);
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
    } catch (e) {
      Navigator.pop(context);
      error(context);
      refresh();
    }
  }

  Future<void> deleteDocument(Map profile, int documentID) async {
    String tok = await getToken();
    final response = await http
        .put(
          dom + 'api/university/delete-document/$documentID',
          headers: {
            HttpHeaders.authorizationHeader: "Token $tok",
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(
            <String, dynamic>{
              'university_id': profile['university_id'],
            },
          ),
        )
        .timeout(Duration(seconds: 10));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['Response'] == 'University document successfully deleted.') {
        Navigator.pop(context);
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

  void refresh() {
    setState(() {
      uniData = getUniversity();
    });
  }

  _deleteDocument(Map profile, int documentId) {
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
                deleteDocument(profile, documentId);
                loading(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scafKey,
      backgroundColor: Colors.white,
      drawer: NavDrawer(),
      body: FutureBuilder(
        future: uniData,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
              backgroundColor: Colors.white,
              drawer: NavDrawer(),
              appBar: CustomAppBar('University Profile'),
              body: Padding(
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
                      Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Text(
                          'Unable to establish a connection with our servers.\nCheck your connection and try again later.',
                          style: TextStyle(color: Colors.black54),
                          textAlign: TextAlign.center,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          }
          if (snapshot.hasData) {
            deadlines = [];
            appChips = [];
            topMajors = [];
            standOutFactors = [];
            testingReqs = [];
            documentChips = [];
            educationString = '';
            if (snapshot.data['stand_out_factors'] != null) {
              for (int i = 0;
                  i < snapshot.data['stand_out_factors'].length;
                  i++) {
                standOutFactors.add(
                  Chip(
                    backgroundColor: Colors.white12,
                    shape: StadiumBorder(
                        side: BorderSide(color: Color(0xff005fa8), width: 0.0)),
                    label: Text(
                      snapshot.data['stand_out_factors'][i],
                      style: TextStyle(fontSize: 15),
                    ),
                    elevation: 1,
                  ),
                );
              }
            }
            if (snapshot.data['degree_levels'] != null) {
              for (int i = 0; i < snapshot.data['degree_levels'].length; i++) {
                if (i == 0) {
                  educationString += '${snapshot.data['degree_levels'][i]}';
                } else {
                  educationString += ', ${snapshot.data['degree_levels'][i]}';
                }
              }
            }
            if (snapshot.data['top_majors'] != null) {
              for (int i = 0; i < snapshot.data['top_majors'].length; i++) {
                topMajors.add(
                  Chip(
                    visualDensity: VisualDensity.compact,
                    backgroundColor: Colors.white12,
                    shape: StadiumBorder(
                        side: BorderSide(color: Color(0xff005fa8), width: 0.0)),
                    label: Text(
                      snapshot.data['top_majors'][i],
                      style: TextStyle(
                          fontSize: 11, color: Colors.black.withOpacity(0.8)),
                    ),
                    elevation: 1,
                  ),
                );
              }
            }
            if (snapshot.data['testing_requirements'] != null) {
              for (int i = 0;
                  i < snapshot.data['testing_requirements'].length;
                  i++) {
                testingReqs.add(
                  Chip(
                    visualDensity: VisualDensity.compact,
                    backgroundColor: Colors.white12,
                    shape: StadiumBorder(
                        side: BorderSide(color: Color(0xff005fa8), width: 0.0)),
                    label: Text(
                      snapshot.data['testing_requirements'][i],
                      style: TextStyle(
                          fontSize: 11, color: Colors.black.withOpacity(0.8)),
                    ),
                    elevation: 1,
                  ),
                );
              }
            }
            if (snapshot.data['document_data'] != null) {
              for (int i = 0; i < snapshot.data['document_data'].length; i++) {
                documentChips.add(
                  InkWell(
                    child: Card(
                      margin: EdgeInsets.all(1),
                      shape: StadiumBorder(
                        side: BorderSide(color: Color(0xff005fa8), width: 0.0),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding:
                                EdgeInsets.only(top: 5, left: 11, bottom: 6),
                            child: Text(
                              snapshot.data['document_data'][i]
                                  ['document_title'],
                              style: TextStyle(
                                fontSize: 13.5,
                                color: Colors.black.withOpacity(0.8),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 5, left: 1, top: 1),
                            child: InkWell(
                              child: Icon(
                                Icons.close,
                                size: 19,
                              ),
                              onTap: () {
                                _deleteDocument(
                                    snapshot.data,
                                    snapshot.data['document_data'][i]
                                        ['document_id']);
                              },
                            ),
                          )
                        ],
                      ),
                      elevation: 1,
                    ),
                    onTap: () {
                      launch(snapshot.data['document_data'][i]['document_url']);
                    },
                  ),
                );
              }
            }
            if (snapshot.data['application_fee'] != null) {
              appChips.add(
                Chip(
                  backgroundColor: Colors.white12,
                  shape: StadiumBorder(
                      side: BorderSide(color: Color(0xff005fa8), width: 0.0)),
                  label: Text(
                    r'$' + snapshot.data['application_fee'].toString(),
                    style: TextStyle(fontSize: 16),
                  ),
                  elevation: 1,
                ),
              );
            }
            if (snapshot.data['common_app_accepted_status'] != null) {
              appChips.add(
                Chip(
                  labelPadding: EdgeInsets.only(right: 5, left: 5),
                  backgroundColor: Colors.white12,
                  shape: StadiumBorder(
                      side: BorderSide(color: Color(0xff005fa8), width: 0.0)),
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 3),
                        child: CachedNetworkImage(
                          width: 65,
                          fit: BoxFit.contain,
                          imageUrl:
                              'https://membersupport.commonapp.org/servlet/rtaImage?eid=ka10V000001DsVb&feoid=00N0V000008rTCP&refid=0EM0V0000017WaN',
                        ),
                      ),
                      snapshot.data['common_app_accepted_status']
                          ? Padding(
                              padding: EdgeInsets.only(left: 2),
                              child: Icon(
                                Icons.check_circle,
                                size: 26,
                                color: Colors.green,
                              ),
                            )
                          : Padding(
                              padding: EdgeInsets.only(left: 2),
                              child: Icon(
                                Icons.cancel,
                                color: Colors.red,
                              ),
                            ),
                    ],
                  ),
                  elevation: 1,
                ),
              );
            }
            if (snapshot.data['coalition_app_accepted_status'] != null) {
              appChips.add(
                Chip(
                  labelPadding: EdgeInsets.only(right: 5, left: 5),
                  backgroundColor: Colors.white12,
                  shape: StadiumBorder(
                      side: BorderSide(color: Color(0xff005fa8), width: 0.0)),
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 2),
                        child: CachedNetworkImage(
                          width: 70,
                          fit: BoxFit.contain,
                          imageUrl:
                              'https://thebiz.bentley.edu/wp-content/uploads/2016/10/coalition-logo-simple-horz-color-01.png',
                        ),
                      ),
                      snapshot.data['coalition_app_accepted_status']
                          ? Padding(
                              padding: EdgeInsets.only(left: 2),
                              child: Icon(
                                Icons.check_circle,
                                size: 26,
                                color: Colors.green,
                              ),
                            )
                          : Padding(
                              padding: EdgeInsets.only(left: 2),
                              child: Icon(
                                Icons.cancel,
                                color: Colors.red,
                              ),
                            ),
                    ],
                  ),
                  elevation: 1,
                ),
              );
            }
            if (snapshot.data['application_types'] != null) {
              for (int i = 0;
                  i < snapshot.data['application_types'].length;
                  i++) {
                deadlines.add(
                  Padding(
                    padding: EdgeInsets.only(top: 5, left: 23),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(bottom: 1),
                          child: Text(
                            snapshot.data['application_types'][i].keys.first
                                    .toString()
                                    .toUpperCase() +
                                ':',
                            style: TextStyle(
                                color: Colors.black.withOpacity(0.65),
                                fontSize: 12.5),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 6, top: 0.5),
                          child: Text(
                            snapshot.data['application_types'][i][snapshot
                                    .data['application_types'][i].keys.first]
                                .toString(),
                            style: TextStyle(
                                color: Colors.black.withOpacity(0.8),
                                fontSize: 17.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            }
            return CustomScrollView(
              shrinkWrap: false,
              slivers: <Widget>[
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  expandedHeight: 300,
                  flexibleSpace: Hero(
                    tag: snapshot.data['university_id'],
                    child: Stack(
                      children: <Widget>[
                        Positioned(
                          child: CachedNetworkImage(
                            fit: BoxFit.cover,
                            key: Key(snapshot.data['university_id'].toString()),
                            imageUrl: snapshot.data['image_url'] ??
                                'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cd/Black_flag.svg/1200px-Black_flag.svg.png',
                            imageBuilder: (context, imageProvider) => Container(
                              decoration: BoxDecoration(
                                image: imageProvider != null
                                    ? DecorationImage(
                                        alignment: Alignment.center,
                                        colorFilter: ColorFilter.mode(
                                            Colors.black.withAlpha(50),
                                            BlendMode.darken),
                                        image: imageProvider,
                                        fit: BoxFit.cover,
                                      )
                                    : DecorationImage(
                                        image: NetworkImage(
                                            'https://www.shareicon.net/data/512x512/2016/08/18/814358_school_512x512.png',
                                            scale: 6.5),
                                      ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              decoration: BoxDecoration(
                                color: Color(0xff005fa8),
                                image: DecorationImage(
                                  image: NetworkImage(
                                      'https://www.shareicon.net/data/512x512/2016/08/18/814358_school_512x512.png',
                                      scale: 6.5),
                                ),
                              ),
                            ),
                          ),
                          top: 0,
                          left: 0,
                          right: 0,
                          bottom: 0,
                        ),
                        Positioned(
                          child: Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Spacer(),
                                  Padding(
                                    padding:
                                        EdgeInsets.only(bottom: 40, right: 20),
                                    child: Stack(
                                      children: <Widget>[
                                        CircleAvatar(
                                          backgroundImage:
                                              CachedNetworkImageProvider(
                                            snapshot.data['logo_url'],
                                          ),
                                          backgroundColor: Colors.white,
                                          radius: 33,
                                        ),
                                        ClipOval(
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              child: Container(
                                                height: 66,
                                                width: 66,
                                                color: Colors.black
                                                    .withOpacity(0.35),
                                                child: Center(
                                                    child: Text(
                                                  'EDIT',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                )),
                                              ),
                                              onTap: () async {
                                                File image =
                                                    await FilePicker.getFile(
                                                  type: FileType.image,
                                                );
                                                if (image != null) {
                                                  editLogo(
                                                      snapshot.data, image);
                                                  loading(context);
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.only(right: 33.5),
                                child: Row(
                                  children: <Widget>[
                                    Spacer(),
                                    Row(
                                      children: <Widget>[
                                        Material(
                                          color: Colors.transparent,
                                          child: Text(
                                            snapshot.data['acceptance_rate']
                                                .toString()
                                                .split('.')
                                                .first,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                              fontSize: 23,
                                            ),
                                          ),
                                        ),
                                        Material(
                                          color: Colors.transparent,
                                          child: Text(
                                            '%',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                              fontSize: 14,
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    right: snapshot.data['selectivity']
                                                .toString()
                                                .toUpperCase() ==
                                            'MOST SELECTIVE'
                                        ? 14
                                        : snapshot.data['selectivity']
                                                    .toString()
                                                    .toUpperCase() ==
                                                'MORE SELECTIVE'
                                            ? 16
                                            : 30,
                                    bottom: 38),
                                child: Row(
                                  children: <Widget>[
                                    Spacer(),
                                    Material(
                                      color: Colors.transparent,
                                      child: Text(
                                        snapshot.data['selectivity']
                                            .toString()
                                            .toUpperCase(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                          fontSize: 9,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Row(
                                children: <Widget>[
                                  Spacer(),
                                  Padding(
                                    padding:
                                        EdgeInsets.only(right: 28, bottom: 18),
                                    child: ClipOval(
                                      child: Material(
                                        shape: CircleBorder(),
                                        color: Colors.black.withOpacity(0.4),
                                        child: IconButton(
                                          iconSize: 30,
                                          color: Colors.white,
                                          icon: Icon(Icons.create),
                                          onPressed: () async {
                                            File image =
                                                await FilePicker.getFile(
                                              type: FileType.image,
                                            );
                                            if (image != null) {
                                              editImage(snapshot.data, image);
                                              loading(context);
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(50),
                                    topRight: Radius.circular(50),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          bottom: -1,
                          left: 0,
                          right: 0,
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding:
                            EdgeInsets.only(left: 20, bottom: 3, right: 24),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: MediaQuery.of(context).size.width * 0.75,
                              child: Text(
                                snapshot.data['university_name'],
                                style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 21.5,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            Spacer(),
                            Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: InkWell(
                                child: Text(
                                  'EDIT',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xff005fa8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                onTap: () async {
                                  final List data = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditUniDetails(
                                        research:
                                            snapshot.data['research_or_not'],
                                        website: snapshot.data['website_url'],
                                        acceptance: int.parse(snapshot
                                            .data['acceptance_rate']
                                            .toString()
                                            .split('.')
                                            .first),
                                        ranking:
                                            snapshot.data['usnews_ranking'],
                                        degreeLevels:
                                            snapshot.data['degree_levels'],
                                        standOutFactors:
                                            snapshot.data['stand_out_factors'],
                                      ),
                                    ),
                                  );
                                  refresh();
                                  if (data != null) {
                                    editDetails(snapshot.data, data);
                                    loading(context);
                                  }
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(left: 22, top: 5),
                            child: Icon(
                              Icons.location_on,
                              color: Colors.black54,
                              size: 22,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 6, top: 4),
                            child: Text(
                              snapshot.data['university_location'],
                              style: TextStyle(
                                  color: Colors.black54, fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(left: 22, top: 4),
                            child: Icon(
                              Icons.show_chart,
                              color: Colors.black54,
                              size: 22,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 6, top: 4),
                            child: Text(
                              snapshot.data['usnews_ranking'].toString(),
                              style: TextStyle(
                                  color: Colors.black54, fontSize: 15),
                            ),
                          ),
                          Text(
                            snapshot.data['usnews_ranking']
                                    .toString()
                                    .endsWith('1')
                                ? 'st'
                                : snapshot.data['usnews_ranking']
                                        .toString()
                                        .endsWith('2')
                                    ? 'nd'
                                    : snapshot.data['usnews_ranking']
                                            .toString()
                                            .endsWith('3')
                                        ? 'rd'
                                        : 'th',
                            style:
                                TextStyle(color: Colors.black54, fontSize: 13),
                          )
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(left: 22, top: 5),
                            child: Icon(
                              snapshot.data['research_or_not']
                                  ? const IconData(0xF0093,
                                      fontFamily: 'maticons')
                                  : const IconData(0xF13F4,
                                      fontFamily: 'maticons'),
                              color: Colors.black54,
                              size: 22,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 6, top: 5),
                            child: snapshot.data['research_or_not']
                                ? Text(
                                    'Research Intensive',
                                    style: TextStyle(
                                        color: Colors.black54, fontSize: 15),
                                  )
                                : Text(
                                    'No Research',
                                    style: TextStyle(
                                        color: Colors.black54, fontSize: 15),
                                  ),
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(left: 22, top: 9),
                            child: Icon(
                              Icons.school,
                              color: Colors.black54,
                              size: 22,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 6, top: 9),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: Text(
                                educationString,
                                softWrap: true,
                                style: TextStyle(
                                    color: Colors.black54, fontSize: 15),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(left: 22, top: 5),
                            child: Icon(
                              Icons.person,
                              color: Colors.black54,
                              size: 22,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 5, top: 5),
                            child: InkWell(
                              child: Text(
                                '@' + snapshot.data['university_rep'],
                                style: TextStyle(
                                  color: Color(0xff005fa8),
                                ),
                              ),
                              onTap: () {},
                            ),
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(left: 22, top: 5),
                            child: Icon(
                              Icons.link,
                              color: Colors.black54,
                              size: 22,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 7, top: 5),
                            child: InkWell(
                              child: Text(
                                'Visit Website',
                                style: TextStyle(color: Color(0xff005fa8)),
                              ),
                              onTap: () {
                                launch(snapshot.data['website_url']);
                              },
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 18, top: 15, right: 16),
                        child: standOutFactors.isNotEmpty
                            ? Wrap(
                                spacing: 8,
                                direction: Axis.horizontal,
                                children: standOutFactors,
                              )
                            : Text(
                                'No Standout Factors',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12,
                                ),
                              ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 12, left: 18, right: 25),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'About',
                              style: TextStyle(
                                  color: Colors.black87, fontSize: 20),
                            ),
                            Spacer(),
                            InkWell(
                              child: Text(
                                'EDIT',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xff005fa8),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              onTap: () async {
                                final String data = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditAbout(
                                      about: snapshot
                                          .data['university_description'],
                                    ),
                                  ),
                                );
                                if (data != null) {
                                  editAbout(snapshot.data, data);
                                  loading(context);
                                }
                              },
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 2, left: 19, right: 18, bottom: 20),
                        child: Text(
                          snapshot.data['university_description'] ?? '',
                          maxLines: 100,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.black.withOpacity(0.7),
                              fontSize: 15),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 18, right: 25),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Top Majors',
                              style: TextStyle(
                                  color: Colors.black87, fontSize: 20),
                            ),
                            Spacer(),
                            InkWell(
                              child: Text(
                                'EDIT',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xff005fa8),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              onTap: () async {
                                final List data = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditTopMajors(
                                      curMajors: snapshot.data['top_majors'],
                                    ),
                                  ),
                                );
                                refresh();
                                if (data != null) {
                                  editTopMajors(snapshot.data, data);
                                  loading(context);
                                }
                              },
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 21, top: 2, right: 16, bottom: 20),
                        child: topMajors.isNotEmpty
                            ? Wrap(
                                spacing: 4,
                                direction: Axis.horizontal,
                                children: topMajors,
                              )
                            : Text(
                                'No Top Majors',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12,
                                ),
                              ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 18, right: 25),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Cost',
                              style: TextStyle(
                                  color: Colors.black87, fontSize: 20),
                            ),
                            Spacer(),
                            InkWell(
                              child: Text(
                                'EDIT',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xff005fa8),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              onTap: () async {
                                final List<int> data = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditCost(
                                      inState: snapshot.data['in_state_cost'],
                                      outOfState:
                                          snapshot.data['out_of_state_cost'],
                                      international:
                                          snapshot.data['international_cost'],
                                    ),
                                  ),
                                );
                                editCost(snapshot.data, data);
                                loading(context);
                              },
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 5, left: 23),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              'IN STATE:',
                              style: TextStyle(
                                  color: Colors.black.withOpacity(0.65),
                                  fontSize: 13),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 5),
                              child: Text(
                                r'$' + '${snapshot.data['in_state_cost']}',
                                style: TextStyle(
                                    color: Colors.black.withOpacity(0.8),
                                    fontSize: 18.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 5, left: 23),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              'OUT OF STATE:',
                              style: TextStyle(
                                  color: Colors.black.withOpacity(0.65),
                                  fontSize: 13),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 5),
                              child: Text(
                                r'$' + '${snapshot.data['out_of_state_cost']}',
                                style: TextStyle(
                                    color: Colors.black.withOpacity(0.8),
                                    fontSize: 18.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 5, left: 23, bottom: 25),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              'INTERNATIONAL:',
                              style: TextStyle(
                                  color: Colors.black.withOpacity(0.65),
                                  fontSize: 13),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 5),
                              child: Text(
                                r'$' + '${snapshot.data['international_cost']}',
                                style: TextStyle(
                                    color: Colors.black.withOpacity(0.8),
                                    fontSize: 18.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 18, right: 25),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Testing',
                              style: TextStyle(
                                  color: Colors.black87, fontSize: 20),
                            ),
                            Spacer(),
                            InkWell(
                              child: Text(
                                'EDIT',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xff005fa8),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              onTap: () async {
                                final List data = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditTesting(
                                      curTesting:
                                          snapshot.data['testing_requirements'],
                                    ),
                                  ),
                                );
                                refresh();
                                if (data != null) {
                                  editTesting(snapshot.data, data);
                                  loading(context);
                                }
                              },
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 21, top: 2, right: 16, bottom: 20),
                        child: testingReqs.isNotEmpty
                            ? Container(
                                child: Wrap(
                                  spacing: 4,
                                  direction: Axis.horizontal,
                                  children: testingReqs,
                                ),
                              )
                            : Text(
                                'No Testing Requirements',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12,
                                ),
                              ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 20, right: 25),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Application & Dates',
                              style: TextStyle(
                                  color: Colors.black87, fontSize: 20),
                            ),
                            Spacer(),
                            InkWell(
                              child: Text(
                                'EDIT',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xff005fa8),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              onTap: () async {
                                Map _appTypes = {};
                                for (int i = 0;
                                    i <
                                        snapshot
                                            .data['application_types'].length;
                                    i++) {
                                  _appTypes[snapshot
                                          .data['application_types'][i]
                                          .keys
                                          .first] =
                                      snapshot.data['application_types'][i][
                                              snapshot
                                                  .data['application_types'][i]
                                                  .keys
                                                  .first]
                                          .toString();
                                }
                                final List data = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditApplication(
                                      applicationFee:
                                          snapshot.data['application_fee'],
                                      commonApp: snapshot
                                          .data['common_app_accepted_status'],
                                      coalition: snapshot.data[
                                          'coalition_app_accepted_status'],
                                      applicationTypes: _appTypes,
                                    ),
                                  ),
                                );
                                refresh();
                                if (data != null) {
                                  editApplication(snapshot.data, data[0],
                                      data[1], data[2], data[3]);
                                  loading(context);
                                }
                              },
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 20, top: 1, right: 16),
                        child: appChips.isNotEmpty
                            ? Container(
                                child: Wrap(
                                  spacing: 4,
                                  direction: Axis.horizontal,
                                  children: appChips,
                                ),
                              )
                            : Padding(
                                padding: EdgeInsets.only(left: 1),
                                child: Text(
                                  'No Application Information',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 20),
                        child: deadlines.isNotEmpty
                            ? Column(
                                children: deadlines,
                              )
                            : Padding(
                                padding: EdgeInsets.only(left: 21, top: 5),
                                child: Text(
                                  'No Application Deadlines',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 20, right: 25),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Documents',
                              style: TextStyle(
                                  color: Colors.black87, fontSize: 20),
                            ),
                            Spacer(),
                            InkWell(
                              child: Text(
                                'ADD',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xff005fa8),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              onTap: () async {
                                final List data = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddDocument(),
                                  ),
                                );
                                addDocument(snapshot.data, data[0], data[1]);
                                loading(context);
                              },
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 19, top: 5, right: 20, bottom: 25),
                        child: documentChips.isNotEmpty
                            ? Wrap(
                                spacing: 4,
                                runSpacing: 8,
                                direction: Axis.horizontal,
                                children: documentChips,
                              )
                            : Padding(
                                padding: EdgeInsets.only(left: 1),
                                child: Text(
                                  'No Documents',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                      ),
                    ],
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

class EditUniDetails extends StatefulWidget {
  final bool research;
  final String website;
  final int acceptance;
  final int ranking;
  final List degreeLevels;
  final List standOutFactors;
  EditUniDetails({
    @required this.research,
    @required this.website,
    @required this.acceptance,
    @required this.ranking,
    @required this.degreeLevels,
    @required this.standOutFactors,
  });
  @override
  _EditUniDetailsState createState() => _EditUniDetailsState();
}

class _EditUniDetailsState extends State<EditUniDetails> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _website = TextEditingController();
  TextEditingController _acceptance = TextEditingController();
  TextEditingController _ranking = TextEditingController();
  TextEditingController _addDegree = TextEditingController();
  TextEditingController _addFactor = TextEditingController();

  List _standOutFactors;
  List<Widget> factorChips;
  List _degreeLevels;
  List<Widget> degreeChips;
  bool _research;

  @override
  void initState() {
    super.initState();
    _research = widget.research;
    _website.text = widget.website;
    _ranking.text = widget.ranking.toString();
    _acceptance.text = widget.acceptance.toString();
    _standOutFactors = widget.standOutFactors ?? [];
    _degreeLevels = widget.degreeLevels ?? [];
  }

  @override
  Widget build(BuildContext context) {
    factorChips = [];
    degreeChips = [];
    for (int i = 0; i < _standOutFactors.length; i++) {
      factorChips.add(
        Chip(
          visualDensity: VisualDensity.compact,
          labelPadding: EdgeInsets.only(left: 10, top: 1, bottom: 1),
          padding: EdgeInsets.only(left: 3),
          backgroundColor: Colors.white12,
          shape: StadiumBorder(
              side: BorderSide(color: Color(0xff005fa8), width: 0.0)),
          label: Text(
            _standOutFactors[i],
            overflow: TextOverflow.ellipsis,
            style:
                TextStyle(fontSize: 11, color: Colors.black.withOpacity(0.8)),
          ),
          elevation: 1,
          deleteIcon: Icon(
            Icons.close,
            size: 22,
          ),
          onDeleted: () {
            setState(() {
              _standOutFactors.remove(_standOutFactors[i]);
            });
          },
        ),
      );
    }
    for (int i = 0; i < _degreeLevels.length; i++) {
      degreeChips.add(
        Chip(
          visualDensity: VisualDensity.compact,
          labelPadding: EdgeInsets.only(left: 10, top: 1, bottom: 1),
          padding: EdgeInsets.only(left: 3),
          backgroundColor: Colors.white12,
          shape: StadiumBorder(
              side: BorderSide(color: Color(0xff005fa8), width: 0.0)),
          label: Text(
            _degreeLevels[i],
            overflow: TextOverflow.ellipsis,
            style:
                TextStyle(fontSize: 11, color: Colors.black.withOpacity(0.8)),
          ),
          elevation: 1,
          deleteIcon: Icon(
            Icons.close,
            size: 22,
          ),
          onDeleted: () {
            setState(() {
              _degreeLevels.remove(_degreeLevels[i]);
            });
          },
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xff005fa8),
        actions: <Widget>[
          FlatButton(
            child: Text(
              'SAVE',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
            onPressed: () {
              if (_formKey.currentState.validate()) {
                List data = [
                  int.parse(_acceptance.text),
                  int.parse(_ranking.text),
                  _research,
                  _degreeLevels,
                  _website.text,
                  _standOutFactors
                ];
                Navigator.pop(context, data);
              }
            },
          )
        ],
        title: Text('Edit Details', maxLines: 1),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 20, top: 30),
              child: Text(
                'Acceptance %',
                style: TextStyle(fontSize: 21, color: Colors.black87),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 20, right: 30),
              child: Theme(
                data: ThemeData(primaryColor: Color(0xff005fa8)),
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  cursorColor: Color(0xff005fa8),
                  controller: _acceptance,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xff005fa8), width: 0.0),
                    ),
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'This field is required';
                    }
                    return null;
                  },
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 20, top: 30),
              child: Text(
                'Ranking',
                style: TextStyle(fontSize: 21, color: Colors.black87),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 20, right: 30),
              child: Theme(
                data: ThemeData(primaryColor: Color(0xff005fa8)),
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  cursorColor: Color(0xff005fa8),
                  controller: _ranking,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xff005fa8), width: 0.0),
                    ),
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'This field is required';
                    }
                    return null;
                  },
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 20, top: 30),
              child: Text(
                'Research',
                style: TextStyle(fontSize: 21, color: Colors.black87),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 20, right: 30, top: 2),
              child: DropdownButtonFormField(
                icon: Icon(
                  Icons.arrow_drop_down,
                  size: 25,
                ),
                hint: Text(
                  "Research Option",
                  style: TextStyle(fontSize: 16),
                ),
                itemHeight: kMinInteractiveDimension,
                items: [
                  DropdownMenuItem(
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(left: 5, right: 5),
                          child: Icon(
                            const IconData(0xF0093, fontFamily: 'maticons'),
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'Research Intensive',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    value: true,
                  ),
                  DropdownMenuItem(
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(left: 5, right: 5),
                          child: Icon(
                            const IconData(0xF13F4, fontFamily: 'maticons'),
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'No Research',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    value: false,
                  ),
                ],
                value: _research,
                validator: (value) =>
                    value == null ? 'This field is important' : null,
                isExpanded: true,
                onChanged: (value) {
                  setState(() {
                    _research = value;
                  });
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 20, top: 30),
              child: Text(
                'Degrees Offered',
                style: TextStyle(fontSize: 21, color: Colors.black87),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 20, top: 2, right: 15),
              child: _degreeLevels.isNotEmpty
                  ? Wrap(
                      spacing: 4,
                      direction: Axis.horizontal,
                      children: degreeChips,
                    )
                  : Padding(
                      padding: EdgeInsets.only(left: 1),
                      child: Text(
                        'No Degree Levels',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 22, right: 10),
              child: Row(
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: Theme(
                      data: ThemeData(primaryColor: Color(0xff005fa8)),
                      child: TextFormField(
                        cursorColor: Color(0xff005fa8),
                        keyboardType: TextInputType.number,
                        controller: _addDegree,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Color(0xff005fa8), width: 0.0),
                          ),
                        ),
                        validator: (value) {
                          return null;
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10, top: 5),
                    child: RaisedButton(
                      visualDensity: VisualDensity.compact,
                      elevation: 2,
                      color: Color(0xff005fa8),
                      textColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                      child: Text('ADD'),
                      onPressed: () async {
                        if (_addDegree.text.isNotEmpty) {
                          setState(() {
                            _degreeLevels.add(_addDegree.text);
                            _addDegree.clear();
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 20, top: 30),
              child: Text(
                'Website',
                style: TextStyle(fontSize: 21, color: Colors.black87),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 20, right: 30),
              child: Theme(
                data: ThemeData(primaryColor: Color(0xff005fa8)),
                child: TextFormField(
                  cursorColor: Color(0xff005fa8),
                  controller: _website,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xff005fa8), width: 0.0),
                    ),
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'This field is required';
                    }
                    return null;
                  },
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 20, top: 30),
              child: Text(
                'Stand Out Factors',
                style: TextStyle(fontSize: 21, color: Colors.black87),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 20, top: 2, right: 15),
              child: _standOutFactors.isNotEmpty
                  ? Wrap(
                      spacing: 4,
                      direction: Axis.horizontal,
                      children: factorChips,
                    )
                  : Padding(
                      padding: EdgeInsets.only(left: 1),
                      child: Text(
                        'No Stand Out Factors',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 22, right: 10, bottom: 20),
              child: Row(
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: Theme(
                      data: ThemeData(primaryColor: Color(0xff005fa8)),
                      child: TextFormField(
                        cursorColor: Color(0xff005fa8),
                        keyboardType: TextInputType.number,
                        controller: _addFactor,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Color(0xff005fa8), width: 0.0),
                          ),
                        ),
                        validator: (value) {
                          return null;
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10, top: 5),
                    child: RaisedButton(
                      visualDensity: VisualDensity.compact,
                      elevation: 2,
                      color: Color(0xff005fa8),
                      textColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                      child: Text('ADD'),
                      onPressed: () async {
                        if (_addFactor.text.isNotEmpty) {
                          setState(() {
                            _standOutFactors.add(_addFactor.text);
                            _addFactor.clear();
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EditAbout extends StatefulWidget {
  final String about;
  EditAbout({@required this.about});
  @override
  _EditAboutState createState() => _EditAboutState();
}

class _EditAboutState extends State<EditAbout> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _about = TextEditingController();

  @override
  void initState() {
    _about.text = widget.about;
    super.initState();
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
              'SAVE',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
            onPressed: () {
              if (_formKey.currentState.validate()) {
                Navigator.pop(context, _about.text);
              }
            },
          )
        ],
        title: Text('Edit About', maxLines: 1),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 25, top: 30),
              child: Text(
                'About',
                style: TextStyle(fontSize: 25, color: Colors.black87),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 25, right: 25, top: 10),
              child: Theme(
                data: ThemeData(primaryColor: Color(0xff005fa8)),
                child: TextFormField(
                  cursorColor: Color(0xff005fa8),
                  controller: _about,
                  maxLines: null,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xff005fa8), width: 0.0),
                    ),
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'This field is required';
                    }
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

class EditTopMajors extends StatefulWidget {
  final List curMajors;
  EditTopMajors({@required this.curMajors});
  @override
  _EditTopMajorsState createState() => _EditTopMajorsState();
}

class _EditTopMajorsState extends State<EditTopMajors> {
  TextEditingController _major = TextEditingController();
  List tms;
  List<Widget> chips;

  @override
  void initState() {
    super.initState();
    tms = widget.curMajors;
  }

  @override
  Widget build(BuildContext context) {
    chips = [];
    for (int i = 0; i < tms.length; i++) {
      chips.add(
        Chip(
          visualDensity: VisualDensity.compact,
          labelPadding: EdgeInsets.only(left: 10, top: 1, bottom: 1),
          padding: EdgeInsets.only(left: 3),
          backgroundColor: Colors.white12,
          shape: StadiumBorder(
              side: BorderSide(color: Color(0xff005fa8), width: 0.0)),
          label: Text(
            tms[i],
            overflow: TextOverflow.ellipsis,
            style:
                TextStyle(fontSize: 11, color: Colors.black.withOpacity(0.8)),
          ),
          elevation: 1,
          deleteIcon: Icon(
            Icons.close,
            size: 22,
          ),
          onDeleted: () {
            setState(() {
              tms.remove(tms[i]);
            });
          },
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xff005fa8),
        actions: <Widget>[
          FlatButton(
            child: Text(
              'SAVE',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
            onPressed: () {
              Navigator.pop(context, tms);
            },
          )
        ],
        title: Text('Edit Top Majors', maxLines: 1),
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 20, top: 30),
            child: Text(
              'Top majors',
              style: TextStyle(fontSize: 25, color: Colors.black87),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 21, top: 2, right: 15, bottom: 20),
            child: tms.isNotEmpty
                ? Wrap(
                    spacing: 4,
                    direction: Axis.horizontal,
                    children: chips,
                  )
                : Padding(
                    padding: EdgeInsets.only(left: 3, top: 5),
                    child: Text(
                      'No Top Majors',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 25, right: 25, top: 0),
            child: Row(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.55,
                  child: Theme(
                    data: ThemeData(primaryColor: Color(0xff005fa8)),
                    child: TextFormField(
                      cursorColor: Color(0xff005fa8),
                      keyboardType: TextInputType.number,
                      controller: _major,
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0xff005fa8), width: 0.0),
                        ),
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'This field is required';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10, top: 5),
                  child: RaisedButton(
                    elevation: 2,
                    color: Color(0xff005fa8),
                    textColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5))),
                    child: Text('ADD'),
                    onPressed: () async {
                      if (_major.text.isNotEmpty) {
                        setState(() {
                          tms.add(_major.text);
                          _major.clear();
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EditCost extends StatefulWidget {
  final int inState;
  final int outOfState;
  final int international;
  EditCost({@required this.inState, this.outOfState, this.international});
  @override
  _EditCostState createState() => _EditCostState();
}

class _EditCostState extends State<EditCost> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _inState = TextEditingController();
  TextEditingController _outOfState = TextEditingController();
  TextEditingController _international = TextEditingController();

  @override
  void initState() {
    _inState.text = widget.inState.toString();
    _outOfState.text = widget.outOfState.toString();
    _international.text = widget.international.toString();
    super.initState();
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
              'SAVE',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
            onPressed: () {
              if (_formKey.currentState.validate()) {
                List<int> data = [
                  int.parse(_inState.text),
                  int.parse(_outOfState.text),
                  int.parse(_international.text),
                ];
                Navigator.pop(context, data);
              }
            },
          )
        ],
        title: Text('Edit Cost', maxLines: 1),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 25, top: 30),
              child: Text(
                'In-State Cost',
                style: TextStyle(fontSize: 20, color: Colors.black87),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 25, right: 25, top: 0),
              child: Theme(
                data: ThemeData(primaryColor: Color(0xff005fa8)),
                child: TextFormField(
                  cursorColor: Color(0xff005fa8),
                  keyboardType: TextInputType.number,
                  controller: _inState,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xff005fa8), width: 0.0),
                    ),
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'This field is required';
                    }
                    return null;
                  },
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 25, top: 35),
              child: Text(
                'Out-of-State Cost',
                style: TextStyle(fontSize: 20, color: Colors.black87),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 25, right: 25),
              child: Theme(
                data: ThemeData(primaryColor: Color(0xff005fa8)),
                child: TextFormField(
                  cursorColor: Color(0xff005fa8),
                  keyboardType: TextInputType.number,
                  controller: _outOfState,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xff005fa8), width: 0.0),
                    ),
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'This field is required';
                    }
                    return null;
                  },
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 25, top: 35),
              child: Text(
                'International Cost',
                style: TextStyle(fontSize: 20, color: Colors.black87),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 25, right: 25),
              child: Theme(
                data: ThemeData(primaryColor: Color(0xff005fa8)),
                child: TextFormField(
                  cursorColor: Color(0xff005fa8),
                  keyboardType: TextInputType.number,
                  controller: _international,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xff005fa8), width: 0.0),
                    ),
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'This field is required';
                    }
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

class EditTesting extends StatefulWidget {
  final List curTesting;
  EditTesting({@required this.curTesting});
  @override
  _EditTestingState createState() => _EditTestingState();
}

class _EditTestingState extends State<EditTesting> {
  List newTesting;
  List options = ['SAT', 'ACT', 'SAT Subject', 'TOEFL', 'IELTS', 'AP'];
  List<Widget> testOptions;

  @override
  void initState() {
    super.initState();
    newTesting = widget.curTesting;
  }

  @override
  Widget build(BuildContext context) {
    testOptions = [];
    for (int i = 0; i < options.length; i++) {
      testOptions.add(
        Material(
          color: Colors.transparent,
          child: ListTile(
              key: Key(options[i]),
              leading: Checkbox(
                activeColor: Color(0xff005fa8),
                value: newTesting.contains(options[i]),
                onChanged: (newValue) {
                  if (newTesting.contains(options[i])) {
                    newTesting.remove(options[i]);
                  } else {
                    newTesting.add(options[i]);
                  }
                  setState(() {});
                },
              ),
              title: Text(
                options[i],
                style: TextStyle(color: Colors.black, fontSize: 17),
              ),
              onTap: () {
                if (newTesting.contains(options[i])) {
                  newTesting.remove(options[i]);
                } else {
                  newTesting.add(options[i]);
                }
                setState(() {});
              }),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xff005fa8),
        actions: <Widget>[
          FlatButton(
            child: Text(
              'SAVE',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
            onPressed: () {
              Navigator.pop(context, newTesting);
            },
          )
        ],
        title: Text('Edit Testing', maxLines: 1),
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 20, top: 30),
            child: Text(
              'Testing',
              style: TextStyle(fontSize: 25, color: Colors.black87),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Column(
              children: testOptions,
            ),
          )
        ],
      ),
    );
  }
}

class EditApplication extends StatefulWidget {
  final int applicationFee;
  final bool commonApp;
  final bool coalition;
  final Map applicationTypes;
  EditApplication(
      {@required this.applicationFee,
      @required this.commonApp,
      @required this.coalition,
      @required this.applicationTypes});
  @override
  _EditApplicationState createState() => _EditApplicationState();
}

class _EditApplicationState extends State<EditApplication> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _fee = TextEditingController();
  TextEditingController _earlyActionController = TextEditingController();
  TextEditingController _earlyDecisionController = TextEditingController();
  TextEditingController _regularDecisionController = TextEditingController();

  Map _applicationTypes;
  bool _commonApp;
  bool _coalition;
  DateTime _earlyAction;
  // ignore: unused_field
  DateTime _earlyDecision;
  DateTime _regularDecision;

  @override
  void initState() {
    super.initState();
    _fee.text = widget.applicationFee.toString();
    _commonApp = widget.commonApp ?? false;
    _coalition = widget.coalition ?? false;
    _applicationTypes = widget.applicationTypes ?? {};
    _earlyActionController.text = _applicationTypes['Early Action'] ?? '';
    _earlyDecisionController.text = _applicationTypes['Early Decision'] ?? '';
    _regularDecisionController.text =
        _applicationTypes['Regular Decision'] ?? '';
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
              'SAVE',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
            onPressed: () {
              if (_formKey.currentState.validate()) {
                List data = [
                  int.parse(_fee.text),
                  _commonApp,
                  _coalition,
                  _applicationTypes
                ];
                Navigator.pop(context, data);
              }
            },
          )
        ],
        title: Text('Edit Application Info', maxLines: 1),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 25, top: 30),
              child: Text(
                'Application Fee',
                style: TextStyle(fontSize: 20, color: Colors.black87),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 25, right: 25, top: 0),
              child: Theme(
                data: ThemeData(primaryColor: Color(0xff005fa8)),
                child: TextFormField(
                  cursorColor: Color(0xff005fa8),
                  keyboardType: TextInputType.number,
                  controller: _fee,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xff005fa8), width: 0.0),
                    ),
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'This field is required';
                    }
                    return null;
                  },
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 25, top: 30),
              child: Text(
                'Application Modes',
                style: TextStyle(fontSize: 20, color: Colors.black87),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Material(
                color: Colors.transparent,
                child: ListTile(
                    key: Key('Common App'),
                    leading: Checkbox(
                      activeColor: Color(0xff005fa8),
                      value: _commonApp,
                      onChanged: (newValue) {
                        _commonApp = !_commonApp;
                        setState(() {});
                      },
                    ),
                    title: CachedNetworkImage(
                      alignment: Alignment.centerLeft,
                      height: 35,
                      fit: BoxFit.fitHeight,
                      imageUrl:
                          'https://membersupport.commonapp.org/servlet/rtaImage?eid=ka10V000001DsVb&feoid=00N0V000008rTCP&refid=0EM0V0000017WaN',
                    ),
                    onTap: () {
                      _commonApp = !_commonApp;
                      setState(() {});
                    }),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Material(
                color: Colors.transparent,
                child: ListTile(
                    key: Key('Coalition'),
                    leading: Checkbox(
                      activeColor: Color(0xff005fa8),
                      value: _coalition,
                      onChanged: (newValue) {
                        _coalition = !_coalition;
                        setState(() {});
                      },
                    ),
                    title: CachedNetworkImage(
                      alignment: Alignment.centerLeft,
                      height: 35,
                      fit: BoxFit.fitHeight,
                      imageUrl:
                          'https://thebiz.bentley.edu/wp-content/uploads/2016/10/coalition-logo-simple-horz-color-01.png',
                    ),
                    onTap: () {
                      _coalition = !_coalition;
                      setState(() {});
                    }),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 25, top: 30),
              child: Text(
                'Application Dates',
                style: TextStyle(fontSize: 20, color: Colors.black87),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10, top: 15),
              child: Material(
                color: Colors.transparent,
                child: ListTile(
                    key: Key('Early Action'),
                    leading: Checkbox(
                      activeColor: Color(0xff005fa8),
                      value: _applicationTypes.containsKey('Early Action'),
                      onChanged: (newValue) {
                        if (_applicationTypes.containsKey('Early Action')) {
                          _applicationTypes.remove('Early Action');
                        } else {
                          _applicationTypes['Early Action'] =
                              _earlyActionController.text;
                        }
                        setState(() {});
                      },
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text('Early Action',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500)),
                        Padding(
                          padding: EdgeInsets.only(right: 30),
                          child: Theme(
                            data: ThemeData(primaryColor: Color(0xff005fa8)),
                            child: DateTimeField(
                              validator: (value) {
                                if (value == null &&
                                    _applicationTypes
                                        .containsKey('Early Action')) {
                                  return 'You must specify a date';
                                }
                                return null;
                              },
                              cursorColor: Color(0xff005fa8),
                              initialValue: DateTime.now(),
                              controller: _earlyActionController,
                              decoration: InputDecoration(
                                border: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color(0xff005fa8), width: 0.0),
                                ),
                              ),
                              format: DateFormat.MMMMd(),
                              onChanged: (value) {
                                setState(() {
                                  _earlyAction = value;
                                  if (_applicationTypes
                                      .containsKey('Early Action')) {
                                    _applicationTypes['Early Action'] =
                                        DateFormat.MMMMd().format(_earlyAction);
                                  }
                                  setState(() {});
                                });
                              },
                              onShowPicker: (context, currentValue) async {
                                final _date = await showDatePicker(
                                  context: context,
                                  firstDate: DateTime(1900),
                                  initialDate: currentValue ?? DateTime.now(),
                                  lastDate: DateTime(2150),
                                  builder: (context, child) {
                                    return Theme(
                                      data: ThemeData(
                                          colorScheme: ColorScheme(
                                              brightness: Brightness.light,
                                              error: Color(0xff005fa8),
                                              onError: Colors.red,
                                              background: Color(0xff005fa8),
                                              primary: Color(0xff005fa8),
                                              primaryVariant: Color(0xff005fa8),
                                              secondary: Color(0xff005fa8),
                                              secondaryVariant:
                                                  Color(0xff005fa8),
                                              onPrimary: Colors.white,
                                              surface: Color(0xff005fa8),
                                              onSecondary: Colors.black,
                                              onSurface: Colors.black,
                                              onBackground: Colors.black)),
                                      child: child,
                                    );
                                  },
                                );
                                if (_date != null) {
                                  return _date;
                                } else {
                                  return currentValue;
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      if (_applicationTypes.containsKey('Early Action')) {
                        _applicationTypes.remove('Early Action');
                      } else {
                        _applicationTypes['Early Action'] =
                            _earlyActionController.text;
                      }
                      setState(() {});
                    }),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10, top: 15),
              child: Material(
                color: Colors.transparent,
                child: ListTile(
                    key: Key('Early Decision'),
                    leading: Checkbox(
                      activeColor: Color(0xff005fa8),
                      value: _applicationTypes.containsKey('Early Decision'),
                      onChanged: (newValue) {
                        if (_applicationTypes.containsKey('Early Decision')) {
                          _applicationTypes.remove('Early Decision');
                        } else {
                          _applicationTypes['Early Decision'] =
                              _earlyDecisionController.text;
                        }
                        setState(() {});
                      },
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text('Early Decision',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500)),
                        Padding(
                          padding: EdgeInsets.only(right: 30),
                          child: Theme(
                            data: ThemeData(primaryColor: Color(0xff005fa8)),
                            child: DateTimeField(
                              validator: (value) {
                                if (value == null &&
                                    _applicationTypes
                                        .containsKey('Early Decision')) {
                                  return 'You must specify a date';
                                }
                                return null;
                              },
                              cursorColor: Color(0xff005fa8),
                              initialValue: DateTime.now(),
                              controller: _earlyDecisionController,
                              decoration: InputDecoration(
                                border: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color(0xff005fa8), width: 0.0),
                                ),
                              ),
                              format: DateFormat.MMMMd(),
                              onChanged: (value) {
                                setState(() {
                                  _earlyDecision = value;
                                  if (_applicationTypes
                                      .containsKey('Early Decision')) {
                                    _applicationTypes['Early Decision'] =
                                        _earlyDecisionController.text;
                                  }
                                });
                              },
                              onShowPicker: (context, currentValue) async {
                                final _date = await showDatePicker(
                                  context: context,
                                  firstDate: DateTime(1900),
                                  initialDate: currentValue ?? DateTime.now(),
                                  lastDate: DateTime(2150),
                                  builder: (context, child) {
                                    return Theme(
                                      data: ThemeData(
                                          colorScheme: ColorScheme(
                                              brightness: Brightness.light,
                                              error: Color(0xff005fa8),
                                              onError: Colors.red,
                                              background: Color(0xff005fa8),
                                              primary: Color(0xff005fa8),
                                              primaryVariant: Color(0xff005fa8),
                                              secondary: Color(0xff005fa8),
                                              secondaryVariant:
                                                  Color(0xff005fa8),
                                              onPrimary: Colors.white,
                                              surface: Color(0xff005fa8),
                                              onSecondary: Colors.black,
                                              onSurface: Colors.black,
                                              onBackground: Colors.black)),
                                      child: child,
                                    );
                                  },
                                );
                                if (_date != null) {
                                  return _date;
                                } else {
                                  return currentValue;
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      if (_applicationTypes.containsKey('Early Decision')) {
                        _applicationTypes.remove('Early Decision');
                      } else {
                        _applicationTypes['Early Decision'] =
                            _earlyDecisionController.text;
                      }
                      setState(() {});
                    }),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10, top: 15, bottom: 20),
              child: Material(
                color: Colors.transparent,
                child: ListTile(
                    key: Key('Regular Decision'),
                    leading: Checkbox(
                      activeColor: Color(0xff005fa8),
                      value: _applicationTypes.containsKey('Regular Decision'),
                      onChanged: (newValue) {
                        if (_applicationTypes.containsKey('Regular Decision')) {
                          _applicationTypes.remove('Regular Decision');
                        } else {
                          _applicationTypes['Regular Decision'] =
                              _regularDecisionController.text;
                        }
                        setState(() {});
                      },
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text('Regular Decision',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500)),
                        Padding(
                          padding: EdgeInsets.only(right: 30),
                          child: Theme(
                            data: ThemeData(primaryColor: Color(0xff005fa8)),
                            child: DateTimeField(
                              validator: (value) {
                                if (value == null &&
                                    _applicationTypes
                                        .containsKey('Regular Decision')) {
                                  return 'You must specify a date';
                                }
                                return null;
                              },
                              cursorColor: Color(0xff005fa8),
                              initialValue: DateTime.now(),
                              controller: _regularDecisionController,
                              decoration: InputDecoration(
                                border: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color(0xff005fa8), width: 0.0),
                                ),
                              ),
                              format: DateFormat.MMMMd(),
                              onChanged: (value) {
                                setState(() {
                                  _regularDecision = value;
                                  if (_applicationTypes
                                      .containsKey('Regular Decision')) {
                                    _applicationTypes['Regular Decision'] =
                                        DateFormat.MMMMd()
                                            .format(_regularDecision);
                                  }
                                });
                              },
                              onShowPicker: (context, currentValue) async {
                                final _date = await showDatePicker(
                                  context: context,
                                  firstDate: DateTime(1900),
                                  initialDate: currentValue ?? DateTime.now(),
                                  lastDate: DateTime(2150),
                                  builder: (context, child) {
                                    return Theme(
                                      data: ThemeData(
                                          colorScheme: ColorScheme(
                                              brightness: Brightness.light,
                                              error: Color(0xff005fa8),
                                              onError: Colors.red,
                                              background: Color(0xff005fa8),
                                              primary: Color(0xff005fa8),
                                              primaryVariant: Color(0xff005fa8),
                                              secondary: Color(0xff005fa8),
                                              secondaryVariant:
                                                  Color(0xff005fa8),
                                              onPrimary: Colors.white,
                                              surface: Color(0xff005fa8),
                                              onSecondary: Colors.black,
                                              onSurface: Colors.black,
                                              onBackground: Colors.black)),
                                      child: child,
                                    );
                                  },
                                );
                                if (_date != null) {
                                  return _date;
                                } else {
                                  return currentValue;
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      if (_applicationTypes.containsKey('Regular Decision')) {
                        _applicationTypes.remove('Regular Decision');
                      } else {
                        _applicationTypes['Regular Decision'] =
                            _regularDecisionController.text;
                      }
                      setState(() {});
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddDocument extends StatefulWidget {
  @override
  _AddDocumentState createState() => _AddDocumentState();
}

class _AddDocumentState extends State<AddDocument> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _title = TextEditingController();
  File _document;
  @override
  void initState() {
    super.initState();
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
              'ADD',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
            onPressed: () {
              if (_formKey.currentState.validate() && _document != null) {
                List data = [_title.text, _document];
                Navigator.pop(context, data);
              }
            },
          )
        ],
        title: Text('Add Document', maxLines: 1),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 20, top: 30),
              child: Text(
                'Title',
                style: TextStyle(fontSize: 21, color: Colors.black87),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 23, right: 30),
              child: Theme(
                data: ThemeData(primaryColor: Color(0xff005fa8)),
                child: TextFormField(
                  cursorColor: Color(0xff005fa8),
                  controller: _title,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Color(0xff005fa8), width: 0.0),
                    ),
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Document title is required';
                    }
                    return null;
                  },
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 20, top: 30),
              child: Text(
                'Document',
                style: TextStyle(fontSize: 21, color: Colors.black87),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 21, right: 10, top: 10),
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
                          _document = file;
                        });
                      }
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.48,
                      child: Text(
                          _document?.path?.split('/')?.last ?? 'No file chosen',
                          style: TextStyle(
                              color: _document == null
                                  ? Colors.red
                                  : Colors.black87)),
                    ),
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
