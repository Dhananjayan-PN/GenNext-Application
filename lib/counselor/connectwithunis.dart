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
  Future getavailableuniversities;

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
    getavailableuniversities = getAvailableUniversities();
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
      List availableuniversities = json.decode(response.body)['available_unis'];
      return availableuniversities;
    } else {
      throw 'failed';
    }
  }

  Future sendRequest(int id, int index) async {
    String tok = await getToken();
    final response = await http.put(
      dom + 'api/counselor/connect-with-unis/$id',
      headers: {HttpHeaders.authorizationHeader: "Token $tok"},
    );
    if (response.statusCode == 200) {
      if (json.decode(response.body)['Response'] ==
          'Request successfully sent!') {
        unis[index]['request_sent'] = true;
        _scafKey.currentState.showSnackBar(
          SnackBar(
            content: Text(
              'Request successfully sent!',
              textAlign: TextAlign.center,
            ),
          ),
        );
        refresh();
      } else {
        unis[index]['request_failed'] = true;
        _scafKey.currentState.showSnackBar(
          SnackBar(
            content: Text(
              'Request failed. Try again later',
              textAlign: TextAlign.center,
            ),
          ),
        );
        refresh();
      }
    } else {
      unis[index]['request_failed'] = true;
      _scafKey.currentState.showSnackBar(
        SnackBar(
          content: Text(
            'Request failed. Try again later',
            textAlign: TextAlign.center,
          ),
        ),
      );
      refresh();
    }
  }

  void requestSender(int id, int index) async {
    Future.delayed(Duration(milliseconds: 200), () {
      sendRequest(id, index).timeout(Duration(seconds: 10));
    });
  }

  void refresh() {
    setState(() {
      getavailableuniversities = getAvailableUniversities();
    });
  }

  Widget buildCard(uni) {
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
                  Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: InkWell(
                      child: true
                          ? Icon(
                              Icons.check,
                              size: 26,
                              color: Colors.green,
                            )
                          : Icon(
                              Icons.add,
                              size: 26,
                              color: Colors.blue,
                            ),
                      onTap: () {
                        // uni['in_college_list']
                        //     ? removeFromList(
                        //         uni['university_id'], uni['category'])
                        //     : starred != null
                        //         ? addToListFF(uni['university_id'],
                        //             uni['university_name'])
                        //         // ignore: unnecessary_statements
                        //         : null;
                      },
                    ),
                  ),
                ],
              ),
              onTap: () async {
                // // ignore: unused_local_variable
                // final data = await Navigator.push(
                //   context,
                //   PageTransition(
                //       type: PageTransitionType.fade,
                //       child: UniversityPage(university: uni, starred: starred)),
                // );
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
                return getavailableuniversities;
              },
              child: FutureBuilder(
                future: getavailableuniversities.timeout(Duration(seconds: 10)),
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
                                  padding: EdgeInsets.only(
                                      top: 5, left: 30, right: 30),
                                  child: Text(
                                    "Looks like there aren't any\navailable universites at the moment :(",
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
                                        controller: controller1,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return filter1 == null || filter1 == ""
                                ? buildCard(snapshot.data[index - 1])
                                : snapshot.data[index]['university_name']
                                        .toLowerCase()
                                        .contains(filter1.toLowerCase())
                                    ? buildCard(snapshot.data[index - 1])
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
                return getavailableuniversities;
              },
              child: FutureBuilder(
                future: getavailableuniversities.timeout(Duration(seconds: 10)),
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
                                  padding: EdgeInsets.only(
                                      top: 5, left: 30, right: 30),
                                  child: Text(
                                    "Looks like there aren't any\navailable universites at the moment :(",
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
                            }
                            return filter2 == null || filter2 == ""
                                ? buildCard(snapshot.data[index - 1])
                                : snapshot.data[index]['university_name']
                                        .toLowerCase()
                                        .contains(filter2.toLowerCase())
                                    ? buildCard(snapshot.data[index - 1])
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
          ],
        ),
      ),
    );
  }
}
