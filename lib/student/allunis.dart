import 'package:http/http.dart' as http;
import 'universitypage.dart';
import '../imports.dart';
import 'home.dart';

enum ListGroup { reach, match, safety }

class AllUniversitiesScreen extends StatefulWidget {
  @override
  _AllUniversitiesScreenState createState() => _AllUniversitiesScreenState();
}

class _AllUniversitiesScreenState extends State<AllUniversitiesScreen> {
  GlobalKey<ScaffoldState> _scafKey = GlobalKey<ScaffoldState>();
  var refreshKey1 = GlobalKey<RefreshIndicatorState>();
  var refreshKey2 = GlobalKey<RefreshIndicatorState>();
  TextEditingController controller1 = TextEditingController();
  TextEditingController controller2 = TextEditingController();
  String filter1;
  String filter2;
  List unis;
  Future allUniList;
  Future recoUniList;

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
    controller1.addListener(() {
      setState(() {
        filter1 = controller1.text;
      });
    });
    controller2.addListener(() {
      setState(() {
        filter2 = controller2.text;
      });
    });
    allUniList = getAllUniversities();
    recoUniList = getRecommended();
  }

  @override
  void dispose() {
    controller1.dispose();
    controller2.dispose();
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent) {
    curPage = StudentHomeScreen(user: newUser);
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.fade,
            child: StudentHomeScreen(
              user: newUser,
            )));
    return true;
  }

  Future<void> getAllUniversities() async {
    final response = await http.get(
      dom + 'api/student/get-all-universities',
      headers: {HttpHeaders.authorizationHeader: "Token $tok"},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body)['university_data'];
    } else {
      throw 'failed';
    }
  }

  Future<void> getRecommended() async {
    final response = await http.get(
      dom + 'api/student/recommend-universities',
      headers: {HttpHeaders.authorizationHeader: "Token $tok"},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body)['recommended_universities'];
    } else {
      throw 'failed';
    }
  }

  Future<void> editFavoritedStatus(uni, int id, bool curStatus) async {
    final statString = curStatus ? 'unfavorite' : 'favorite';
    final response = await http.put(
      dom + 'api/student/edit-favorite-status/$id/$statString',
      headers: {HttpHeaders.authorizationHeader: "Token $tok"},
    );
    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['Response'] == 'University successfully favorited.') {
        _scafKey.currentState.showSnackBar(
          SnackBar(
            duration: Duration(seconds: 2),
            content: Text(
              'University Starred',
              textAlign: TextAlign.center,
            ),
          ),
        );
        refresh();
      } else if (result['Response'] == 'University successfully unfavorited.') {
        _scafKey.currentState.showSnackBar(
          SnackBar(
            duration: Duration(seconds: 2),
            content: Text(
              'University Unstarred',
              textAlign: TextAlign.center,
            ),
          ),
        );
        refresh();
      } else {
        _scafKey.currentState.showSnackBar(
          SnackBar(
            duration: Duration(seconds: 2),
            content: Text(
              'Unable to send request. Try again later.',
              textAlign: TextAlign.center,
            ),
          ),
        );
        refresh();
      }
    } else {
      _scafKey.currentState.showSnackBar(
        SnackBar(
          duration: Duration(seconds: 2),
          content: Text(
            'Unable to send request. Try again later.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }

  Future<void> remove(int id, String category) async {
    final response = await http.delete(
      dom + 'api/student/delete-college-from-list/$id/$category',
      headers: {HttpHeaders.authorizationHeader: "Token $tok"},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['Response'] == 'University successfully deleted from list.') {
        Navigator.pop(context);
        success(context,
            'University successfully removed.\nHead over to Explore to find more!');
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

  Future<void> add(int id, String category) async {
    final response = await http.put(dom + 'api/student/college-list/add',
        headers: {
          HttpHeaders.authorizationHeader: "Token $tok",
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: jsonEncode(<String, dynamic>{
          'student_id': newUser.id,
          'university_id': id,
          'college_category': category
        }));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['Response'] == 'University successfully added.') {
        Navigator.pop(context);
        success(
            context, 'University successfully added.\nTime to get working!');
        refresh();
      } else {
        error(context);
      }
    } else {
      error(context);
    }
  }

  editFavorited(uni) {
    Future.delayed(Duration(milliseconds: 200), () {
      editFavoritedStatus(uni, uni['university_id'], uni['favorited_status'])
          .timeout(Duration(seconds: 10));
    });
  }

  removeFromList(int id, String category) {
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
                    'Are you sure you want to remove\nthis university from your list?',
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
                'Remove',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.pop(context);
                remove(id, category);
                loading(context);
              },
            ),
          ],
        );
      },
    );
  }

  addToList(int id, String name) async {
    ListGroup data = await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AddToListDialog();
      },
    );
    if (data != null) {
      String catString =
          data == ListGroup.reach ? 'R' : data == ListGroup.match ? 'M' : 'S';
      loading(context);
      add(id, catString);
    }
  }

  void refresh() {
    setState(() {
      allUniList = getAllUniversities();
      recoUniList = getRecommended();
    });
  }

  Widget buildCard(snapshot, int index, bool rec) {
    unis = snapshot;
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
                        Colors.black.withOpacity(0.35), BlendMode.dstIn),
                    image: NetworkImage(
                        'https://www.shareicon.net/data/512x512/2016/08/18/814358_school_512x512.png',
                        scale: 12),
                  ),
          ),
          child: Material(
            color: Colors.transparent,
            child: ListTile(
              title: Text(
                unis[index]['university_name'],
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                unis[index]['university_location'],
                style: TextStyle(
                    color: Colors.white.withOpacity(0.9), fontSize: 13.5),
              ),
              trailing: Wrap(
                children: <Widget>[
                  InkWell(
                    child: unis[index]['favorited_status']
                        ? Icon(Icons.star,
                            size: 25.5, color: Colors.yellow[700])
                        : Icon(Icons.star_border,
                            size: 25.5, color: Colors.yellow[700]),
                    onTap: () {
                      editFavorited(unis[index]);
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: InkWell(
                      child: unis[index]['in_college_list']
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
                        unis[index]['in_college_list']
                            ? removeFromList(unis[index]['university_id'],
                                unis[index]['category'])
                            : addToList(unis[index]['university_id'],
                                unis[index]['university_name']);
                      },
                    ),
                  ),
                ],
              ),
              onTap: () async {
                final data = await Navigator.push(
                  context,
                  PageTransition(
                      type: PageTransitionType.fade,
                      child: UniversityPage(
                        university: unis[index],
                      )),
                );
                refresh();
              },
            ),
          ),
        );
    return Hero(
      tag: rec
          ? unis[index]['university_id'].toString() + 'rec'
          : unis[index]['university_id'],
      child: Card(
        margin: EdgeInsets.only(top: 7, left: 15, right: 15, bottom: 7),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        elevation: 6,
        child: CachedNetworkImage(
          key: Key(unis[index]['university_id'].toString()),
          imageUrl: unis[index]['image_url'] ??
              'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cd/Black_flag.svg/1200px-Black_flag.svg.png',
          placeholder: (context, url) => CardPlaceHolder(),
          errorWidget: (context, url, error) => cardData(null, true),
          imageBuilder: (context, imageProvider) =>
              cardData(imageProvider, false),
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
            'Explore',
          ),
          bottom: TabBar(
            tabs: [
              Tab(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                    Icon(Icons.assessment),
                    Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Text('Recommended'),
                    )
                  ])),
              Tab(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                    Icon(Icons.all_inclusive),
                    Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Text('All Universities'),
                    )
                  ])),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            RefreshIndicator(
              key: refreshKey1,
              onRefresh: () {
                refresh();
                return recoUniList;
              },
              child: FutureBuilder(
                future: recoUniList.timeout(Duration(seconds: 10)),
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
                              Icon(Icons.sentiment_satisfied),
                              Padding(
                                  padding: EdgeInsets.only(
                                      top: 5, left: 30, right: 30),
                                  child: Text(
                                    "There aren't any recommendations\nat the moment",
                                    style: TextStyle(color: Colors.black54),
                                    textAlign: TextAlign.center,
                                  )),
                              Padding(
                                padding: EdgeInsets.only(top: 3),
                                child: Text(
                                    "Come back later to explore your recommendations!",
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
                            primary: true,
                            scrollDirection: Axis.vertical,
                            itemCount: snapshot.data.length + 1,
                            itemBuilder: (BuildContext context, int index) {
                              if (index == 0) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                      top: 5, left: 18, right: 30, bottom: 25),
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
                                              contentPadding:
                                                  EdgeInsets.all(2)),
                                          controller: controller1,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return filter1 == null || filter1 == ""
                                  ? buildCard(snapshot.data, index - 1, true)
                                  : snapshot.data[index - 1]['university_name']
                                          .toLowerCase()
                                          .contains(filter1)
                                      ? buildCard(
                                          snapshot.data, index - 1, true)
                                      : Container();
                            }),
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
            RefreshIndicator(
              key: refreshKey2,
              onRefresh: () {
                refresh();
                return allUniList;
              },
              child: FutureBuilder(
                future: allUniList.timeout(Duration(seconds: 10)),
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
                                style: TextStyle(
                                    fontSize: 18, color: Colors.black54),
                              ),
                              Padding(
                                  padding: EdgeInsets.only(
                                      top: 5, left: 30, right: 30),
                                  child: Text(
                                    "Looks like you haven't added\nany universites yet :(",
                                    style: TextStyle(color: Colors.black54),
                                    textAlign: TextAlign.center,
                                  )),
                              Padding(
                                padding: EdgeInsets.only(top: 3),
                                child: Text(
                                    "Head over to the 'Explore Universities' section to get started!",
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
                            primary: true,
                            scrollDirection: Axis.vertical,
                            itemCount: snapshot.data.length + 1,
                            itemBuilder: (BuildContext context, int index) {
                              if (index == 0) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                      top: 5, left: 18, right: 30, bottom: 25),
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
                                              contentPadding:
                                                  EdgeInsets.all(2)),
                                          controller: controller2,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return filter2 == null || filter2 == ""
                                  ? buildCard(snapshot.data, index - 1, false)
                                  : snapshot.data[index - 1]['university_name']
                                          .toLowerCase()
                                          .contains(filter2)
                                      ? buildCard(
                                          snapshot.data, index - 1, false)
                                      : Container();
                            }),
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
            )
          ],
        ),
      ),
    );
  }
}

class AddToListDialog extends StatefulWidget {
  @override
  _AddToListDialogState createState() => _AddToListDialogState();
}

class _AddToListDialogState extends State<AddToListDialog> {
  ListGroup _listGroup = ListGroup.reach;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: EdgeInsets.only(top: 15),
      contentPadding: EdgeInsets.all(0),
      elevation: 20,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      title: Center(
          child: Text('Add to College List',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500))),
      content: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 5, left: 20, right: 20),
              child: Divider(thickness: 0),
            ),
            Padding(
              padding: EdgeInsets.only(left: 25, right: 25),
              child: Column(
                children: <Widget>[
                  RadioListTile(
                    activeColor: Color(0xff005fa8),
                    title: Text('Reach'),
                    value: ListGroup.reach,
                    groupValue: _listGroup,
                    onChanged: (ListGroup value) {
                      setState(() {
                        _listGroup = value;
                      });
                    },
                  ),
                  RadioListTile(
                    activeColor: Color(0xff005fa8),
                    title: Text('Match'),
                    value: ListGroup.match,
                    groupValue: _listGroup,
                    onChanged: (ListGroup value) {
                      setState(() {
                        _listGroup = value;
                      });
                    },
                  ),
                  RadioListTile(
                    activeColor: Color(0xff005fa8),
                    title: Text('Safety'),
                    value: ListGroup.safety,
                    groupValue: _listGroup,
                    onChanged: (ListGroup value) {
                      setState(() {
                        _listGroup = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text(
            'Cancel',
            style: TextStyle(color: Colors.red),
          ),
          onPressed: () {
            Navigator.pop(context, null);
          },
        ),
        FlatButton(
          child: Text(
            'Add',
            style: TextStyle(color: Color(0xff005fa8)),
          ),
          onPressed: () {
            Navigator.pop(context, _listGroup);
          },
        ),
      ],
    );
  }
}
