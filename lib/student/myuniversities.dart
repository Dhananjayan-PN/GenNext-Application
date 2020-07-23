import 'package:http/http.dart' as http;
import 'universitypage.dart';
import '../imports.dart';
import 'home.dart';

enum ListGroup { reach, match, safety }

class MyUniversitiesScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyUniversitiesScreenState();
}

class MyUniversitiesScreenState extends State<MyUniversitiesScreen> {
  final _formKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> _scafKey = GlobalKey<ScaffoldState>();
  var refreshKey2 = GlobalKey<RefreshIndicatorState>();
  TextEditingController controller = TextEditingController();
  ScrollController scrollController = ScrollController();
  Map<String, int> uniIds = {};
  List<DropdownMenuItem<String>> uniList = [];
  List collegelist;
  String filter;
  List unis;
  bool isStarred;

  Future collegeList;
  Future favoritedList;

  List categories = ['Reach', 'Match', 'Safety'];

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
    controller.addListener(() {
      setState(() {
        filter = controller.text.toLowerCase();
      });
    });
    collegeList = getCollegeList();
    favoritedList = getFavorited();
    getAvailableUniversities();
  }

  @override
  void dispose() {
    controller.dispose();
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent) {
    print("BACK BUTTON!");
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.fade,
            child: StudentHomeScreen(
              user: newUser,
            )));
    return true;
  }

  Future<void> getAvailableUniversities() async {
    uniIds = {};
    uniList = [];
    final response = await http.get(
      dom + 'api/student/get-all-universities',
      headers: {HttpHeaders.authorizationHeader: "Token $tok"},
    );
    collegelist = await collegeList;
    if (response.statusCode == 200) {
      List universities = json.decode(response.body)['university_data'];
      for (var i = 0; i < universities.length; i++) {
        var name = universities[i]['university_name'];
        var id = universities[i]['university_id'];
        if (collegelist[0].every((uni) => uni['university_id'] != id) &&
            collegelist[1].every((uni) => uni['university_id'] != id) &&
            collegelist[2].every((uni) => uni['university_id'] != id)) {
          uniIds[name] = id;
          uniList.add(
            DropdownMenuItem<String>(
              value: name,
              child: Text(
                name,
                style: TextStyle(fontSize: 16),
              ),
            ),
          );
        }
      }
    } else {
      error(context);
    }
  }

  Future<void> getCollegeList() async {
    final response = await http.get(
      dom + 'api/student/get-college-list',
      headers: {HttpHeaders.authorizationHeader: "Token $tok"},
    );
    if (response.statusCode == 200) {
      List list = [];
      list.add(json.decode(response.body)['reach_college_list_data']);
      list.add(json.decode(response.body)['match_college_list_data']);
      list.add(json.decode(response.body)['safety_college_list_data']);
      return list;
    } else {
      throw 'failed';
    }
  }

  Future<void> getFavorited() async {
    final response = await http.get(
      dom + 'api/student/get-favorited-universities',
      headers: {HttpHeaders.authorizationHeader: "Token $tok"},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body)['favorited_university_data'];
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
      refresh();
    }
  }

  Future<void> add(int id, String category, String op) async {
    final response = await http.put(
      dom + 'api/student/college-list/add',
      headers: {
        HttpHeaders.authorizationHeader: "Token $tok",
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode(
        <String, dynamic>{
          'student_id': newUser.id,
          'university_id': id,
          'college_category': category
        },
      ),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['Response'] == 'University successfully added.') {
        if (op == 'FF') {
          Navigator.pop(context);
          success(
              context, 'University successfully added.\nTime to get working!');
        }
        refresh();
      } else {
        error(context);
      }
    } else {
      error(context);
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

  Future<void> changeCategory(int id, String category) async {
    final response = await http.put(
      dom + 'api/student/college-list/change',
      headers: {
        HttpHeaders.authorizationHeader: "Token $tok",
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode(
        <String, dynamic>{
          'student_id': newUser.id,
          'university_id': id,
          'new_college_category': category
        },
      ),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['Response'] == 'University successfully changed.') {
        // refresh();
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

  addToList(String category) {
    String uniName;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: EdgeInsets.only(top: 15),
          contentPadding: EdgeInsets.all(0),
          elevation: 20,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: Center(
              child: Text('Add to $category',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500))),
          content: Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            child: Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 5, left: 20, right: 20),
                    child: Divider(thickness: 0),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10, left: 25, right: 25),
                    child: SearchableDropdown.single(
                      isCaseSensitiveSearch: false,
                      dialogBox: true,
                      menuBackgroundColor: Colors.white,
                      icon: Icon(
                        Icons.arrow_drop_down,
                        size: 25,
                        color: Colors.black,
                      ),
                      items: uniList,
                      value: uniName,
                      style: TextStyle(color: Colors.black),
                      hint: Padding(
                        padding: EdgeInsets.only(bottom: 5.0),
                        child: Text(
                          "University",
                          style: TextStyle(color: Colors.black54, fontSize: 16),
                        ),
                      ),
                      searchHint: "Pick a University",
                      onChanged: (value) {
                        setState(() {
                          uniName = value;
                        });
                      },
                      isExpanded: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text(
                'Add',
                style: TextStyle(color: Colors.blue),
              ),
              onPressed: () {
                if (uniName != null) {
                  Navigator.pop(context);
                  String catString = category == 'Reach'
                      ? 'R'
                      : category == 'Match' ? 'M' : 'S';
                  add(uniIds[uniName], catString, 'CL');
                } else {
                  return null;
                }
              },
            ),
          ],
        );
      },
    );
  }

  addToListFF(int id, String name) async {
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
      add(id, catString, 'FF');
    }
  }

  void refresh() {
    setState(() {
      collegeList = getCollegeList();
      favoritedList = getFavorited();
      getAvailableUniversities();
    });
  }

  Widget buildCard(uni, bool starred) {
    if (starred != null) {
      uni['favorited_status'] = starred;
    }
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
                  InkWell(
                    child: uni['favorited_status']
                        ? Icon(Icons.star,
                            size: 25.5, color: Colors.yellow[700])
                        : Icon(Icons.star_border,
                            size: 25.5, color: Colors.yellow[700]),
                    onTap: () {
                      editFavorited(uni);
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: InkWell(
                      child: uni['in_college_list']
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
                        uni['in_college_list']
                            ? removeFromList(
                                uni['university_id'], uni['category'])
                            : starred != null
                                ? addToListFF(uni['university_id'],
                                    uni['university_name'])
                                : null;
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
                      child: UniversityPage(university: uni, starred: starred)),
                );
                refresh();
              },
            ),
          ),
        );
    return Hero(
      tag: starred != null
          ? uni['university_id'].toString() + 'starred'
          : uni['university_id'],
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
                cardData(imageProvider, false)),
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
          title: Text('My Universities'),
          bottom: TabBar(
            tabs: [
              Tab(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                    Icon(Icons.view_list),
                    Padding(
                      padding: EdgeInsets.only(left: 3.0),
                      child: Text('College List'),
                    )
                  ])),
              Tab(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                    Icon(Icons.star),
                    Padding(
                      padding: EdgeInsets.only(left: 3.0),
                      child: Text('Starred'),
                    )
                  ])),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            FutureBuilder(
              future: collegeList.timeout(Duration(seconds: 10)),
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
                      padding: EdgeInsets.only(bottom: 100),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                                padding: EdgeInsets.only(
                                    top: 5, left: 30, right: 30),
                                child: Text(
                                  "You haven't added any universities to your college list yet",
                                  style: TextStyle(color: Colors.black54),
                                  textAlign: TextAlign.center,
                                )),
                            Padding(
                              padding: EdgeInsets.only(top: 3),
                              child: Text(
                                  "Add a few from the 'Explore' page to\nsee them show up here!",
                                  style: TextStyle(color: Colors.black54),
                                  textAlign: TextAlign.center),
                            )
                          ],
                        ),
                      ),
                    );
                  } else {
                    List<ChecklistView> checklistsViews = [];
                    for (var i = 0; i < snapshot.data.length; i++) {
                      List<ChecklistItemView> subItems = [];
                      for (var j = 0; j < snapshot.data[i].length; j++) {
                        subItems.add(ChecklistItemView(
                          title: buildCard(snapshot.data[i][j], null),
                          onStartDragItem: (listIndex, itemIndex, state) {},
                          canDrag: true,
                          onDropItem: (oldListIndex, oldItemIndex, listIndex,
                              itemIndex, state) {
                            if (listIndex != oldListIndex) {
                              Map uni = snapshot.data[i][j];
                              changeCategory(
                                  uni['university_id'],
                                  listIndex == 0
                                      ? 'R'
                                      : listIndex == 1 ? 'M' : 'S');
                            }
                          },
                        ));
                      }
                      checklistsViews.add(ChecklistView(
                        items: subItems,
                        isOpen: true,
                        canDrag: false,
                        onDropChecklist: (oldIndex, newIndex, state) {},
                        title: Padding(
                          padding:
                              EdgeInsets.only(left: 20, top: 20, bottom: 3),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                categories[i],
                                style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 25,
                                    fontWeight: FontWeight.w300),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 1, top: 2),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    child: Icon(
                                      Icons.add,
                                      color: Color(0xff005fa8),
                                    ),
                                    onTap: () {
                                      if (uniList.isNotEmpty) {
                                        addToList(categories[i]);
                                      } else {
                                        error(context,
                                            'There are no more universities available.\nCome back another time to try again.');
                                      }
                                    },
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ));
                    }
                    return Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: ChecklistListView(
                        controller: scrollController,
                        checklists: checklistsViews,
                      ),
                    );
                  }
                }
                return Padding(
                  padding: EdgeInsets.only(top: 60),
                  child: CardListSkeleton(
                    isBottomLinesActive: false,
                    length: 10,
                  ),
                );
              },
            ),
            RefreshIndicator(
              key: refreshKey2,
              onRefresh: () {
                refresh();
                return collegeList;
              },
              child: FutureBuilder(
                future: favoritedList.timeout(Duration(seconds: 10)),
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
                        padding: EdgeInsets.only(bottom: 100),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                  padding: EdgeInsets.only(
                                      top: 5, left: 30, right: 30),
                                  child: Text(
                                    "You haven't starred any universites yet.",
                                    style: TextStyle(color: Colors.black54),
                                    textAlign: TextAlign.center,
                                  )),
                              Padding(
                                padding: EdgeInsets.only(top: 3),
                                child: Text(
                                    "Explore and star some to see them show up here!",
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
                                          controller: controller,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return filter == null || filter == ""
                                  ? buildCard(snapshot.data[index - 1], true)
                                  : snapshot.data[index - 1]['university_name']
                                          .toLowerCase()
                                          .contains(filter)
                                      ? buildCard(
                                          snapshot.data[index - 1], true)
                                      : Container();
                            }),
                      );
                    }
                  }
                  return Padding(
                    padding: EdgeInsets.only(top: 60),
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
