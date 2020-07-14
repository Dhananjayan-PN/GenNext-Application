import 'package:flutter/material.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:page_transition/page_transition.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:checklist/checklist.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'universitypage.dart';
import '../shimmer_skeleton.dart';
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
  TextEditingController controller1 = TextEditingController();
  TextEditingController controller2 = TextEditingController();
  ScrollController scrollController = ScrollController();
  Map<String, int> uniIds = {};
  List<DropdownMenuItem<String>> uniList = [];
  List collegelist;
  String filter1;
  String filter2;
  List unis;
  bool isStarred;

  Future collegeList;
  Future favoritedList;

  List categories = ['Reach', 'Match', 'Safety'];

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
    collegeList = getCollegeList();
    favoritedList = getFavorited();
    getAvailableUniversities();
  }

  @override
  void dispose() {
    controller1.dispose();
    controller2.dispose();
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
      Navigator.pop(context);
      _error();
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
          _success('added');
        }
        refresh();
      } else {
        _error();
      }
    } else {
      _error();
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
        _success('remove');
        refresh();
      } else {
        Navigator.pop(context);
        _error();
      }
    } else {
      Navigator.pop(context);
      _error();
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
        _error();
      }
    } else {
      _error();
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
                style: TextStyle(color: Colors.blue),
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
                _loading();
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
      _loading();
      add(id, catString, 'FF');
    }
  }

  _loading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(0),
          elevation: 20,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          content: Container(
            height: 150,
            width: 80,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 50,
                    width: 50,
                    child: SpinKitWave(
                      color: Colors.grey.withOpacity(0.8),
                      size: 25,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 23.0),
                    child: Text(
                      "Saving your changes",
                      style: TextStyle(color: Colors.black, fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  _error([String message]) {
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
            height: 150,
            width: 80,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.error_outline,
                    size: 40,
                    color: Colors.red.withOpacity(0.9),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(
                      message ??
                          'Something went wrong.\nCheck your connection and try again later.',
                      style: TextStyle(color: Colors.black, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  _success(String op) {
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
            height: 150,
            width: 80,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.check_circle_outline,
                    size: 40,
                    color: Colors.green,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(
                      op == 'remove'
                          ? 'University successfully removed.\nHead over to Explore to find more!'
                          : op == 'added'
                              ? 'University successfully added.\nTime to get working!'
                              : 'University successfully moved.\nGet writing!',
                      style: TextStyle(color: Colors.black, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void refresh() {
    setState(() {
      collegeList = getCollegeList();
      favoritedList = getFavorited();
      getAvailableUniversities();
    });
  }

  Widget buildCard(snapshot, int index) {
    unis = snapshot;
    unis[index]['favorited_status'] = true;
    Widget cardData(ImageProvider imageProvider, bool isError) => Container(
          decoration: BoxDecoration(
            gradient: isError
                ? LinearGradient(
                    end: Alignment.topRight,
                    begin: Alignment.bottomLeft,
                    colors: [Color(0xff00AEEF), Color(0xff0072BC)])
                : null,
            image: imageProvider != null
                ? DecorationImage(
                    alignment: Alignment.center,
                    colorFilter: ColorFilter.mode(
                        Colors.black.withAlpha(140), BlendMode.darken),
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
              key: Key(unis[index]['university_id'].toString()),
              title: Text(
                unis[index]['university_name'],
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
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
                    child:
                        Icon(Icons.star, size: 25.5, color: Colors.yellow[700]),
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
                            : addToListFF(unis[index]['university_id'],
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
    return Padding(
      padding: EdgeInsets.only(top: 4, left: 10, right: 10),
      child: Card(
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

  Widget buildCollegeListCard(uni) {
    Widget cardData(ImageProvider imageProvider, bool isError) => Container(
          decoration: BoxDecoration(
            gradient: isError
                ? LinearGradient(
                    end: Alignment.topRight,
                    begin: Alignment.bottomLeft,
                    colors: [Color(0xff00AEEF), Color(0xff0072BC)])
                : null,
            image: imageProvider != null
                ? DecorationImage(
                    alignment: Alignment.center,
                    colorFilter: ColorFilter.mode(
                        Colors.black.withAlpha(140), BlendMode.darken),
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
              key: Key(uni['university_id'].toString()),
              title: Text(
                uni['university_name'],
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
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
                        removeFromList(uni['university_id'], uni['category']);
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
                      child: UniversityPage(university: uni)),
                );
                refresh();
              },
            ),
          ),
        );
    return Padding(
      padding: EdgeInsets.only(top: 4, left: 10, right: 10),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        elevation: 5,
        child: Material(
          color: Colors.transparent,
          child: CachedNetworkImage(
              key: Key(uni['university_id'].toString()),
              imageUrl: uni['image_url'] ??
                  'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cd/Black_flag.svg/1200px-Black_flag.svg.png',
              placeholder: (context, url) => CardPlaceHolder(),
              errorWidget: (context, url, error) => cardData(null, true),
              imageBuilder: (context, imageProvider) =>
                  cardData(imageProvider, false)),
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
        appBar: GradientAppBar(
          elevation: 6,
          title: Text(
            'My Universities',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: Platform.isIOS ? FontWeight.w500 : FontWeight.w400),
          ),
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xff00AEEF), Color(0xff0072BC)]),
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
                          title: buildCollegeListCard(snapshot.data[i][j]),
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
                          padding: EdgeInsets.only(left: 20, top: 20),
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
                                      color: Colors.blue[700],
                                    ),
                                    onTap: () {
                                      if (uniList.isNotEmpty) {
                                        addToList(categories[i]);
                                      } else {
                                        _error(
                                            'There are no more universities available\nCome back some other time to try again');
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
                      return Column(
                        children: <Widget>[
                          Padding(
                            padding:
                                EdgeInsets.only(top: 5, left: 18, right: 30),
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
                                    controller: controller2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(top: 20.0),
                              child: Scrollbar(
                                child: ListView.builder(
                                    primary: true,
                                    scrollDirection: Axis.vertical,
                                    itemCount: snapshot.data.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return filter2 == null || filter2 == ""
                                          ? buildCard(snapshot.data, index)
                                          : snapshot.data[index]
                                                      ['university_name']
                                                  .toLowerCase()
                                                  .contains(filter2)
                                              ? buildCard(snapshot.data, index)
                                              : Container();
                                    }),
                              ),
                            ),
                          ),
                        ],
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
            style: TextStyle(color: Colors.blue),
          ),
          onPressed: () {
            Navigator.pop(context, _listGroup);
          },
        ),
      ],
    );
  }
}
