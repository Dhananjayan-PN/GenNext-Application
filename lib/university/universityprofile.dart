import 'package:http/http.dart' as http;
import 'package:dio/dio.dart' as dio;
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

  bool myInterceptor(bool stopDefaultButtonEvent) {
    curPage = UniHomeScreen(user: newUser);
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.fade,
            child: UniHomeScreen(user: newUser)));
    return true;
  }

  Future<void> getUniversity() async {
    String tok = await getToken();
    final response = await http.get(
      dom + 'api/university/profile',
      headers: {HttpHeaders.authorizationHeader: "Token $tok"},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body)['university_data'];
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
    print(response.body);
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

  void refresh() {
    setState(() {
      uniData = getUniversity();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scafKey,
      backgroundColor: Colors.white,
      drawer: NavDrawer(
        user: newUser,
        name: newUser.firstname + ' ' + newUser.lastname,
        email: newUser.email,
      ),
      body: FutureBuilder(
        future: uniData,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
              backgroundColor: Colors.white,
              drawer: NavDrawer(
                user: newUser,
                name: newUser.firstname + ' ' + newUser.lastname,
                email: newUser.email,
              ),
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
                    label: Text(snapshot.data['stand_out_factors'][i]),
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
                  ActionChip(
                    avatar: Icon(
                      Icons.insert_drive_file,
                      size: 18,
                      color: Color(0xff005fa8),
                    ),
                    labelPadding: EdgeInsets.only(right: 5),
                    visualDensity: VisualDensity.compact,
                    backgroundColor: Colors.white12,
                    shape: StadiumBorder(
                        side: BorderSide(color: Color(0xff005fa8), width: 0.0)),
                    label: Text(
                      snapshot.data['document_data'][i]['document_name'],
                      style: TextStyle(
                          fontSize: 12.5, color: Colors.black.withOpacity(0.8)),
                    ),
                    elevation: 1,
                    onPressed: () {
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
                  avatar: snapshot.data['common_app_accepted_status']
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
                  backgroundColor: Colors.white12,
                  shape: StadiumBorder(
                      side: BorderSide(color: Color(0xff005fa8), width: 0.0)),
                  label: CachedNetworkImage(
                    width: 65,
                    fit: BoxFit.contain,
                    imageUrl:
                        'https://membersupport.commonapp.org/servlet/rtaImage?eid=ka10V000001DsVb&feoid=00N0V000008rTCP&refid=0EM0V0000017WaN',
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
                          padding: EdgeInsets.only(left: 5, top: 0.5),
                          child: Text(
                            snapshot.data['application_types'][i][snapshot
                                    .data['application_types'][i].keys.first]
                                .toString(),
                            style: TextStyle(
                                color: Colors.black.withOpacity(0.8),
                                fontSize: 18.5),
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
                                        EdgeInsets.only(bottom: 42, right: 20),
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
                              Row(
                                children: <Widget>[
                                  Spacer(),
                                  Padding(
                                    padding:
                                        EdgeInsets.only(right: 11, bottom: 45),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
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
                                        ),
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
                                  )
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Spacer(),
                                  Padding(
                                    padding:
                                        EdgeInsets.only(right: 28, bottom: 20),
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
                                  final data = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditUniDetails(),
                                    ),
                                  );
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
                                  ? IconData(0xF0093, fontFamily: 'maticons')
                                  : IconData(0xF13F4, fontFamily: 'maticons'),
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
                            Container(
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: Text(
                                'Top Majors',
                                style: TextStyle(
                                    color: Colors.black87, fontSize: 20),
                              ),
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
                                final data = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditTopMajors(),
                                  ),
                                );
                              },
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 20, top: 2, right: 16, bottom: 20),
                        child: topMajors.isNotEmpty
                            ? Wrap(
                                spacing: 4,
                                direction: Axis.horizontal,
                                children: topMajors,
                              )
                            : Text(
                                'No Top majors',
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
                            Container(
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: Text(
                                'Testing',
                                style: TextStyle(
                                    color: Colors.black87, fontSize: 20),
                              ),
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
                                final data = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditTesting(),
                                  ),
                                );
                              },
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 22, top: 2, right: 16, bottom: 20),
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
                        padding: EdgeInsets.only(left: 18, right: 25),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: Text(
                                'Application & Dates',
                                style: TextStyle(
                                    color: Colors.black87, fontSize: 20),
                              ),
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
                                final data = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditApplication(),
                                  ),
                                );
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
                            : Text(
                                'No Application Information',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12,
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
                                padding: EdgeInsets.only(left: 20, top: 5),
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
                        padding: EdgeInsets.only(left: 18, right: 25),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: Text(
                                'Documents',
                                style: TextStyle(
                                    color: Colors.black87, fontSize: 20),
                              ),
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
                                final data = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditDocuments(),
                                  ),
                                );
                              },
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 20, top: 2, right: 1, bottom: 20),
                        child: documentChips.isNotEmpty
                            ? Wrap(
                                spacing: 4,
                                direction: Axis.horizontal,
                                children: documentChips,
                              )
                            : Text(
                                'No Documents',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12,
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

class EditImages extends StatefulWidget {
  final String imageUrl;
  final String logoUrl;
  final int acceptance;
  EditImages(
      {@required this.imageUrl,
      @required this.logoUrl,
      @required this.acceptance});
  @override
  _EditImagesState createState() => _EditImagesState();
}

class _EditImagesState extends State<EditImages> {
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
              'SAVE',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
        title: Text('Edit Appearance', maxLines: 1),
      ),
      body: ListView(
        children: <Widget>[
          Container(
            height: 300,
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(1)),
              child: CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl: widget.imageUrl ??
                    'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cd/Black_flag.svg/1200px-Black_flag.svg.png',
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    image: imageProvider != null
                        ? DecorationImage(
                            alignment: Alignment.center,
                            colorFilter: ColorFilter.mode(
                                Colors.black.withAlpha(50), BlendMode.darken),
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
            ),
          ),
        ],
      ),
    );
  }
}

class EditUniDetails extends StatefulWidget {
  @override
  _EditUniDetailsState createState() => _EditUniDetailsState();
}

class _EditUniDetailsState extends State<EditUniDetails> {
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
              'SAVE',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
        title: Text('Edit Details', maxLines: 1),
      ),
      body: Container(),
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
  @override
  _EditTopMajorsState createState() => _EditTopMajorsState();
}

class _EditTopMajorsState extends State<EditTopMajors> {
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
              'SAVE',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
        title: Text('Edit Top Majors', maxLines: 1),
      ),
      body: Container(),
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
  @override
  _EditTestingState createState() => _EditTestingState();
}

class _EditTestingState extends State<EditTesting> {
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
              'SAVE',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
        title: Text('Edit Testing', maxLines: 1),
      ),
      body: Container(),
    );
  }
}

class EditApplication extends StatefulWidget {
  @override
  _EditApplicationState createState() => _EditApplicationState();
}

class _EditApplicationState extends State<EditApplication> {
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
              'SAVE',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
        title: Text('Edit App & Dates', maxLines: 1),
      ),
      body: Container(),
    );
  }
}

class EditDocuments extends StatefulWidget {
  @override
  _EditDocumentsState createState() => _EditDocumentsState();
}

class _EditDocumentsState extends State<EditDocuments> {
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
              'SAVE',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
        title: Text('Edit Documents', maxLines: 1),
      ),
      body: Container(),
    );
  }
}
