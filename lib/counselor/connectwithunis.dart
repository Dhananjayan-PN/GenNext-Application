import '../imports.dart';
import 'package:http/http.dart' as http;
import 'home.dart';

class ConnectUniversitiesScreen extends StatefulWidget {
  @override
  _ConnectUniversitiesScreenState createState() =>
      _ConnectUniversitiesScreenState();
}

class _ConnectUniversitiesScreenState extends State<ConnectUniversitiesScreen> {
  GlobalKey<ScaffoldState> _scafKey = GlobalKey<ScaffoldState>();
  var refreshKey1 = GlobalKey<RefreshIndicatorState>();
  var refreshKey2 = GlobalKey<RefreshIndicatorState>();
  TextEditingController controller1 = TextEditingController();
  TextEditingController controller2 = TextEditingController();
  String filter1;
  String filter2;
  List unis;
  Future availableUniversities;
  Future connectedUniversities;

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
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
    availableUniversities = getAvailableUniversities();
    connectedUniversities = getConnectedUnis();
  }

  @override
  void dispose() {
    controller1.dispose();
    controller2.dispose();
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    return true;
  }

  Future getAvailableUniversities() async {
    String tok = await getToken();
    final response = await http.get(
      dom + 'api/counselor/connect-with-unis',
      headers: {HttpHeaders.authorizationHeader: "Token $tok"},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body)['available_unis'];
    } else {
      throw 'failed';
    }
  }

  Future getConnectedUnis() async {
    String tok = await getToken();
    final response = await http.get(
      dom + 'api/counselor/get-connected-unis',
      headers: {HttpHeaders.authorizationHeader: "Token $tok"},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body)['my_connected_unis'];
    } else {
      throw 'failed';
    }
  }

  Future sendRequest(int id) async {
    String tok = await getToken();
    final response = await http.put(
      dom + 'api/counselor/connect-with-unis/$id',
      headers: {HttpHeaders.authorizationHeader: "Token $tok"},
    );
    if (response.statusCode == 200) {
      if (json.decode(response.body)['Response'] ==
          'Request successfully sent!') {
        Navigator.pop(context);
        success(context,
            'Your connection request has been sent.\nKindly wait for the rep to accept it');
        refresh();
      } else if (jsonDecode(response.body)['Reponse'] ==
          'Request already sent!') {
        Navigator.pop(context);
        success(context,
            'Your request has already been sent.\nKindly wait for the rep to accept it');
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

  void refresh() {
    setState(() {
      availableUniversities = getAvailableUniversities();
      connectedUniversities = getConnectedUnis();
    });
  }

  Widget buildCard(uni, connected) {
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
                        Colors.black.withOpacity(0.4), BlendMode.dstIn),
                    image: NetworkImage(
                        'https://www.shareicon.net/data/512x512/2016/08/18/814358_school_512x512.png',
                        scale: 12),
                  ),
          ),
          child: Material(
            color: Colors.transparent,
            child: ListTile(
              key: Key(uni['university_id'].toString()),
              title: Text(
                uni['university_name'],
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                uni['university_location'],
                style: TextStyle(
                    color: Colors.white.withOpacity(0.9), fontSize: 13.5),
              ),
              trailing: Wrap(
                children: <Widget>[
                  connected
                      ? Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: InkWell(
                            child: Icon(
                              Icons.mail,
                              size: 26,
                              color: Colors.blue,
                            ),
                            onTap: () async {
                              if (await canLaunch(
                                  'mailto:${uni['university_rep_email'] ?? 'help@collegegenie.org'}')) {
                                launch(
                                    'mailto:${uni['university_rep_email' ?? 'help@collegegenie.org']}');
                              } else {
                                await ClipboardManager.copyToClipBoard(
                                    uni['university_rep_email'] ??
                                        'help@collegegenie.org');
                                _scafKey.currentState.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Unable to open mail. Email copied to clipboard.',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        )
                      : SizedBox(
                          height: 5,
                          width: 5,
                        ),
                  !connected
                      ? Padding(
                          padding: EdgeInsets.only(left: 7, right: 2),
                          child: InkWell(
                            child: Icon(
                              Icons.add,
                              size: 26,
                              color: Colors.blue,
                            ),
                            onTap: () {
                              loading(context);
                              sendRequest(uni['university_id']);
                            },
                          ),
                        )
                      : Padding(
                          padding: EdgeInsets.only(left: 7, right: 2),
                          child: Icon(
                            Icons.check,
                            size: 26,
                            color: Colors.green,
                          ),
                        ),
                ],
              ),
              onTap: () async {
                // ignore: unused_local_variable
                final data = await Navigator.push(
                  context,
                  PageTransition(
                      type: PageTransitionType.fade,
                      child: UniversityPage(
                          university: uni, connected: uni['request_sent'])),
                );
                refresh();
              },
            ),
          ),
        );
    return Hero(
      tag: uni['university_id'].toString(),
      child: Card(
        margin: EdgeInsets.only(top: 7, left: 15, right: 15, bottom: 7),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        elevation: 6,
        child: CachedNetworkImage(
          key: Key(uni['university_id'].toString()),
          imageUrl: uni['image_url'] ??
              'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cd/Black_flag.svg/1200px-Black_flag.svg.png',
          placeholder: (context, url) => CardPlaceHolder(),
          errorWidget: (context, url, error) => cardData(null, true),
          imageBuilder: (context, imageProvider) =>
              cardData(imageProvider, false),
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: _scafKey,
        backgroundColor: Colors.white,
        drawer: NavDrawer(),
        appBar: AppBar(
          backgroundColor: Color(0xff005fa8),
          elevation: 6,
          title: Text('University Connect'),
          bottom: TabBar(
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.insert_link),
                    Padding(
                      padding: EdgeInsets.only(left: 3.5),
                      child: Text('Connected'),
                    )
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.all_inclusive),
                    Padding(
                      padding: EdgeInsets.only(left: 3.5),
                      child: Text('Universities'),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            RefreshIndicator(
              key: refreshKey1,
              onRefresh: () {
                refresh();
                return connectedUniversities;
              },
              child: FutureBuilder(
                future: connectedUniversities.timeout(Duration(seconds: 10)),
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
                                padding: EdgeInsets.only(bottom: 5),
                                child: Icon(
                                  Icons.insert_link,
                                  size: 35,
                                  color: Colors.black.withOpacity(0.75),
                                ),
                              ),
                              Padding(
                                  padding: EdgeInsets.only(
                                      top: 5, left: 30, right: 30),
                                  child: Text(
                                    "You haven't connected with universities yet.",
                                    style: TextStyle(color: Colors.black54),
                                    textAlign: TextAlign.center,
                                  )),
                              Padding(
                                padding: EdgeInsets.only(top: 3),
                                child: Text(
                                    "Connect with a few to see them show up here!",
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
                          scrollDirection: Axis.vertical,
                          itemCount: snapshot.data.length + 1,
                          itemBuilder: (BuildContext context, int index) {
                            if (index == 0) {
                              return Padding(
                                padding: EdgeInsets.only(
                                    top: 5, left: 18, right: 30, bottom: 20),
                                child: Row(
                                  children: <Widget>[
                                    Padding(
                                      padding:
                                          EdgeInsets.only(top: 5, right: 6),
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
                                          contentPadding: EdgeInsets.all(2),
                                        ),
                                        controller: controller1,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return filter1 == null || filter1 == ""
                                ? buildCard(snapshot.data[index - 1], true)
                                : snapshot.data[index - 1]['university_name']
                                        .toLowerCase()
                                        .contains(filter1.toLowerCase())
                                    ? buildCard(snapshot.data[index - 1], true)
                                    : Container();
                          },
                        ),
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
            ),
            RefreshIndicator(
              key: refreshKey2,
              onRefresh: () {
                refresh();
                return availableUniversities;
              },
              child: FutureBuilder(
                future: availableUniversities.timeout(Duration(seconds: 10)),
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
                                padding: EdgeInsets.only(bottom: 5),
                                child: Icon(
                                  Icons.all_inclusive,
                                  size: 35,
                                  color: Colors.black.withOpacity(0.75),
                                ),
                              ),
                              Padding(
                                  padding: EdgeInsets.only(
                                      top: 5, left: 30, right: 30),
                                  child: Text(
                                    "Looks like there aren't any\navailable universites at the moment.",
                                    style: TextStyle(color: Colors.black54),
                                    textAlign: TextAlign.center,
                                  )),
                              Padding(
                                padding: EdgeInsets.only(top: 3),
                                child: Text(
                                    "Check back later to connect with them!",
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
                          scrollDirection: Axis.vertical,
                          itemCount: snapshot.data.length + 1,
                          itemBuilder: (BuildContext context, int index) {
                            if (index == 0) {
                              return Padding(
                                padding: EdgeInsets.only(
                                    top: 5, left: 18, right: 30, bottom: 20),
                                child: Row(
                                  children: <Widget>[
                                    Padding(
                                      padding:
                                          EdgeInsets.only(top: 5, right: 6),
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
                                          contentPadding: EdgeInsets.all(2),
                                        ),
                                        controller: controller2,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              return filter2 == null || filter2 == ""
                                  ? buildCard(snapshot.data[index - 1],
                                      snapshot.data[index - 1]['request_sent'])
                                  : snapshot.data[index - 1]['university_name']
                                          .toLowerCase()
                                          .contains(filter2)
                                      ? buildCard(
                                          snapshot.data[index - 1],
                                          snapshot.data[index - 1]
                                              ['request_sent'])
                                      : Container();
                            }
                          },
                        ),
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
            ),
          ],
        ),
      ),
    );
  }
}

class UniversityPage extends StatefulWidget {
  final Map university;
  final bool connected;
  UniversityPage({@required this.university, this.connected});
  @override
  _UniversityPageState createState() => _UniversityPageState();
}

class _UniversityPageState extends State<UniversityPage> {
  GlobalKey<ScaffoldState> _scafKey = GlobalKey<ScaffoldState>();
  List<Widget> standOutFactors;
  List<Widget> appChips;
  List<Widget> deadlines;
  List<Widget> topMajors;
  List<Widget> testingReqs;
  List<Widget> documentChips;
  String educationString = '';

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
  }

  @override
  void dispose() {
    super.dispose();
    BackButtonInterceptor.remove(myInterceptor);
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    Navigator.pop(context);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    deadlines = [];
    appChips = [];
    topMajors = [];
    standOutFactors = [];
    testingReqs = [];
    documentChips = [];
    educationString = '';
    if (widget.university['stand_out_factors'] != null) {
      for (int i = 0; i < widget.university['stand_out_factors'].length; i++) {
        standOutFactors.add(
          Chip(
            backgroundColor: Colors.white12,
            shape: StadiumBorder(
                side: BorderSide(color: Color(0xff005fa8), width: 0.0)),
            label: Text(widget.university['stand_out_factors'][i]),
            elevation: 1,
          ),
        );
      }
    }
    if (widget.university['degree_levels'] != null) {
      for (int i = 0; i < widget.university['degree_levels'].length; i++) {
        if (i == 0) {
          educationString += '${widget.university['degree_levels'][i]}';
        } else {
          educationString += ', ${widget.university['degree_levels'][i]}';
        }
      }
    }
    if (widget.university['top_majors'] != null) {
      for (int i = 0; i < widget.university['top_majors'].length; i++) {
        topMajors.add(
          Chip(
            visualDensity: VisualDensity.compact,
            backgroundColor: Colors.white12,
            shape: StadiumBorder(
                side: BorderSide(color: Color(0xff005fa8), width: 0.0)),
            label: Text(
              widget.university['top_majors'][i],
              style:
                  TextStyle(fontSize: 11, color: Colors.black.withOpacity(0.8)),
            ),
            elevation: 1,
          ),
        );
      }
    }
    if (widget.university['testing_requirements'] != null) {
      for (int i = 0;
          i < widget.university['testing_requirements'].length;
          i++) {
        testingReqs.add(
          Chip(
            visualDensity: VisualDensity.compact,
            backgroundColor: Colors.white12,
            shape: StadiumBorder(
                side: BorderSide(color: Color(0xff005fa8), width: 0.0)),
            label: Text(
              widget.university['testing_requirements'][i],
              style:
                  TextStyle(fontSize: 11, color: Colors.black.withOpacity(0.8)),
            ),
            elevation: 1,
          ),
        );
      }
    }
    if (widget.university['document_data'] != null) {
      for (int i = 0; i < widget.university['document_data'].length; i++) {
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
              widget.university['document_data'][i]['document_name'],
              style: TextStyle(
                  fontSize: 12.5, color: Colors.black.withOpacity(0.8)),
            ),
            elevation: 1,
            onPressed: () {
              launch(widget.university['document_data'][i]['document_url']);
            },
          ),
        );
      }
    }
    if (widget.university['application_fee'] != null) {
      appChips.add(
        Chip(
          backgroundColor: Colors.white12,
          shape: StadiumBorder(
              side: BorderSide(color: Color(0xff005fa8), width: 0.0)),
          label: Text(
            r'$' + widget.university['application_fee'].toString(),
            style: TextStyle(fontSize: 16),
          ),
          elevation: 1,
        ),
      );
    }
    if (widget.university['common_app_accepted_status'] != null) {
      appChips.add(
        Chip(
          labelPadding: EdgeInsets.only(right: 5, left: 5),
          avatar: widget.university['common_app_accepted_status']
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
    if (widget.university['coalition_app_accepted_status'] != null) {
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
              widget.university['coalition_app_accepted_status']
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
    if (widget.university['application_types'] != null) {
      for (int i = 0; i < widget.university['application_types'].length; i++) {
        deadlines.add(
          Padding(
            padding: EdgeInsets.only(top: 5, left: 25),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 1),
                  child: Text(
                    widget.university['application_types'][i].keys.first
                            .toString()
                            .toUpperCase() +
                        ':',
                    style: TextStyle(
                        color: Colors.black.withOpacity(0.65), fontSize: 12.5),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 5, top: 0.5),
                  child: Text(
                    widget.university['application_types'][i][widget
                            .university['application_types'][i].keys.first]
                        .toString(),
                    style: TextStyle(
                        color: Colors.black.withOpacity(0.8), fontSize: 18.5),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
    return Scaffold(
      key: _scafKey,
      backgroundColor: Colors.white,
      body: CustomScrollView(
        shrinkWrap: false,
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            expandedHeight: 300,
            flexibleSpace: Hero(
              tag: widget.university['university_id'].toString(),
              child: Stack(
                children: <Widget>[
                  Positioned(
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      key: Key(widget.university['university_id'].toString()),
                      imageUrl: widget.university['image_url'] ??
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
                              padding: EdgeInsets.only(bottom: 30, right: 22.5),
                              child: CircleAvatar(
                                backgroundImage: CachedNetworkImageProvider(
                                    widget.university['logo_url']),
                                backgroundColor: Colors.white,
                                radius: 33,
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
                                      widget.university['acceptance_rate']
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
                              right: widget.university['selectivity']
                                          .toString()
                                          .toUpperCase() ==
                                      'MOST SELECTIVE'
                                  ? 14
                                  : widget.university['selectivity']
                                              .toString()
                                              .toUpperCase() ==
                                          'MORE SELECTIVE'
                                      ? 16
                                      : 30,
                              bottom: 120),
                          child: Row(
                            children: <Widget>[
                              Spacer(),
                              Material(
                                color: Colors.transparent,
                                child: Text(
                                  widget.university['selectivity']
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
                  padding: EdgeInsets.only(left: 20, bottom: 3, right: 15),
                  child: Text(
                    widget.university['university_name'],
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: 21.5,
                        fontWeight: FontWeight.w500),
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
                        widget.university['university_location'],
                        style: TextStyle(color: Colors.black54, fontSize: 15),
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
                        widget.university['usnews_ranking'].toString(),
                        style: TextStyle(color: Colors.black54, fontSize: 15),
                      ),
                    ),
                    Text(
                      widget.university['usnews_ranking']
                              .toString()
                              .endsWith('1')
                          ? 'st'
                          : widget.university['usnews_ranking']
                                  .toString()
                                  .endsWith('2')
                              ? 'nd'
                              : widget.university['usnews_ranking']
                                      .toString()
                                      .endsWith('3')
                                  ? 'rd'
                                  : 'th',
                      style: TextStyle(color: Colors.black54, fontSize: 13),
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
                        widget.university['research_or_not']
                            ? const IconData(0xF0093, fontFamily: 'maticons')
                            : const IconData(0xF13F4, fontFamily: 'maticons'),
                        color: Colors.black54,
                        size: 22,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 6, top: 5),
                      child: widget.university['research_or_not']
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
                          style: TextStyle(color: Colors.black54, fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
                if (widget.university['university_rep'] !=
                        'college_genie_representative' &&
                    widget.university['university_rep'] != null) ...[
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
                            '@' + widget.university['university_rep'],
                            style: TextStyle(color: Color(0xff005fa8)),
                          ),
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),
                ],
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
                          launch(widget.university['website_url']);
                        },
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(left: 16, top: 15, right: 16),
                  child: Wrap(
                    spacing: 8,
                    direction: Axis.horizontal,
                    children: standOutFactors,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 12, left: 18),
                  child: Text(
                    'About',
                    style: TextStyle(color: Colors.black87, fontSize: 20),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 2, left: 19, right: 18),
                  child: Text(
                    widget.university['university_description'] ?? '',
                    maxLines: 100,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.black.withOpacity(0.7), fontSize: 15),
                  ),
                ),
                if (topMajors.isNotEmpty) ...[
                  Padding(
                    padding: EdgeInsets.only(top: 15, left: 18),
                    child: Text(
                      'Top Majors',
                      style: TextStyle(color: Colors.black87, fontSize: 20),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: 22, top: 2, right: 16, bottom: 15),
                    child: Wrap(
                      spacing: 4,
                      direction: Axis.horizontal,
                      children: topMajors,
                    ),
                  ),
                ],
                Padding(
                  padding: EdgeInsets.only(left: 18),
                  child: Text(
                    'Cost',
                    style: TextStyle(color: Colors.black87, fontSize: 20),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 5, left: 25),
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
                          r'$' + '${widget.university['in_state_cost']}',
                          style: TextStyle(
                              color: Colors.black.withOpacity(0.8),
                              fontSize: 18.5),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 5, left: 25),
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
                          r'$' + '${widget.university['out_of_state_cost']}',
                          style: TextStyle(
                              color: Colors.black.withOpacity(0.8),
                              fontSize: 18.5),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 5, left: 25, bottom: 15),
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
                          r'$' + '${widget.university['international_cost']}',
                          style: TextStyle(
                              color: Colors.black.withOpacity(0.8),
                              fontSize: 18.5),
                        ),
                      ),
                    ],
                  ),
                ),
                if (testingReqs.isNotEmpty) ...[
                  Padding(
                    padding: EdgeInsets.only(left: 18),
                    child: Text(
                      'Testing',
                      style: TextStyle(color: Colors.black87, fontSize: 20),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: 22, top: 2, right: 16, bottom: 15),
                    child: Container(
                      child: Wrap(
                        spacing: 4,
                        direction: Axis.horizontal,
                        children: testingReqs,
                      ),
                    ),
                  ),
                ],
                Padding(
                  padding: EdgeInsets.only(left: 18),
                  child: Text(
                    'Application & Dates',
                    style: TextStyle(color: Colors.black87, fontSize: 20),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 23, top: 1, right: 16),
                  child: Container(
                    child: Wrap(
                      spacing: 4,
                      direction: Axis.horizontal,
                      children: appChips,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 15),
                  child: Column(
                    children: deadlines,
                  ),
                ),
                if (documentChips.isNotEmpty) ...[
                  Padding(
                    padding: EdgeInsets.only(left: 18),
                    child: Text(
                      'Documents',
                      style: TextStyle(color: Colors.black87, fontSize: 20),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: 22, top: 2, right: 16, bottom: 25),
                    child: Wrap(
                        spacing: 4,
                        direction: Axis.horizontal,
                        children: documentChips),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
